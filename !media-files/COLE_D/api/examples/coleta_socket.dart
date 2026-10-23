import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef JsonObject = Map<String, dynamic>;
typedef SnapshotCallback = void Function(String topic, JsonObject snapshot);

/// Cliente para Flutter mobile/desktop ou Dart VM. Não funciona no Flutter Web,
/// pois usa dart:io. Cada tópico mantém sua própria assinatura e último estado.
class ColetaSocketClient {
  ColetaSocketClient({
    required this.url,
    this.onSnapshot,
    this.onEvent,
    this.onConnectionChange,
    this.onDiagnostic,
    this.connectTimeout = const Duration(seconds: 10),
    this.heartbeatInterval = const Duration(seconds: 10),
    this.silenceTimeout = const Duration(seconds: 30),
  }) {
    final uri = Uri.parse(url);
    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      throw ArgumentError.value(url, 'url', 'Use ws:// ou wss://');
    }
    if (connectTimeout <= Duration.zero ||
        heartbeatInterval <= Duration.zero ||
        silenceTimeout <= heartbeatInterval) {
      throw ArgumentError('Timeouts positivos; silêncio maior que heartbeat.');
    }
  }

  final String url;
  final SnapshotCallback? onSnapshot;
  final void Function(JsonObject event)? onEvent;
  final void Function(bool online)? onConnectionChange;
  final void Function(String message)? onDiagnostic;
  final Duration connectTimeout;
  final Duration heartbeatInterval;
  final Duration silenceTimeout;

  final Map<String, JsonObject> _subscriptions = {};
  final Map<String, JsonObject> _snapshots = {};
  WebSocket? _socket;
  StreamSubscription<dynamic>? _listener;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  DateTime? _lastMessageAt;
  bool _disposed = false;
  bool _started = false;
  bool _connecting = false;
  bool _online = false;
  int _generation = 0;
  int _retryAttempt = 0;
  int _requestSequence = 0;

  bool get isConnected => _online;

  /// Cópia imutável do envelope de cada último snapshot/update recebido.
  /// Uma queda de conexão não limpa este cache: mantenha os marcadores visíveis.
  Map<String, JsonObject> get snapshots => Map.unmodifiable(_snapshots);

  JsonObject? lastSnapshot(String topic) => _snapshots[topic];

  /// Pode ser chamado novamente; não abre conexões duplicadas.
  /// Falhas são informadas por onDiagnostic e iniciam a reconexão automática.
  Future<void> connect() async {
    _ensureUsable();
    _started = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _open();
  }

  void subscribeColetaComum({
    String? logradouro,
    String? turno,
    String? tipoResiduo,
    double? lat,
    double? lng,
    bool notifyArrival = false,
  }) {
    _subscribe('coleta_comum', {
      'filters': _filters({
        'logradouro': logradouro,
        'turno': turno,
        'tipo_residuo': tipoResiduo,
      }),
      if (lat != null || lng != null) 'location': _location(lat, lng),
      'notifyArrival': notifyArrival,
    });
  }

  void subscribeColetaSeletiva({
    String? material,
    String? busca,
    double? lat,
    double? lng,
  }) {
    _subscribe('coleta_seletiva', {
      'filters': _filters({'material': material, 'busca': busca}),
      if (lat != null || lng != null) 'location': _location(lat, lng),
    });
  }

  /// Remove somente a assinatura. O cache continua disponível à interface.
  void unsubscribe(String topic) {
    _ensureUsable();
    _subscriptions.remove(topic);
    _send({'type': 'unsubscribe', 'topic': topic, 'requestId': _requestId()});
  }

  void _subscribe(String topic, JsonObject options) {
    _ensureUsable();
    _subscriptions[topic] = _freezeObject(options);
    _sendSubscription(topic);
  }

  void _sendSubscription(String topic) {
    final options = _subscriptions[topic];
    if (options == null) return;
    _send({
      'type': 'subscribe',
      'requestId': _requestId(),
      'topic': topic,
      ...options,
    });
  }

  Future<void> _open() async {
    if (_disposed || !_started || _connecting || _socket != null) return;
    _connecting = true;
    final generation = ++_generation;
    final transport = HttpClient()..connectionTimeout = connectTimeout;
    var expired = false;
    try {
      final pending = WebSocket.connect(url, customClient: transport);
      // Future.timeout não cancela a operação original. Feche também qualquer
      // socket que terminar de abrir depois do timeout ou do dispose.
      unawaited(
        pending.then<void>((socket) {
          if (expired || _disposed || generation != _generation) {
            unawaited(_closeQuietly(socket));
          }
        }, onError: (Object error, StackTrace stack) {}),
      );
      final socket = await pending.timeout(
        connectTimeout,
        onTimeout: () {
          expired = true;
          throw TimeoutException('Tempo de conexão esgotado.', connectTimeout);
        },
      );
      if (_disposed || generation != _generation) {
        await _closeQuietly(socket);
        return;
      }
      _socket = socket;
      _lastMessageAt = DateTime.now();
      _listener = socket.listen(
        (frame) => _handleFrame(frame, generation),
        onDone: () => _loseConnection(generation),
        onError: (Object error, StackTrace stack) {
          onDiagnostic?.call('Conexão interrompida: $error');
          _loseConnection(generation);
        },
        cancelOnError: true,
      );
      _setOnline(true);
      for (final topic in _subscriptions.keys.toList()) {
        _sendSubscription(topic);
      }
      if (_socket == socket && !_disposed) {
        _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
          if (DateTime.now().difference(_lastMessageAt!) >= silenceTimeout) {
            onDiagnostic?.call('Servidor sem resposta; tentando reconectar.');
            _loseConnection(generation);
            return;
          }
          _send({'type': 'ping', 'requestId': _requestId()});
        });
      }
    } catch (error) {
      if (!_disposed && generation == _generation) {
        onDiagnostic?.call('Não foi possível conectar: $error');
        _loseConnection(generation);
      }
    } finally {
      transport.close(force: true);
      _connecting = false;
    }
  }

  void _handleFrame(dynamic frame, int generation) {
    if (_disposed || generation != _generation) return;
    JsonObject message;
    try {
      if (frame is! String) throw const FormatException('Esperado texto JSON.');
      final decoded = jsonDecode(frame);
      if (decoded is! Map<String, dynamic> || decoded['type'] is! String) {
        throw const FormatException('Envelope JSON inválido.');
      }
      message = _freezeObject(decoded);
    } catch (error) {
      onDiagnostic?.call('Mensagem inválida ignorada: $error');
      return;
    }
    _lastMessageAt = DateTime.now();
    final type = message['type'];
    if (type == 'connected') {
      _retryAttempt = 0;
    } else if (type == 'snapshot' || type == 'update') {
      final topic = message['topic'];
      final data = message['data'];
      final validTopic = topic == 'coleta_comum' || topic == 'coleta_seletiva';
      final itemsKey = topic == 'coleta_comum' ? 'caminhoes' : 'pontos';
      if (!validTopic || data is! Map || data[itemsKey] is! List) {
        onDiagnostic?.call('Snapshot inválido ignorado.');
        return;
      }
      // Um frame já em trânsito pode chegar depois de unsubscribe.
      if (!_subscriptions.containsKey(topic)) return;
      _snapshots[topic as String] = message;
      onSnapshot?.call(topic, message);
    } else if (type == 'ping') {
      _send({'type': 'pong', 'requestId': message['requestId']});
    }
    // Inclui connected, pong, arrival_alert e error. O erro remoto mantém
    // requestId/code/message para a aplicação tratar filtros inválidos.
    onEvent?.call(message);
  }

  bool _send(JsonObject message) {
    final socket = _socket;
    if (_disposed || socket == null || socket.readyState != WebSocket.open) {
      return false;
    }
    try {
      socket.add(jsonEncode(message));
      return true;
    } catch (error) {
      onDiagnostic?.call('Falha no envio: $error');
      _loseConnection(_generation);
      return false;
    }
  }

  void _loseConnection(int generation) {
    if (_disposed || generation != _generation) return;
    ++_generation;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    final listener = _listener;
    final socket = _socket;
    _listener = null;
    _socket = null;
    if (listener != null) unawaited(listener.cancel());
    if (socket != null) unawaited(_closeQuietly(socket));
    _setOnline(false);
    if (!_started || _reconnectTimer != null) return;
    // 500 ms, 1 s, 2 s, 4 s, 8 s e, no máximo, 10 s.
    final exponent = _retryAttempt > 5 ? 5 : _retryAttempt;
    final milliseconds = 500 * (1 << exponent);
    _retryAttempt++;
    _reconnectTimer = Timer(
      Duration(milliseconds: milliseconds > 10000 ? 10000 : milliseconds),
      () {
        _reconnectTimer = null;
        unawaited(_open());
      },
    );
  }

  void _setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    onConnectionChange?.call(value);
  }

  String _requestId() => 'app-${++_requestSequence}';

  void _ensureUsable() {
    if (_disposed) throw StateError('O cliente já foi descartado.');
  }

  /// Cancela heartbeat e reconexão; chamadas posteriores não reabrem o socket.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _started = false;
    ++_generation;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    final listener = _listener;
    final socket = _socket;
    _listener = null;
    _socket = null;
    _setOnline(false);
    if (listener != null) await listener.cancel();
    if (socket != null) await _closeQuietly(socket);
  }

  static Future<void> _closeQuietly(WebSocket socket) async {
    try {
      await socket
          .close(WebSocketStatus.goingAway)
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // O transporte pode já ter sido encerrado pela rede.
    }
  }

  static JsonObject _filters(Map<String, String?> values) => {
    for (final entry in values.entries)
      if (entry.value != null && entry.value!.trim().isNotEmpty)
        entry.key: entry.value!.trim(),
  };

  static JsonObject _location(double? lat, double? lng) {
    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      throw ArgumentError('Informe latitude e longitude válidas juntas.');
    }
    return {'lat': lat, 'lng': lng};
  }

  static JsonObject _freezeObject(JsonObject value) =>
      Map<String, dynamic>.unmodifiable(
        value.map((key, item) => MapEntry(key, _freeze(item))),
      );

  static dynamic _freeze(dynamic value) {
    if (value is Map<String, dynamic>) return _freezeObject(value);
    if (value is List) return List<dynamic>.unmodifiable(value.map(_freeze));
    return value;
  }
}
