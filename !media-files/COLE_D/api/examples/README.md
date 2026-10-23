# Cliente Dart/Flutter para as telas 3 e 4

`coleta_socket.dart` é um cliente reutilizável para Flutter Android/iOS/desktop
ou Dart VM. Ele usa somente `dart:io`, `dart:async` e `dart:convert`; não exige
pacote de WebSocket no `pubspec.yaml`. Não é um aplicativo Flutter completo e
não suporta Flutter Web, que precisa de um transporte compatível com navegador.

## Endereço de desenvolvimento

Inicie a API com `HOST=0.0.0.0` para permitir acesso pela rede. No PowerShell,
defina `$env:HOST = '0.0.0.0'` antes do comando de inicialização do servidor.

| Onde o cliente executa | URL |
| --- | --- |
| Emulador Android padrão | `ws://10.0.2.2:8080/ws` |
| Dart/Flutter desktop na mesma máquina | `ws://127.0.0.1:8080/ws` |
| Celular físico na mesma rede | `ws://IP-LOCAL-DO-PC:8080/ws` |

No celular físico, libere a porta 8080 no firewall para a rede de
desenvolvimento. `0.0.0.0` é endereço de escuta do servidor; use o IP do PC no
cliente. Android requer a permissão `android.permission.INTERNET`. Para testes
locais com `ws://`, permita tráfego sem TLS somente na configuração de debug
(`android:usesCleartextTraffic="true"` no `<application>` do manifest de debug).
Em produção, configure TLS e use `wss://`.

## Uso nas duas telas

Copie o arquivo para o projeto e adapte os callbacks ao gerenciador de estado
usado no aplicativo. `onSnapshot` recebe o envelope inteiro; os objetos do mapa
ficam em `snapshot['data']`. Os nomes de filtros são os do protocolo da API.

```dart
import 'coleta_socket.dart';

late final ColetaSocketClient coleta;

Future<void> iniciar() async {
  coleta = ColetaSocketClient(
    url: 'ws://10.0.2.2:8080/ws',
    onConnectionChange: (online) {
      // Atualize o estado da UI. Quando false, exiba a faixa vermelha
      // "Sem conexão" e mantenha os últimos marcadores no mapa.
      atualizarStatusDaTela(online);
    },
    onSnapshot: (topic, snapshot) {
      final data = snapshot['data'] as Map<String, dynamic>;
      if (topic == 'coleta_comum') {
        atualizarCaminhoes(data['caminhoes'] as List);
      } else {
        atualizarPontos(
          data['pontos'] as List,
          data['ponto_mais_proximo'],
        );
      }
    },
    onEvent: (event) {
      if (event['type'] == 'arrival_alert') {
        final data = event['data'] as Map<String, dynamic>;
        mostrarAvisoDeChegada(data['caminhao_id'], data['distancia_metros']);
      } else if (event['type'] == 'error') {
        mostrarErroDaApi(event['code'], event['message']);
      }
    },
  );

  // As assinaturas podem ser configuradas antes da conexão.
  coleta.subscribeColetaComum(
    logradouro: 'Rua Osvaldo Lelis', // Via do cenário roteado incluído.
    lat: -22.1085,
    lng: -50.1742,
    notifyArrival: true,
  );
  coleta.subscribeColetaSeletiva(
    material: 'Plástico',
    lat: -22.1085,
    lng: -50.1742,
  );
  await coleta.connect();
}

// Ao mudar um filtro, repita a assinatura do tópico com todos os filtros
// desejados. Isso substitui a assinatura anterior desse tópico.
void filtrarPontos(String busca) {
  coleta.subscribeColetaSeletiva(busca: busca);
}

// Ao sair de uma tela, se ela não deve receber atualizações:
void sairDaTela3() => coleta.unsubscribe('coleta_comum');

// Ao encerrar o serviço/aplicativo:
Future<void> encerrar() => coleta.dispose();
```

As funções `atualizarStatusDaTela`, `atualizarCaminhoes`, `atualizarPontos`,
`mostrarAvisoDeChegada` e `mostrarErroDaApi` são pontos de integração da sua
interface, não funções prontas fornecidas pelo exemplo. Inicialize o estado
visual como desconectado (`coleta.isConnected` é `false` até a conexão abrir).
Se usar callbacks com `setState`, verifique `mounted`; descarte o cliente no
ciclo de vida do serviço ou widget que é seu proprietário.

O cliente mantém os dois tópicos e os reassina depois da reconexão. Ele tenta
novamente em 500 ms, 1 s, 2 s, 4 s, 8 s e então a cada 10 s; envia `ping` JSON e
considera a conexão perdida após 30 s sem mensagens. Mensagens inválidas são
ignoradas com diagnóstico opcional. `dispose()` cancela a reconexão.

`snapshot` e `update` contêm o estado completo do tópico. Substitua a lista
exibida quando um desses eventos chegar. Durante uma queda, consulte
`coleta.lastSnapshot('coleta_comum')` ou `coleta.snapshots` e preserve a última
posição. Esses dados são imutáveis e devem aparecer como desatualizados enquanto
`isConnected` for `false`. Não calcule deslocamento novo durante a desconexão.

O alerta de chegada informa o ID do caminhão e a distância. Cabe à interface
aplicar o comportamento visual/sonoro e as regras de pontuação da prova. A API
não detecta capturas de tela do dispositivo. A rota pelas ruas e o desenho da
navegação devem ser obtidos pelo provedor de mapas/rotas escolhido no frontend;
as coordenadas e a distância direta da API não substituem esse serviço.

## Persistência local opcional

O cache em memória sobrevive às quedas de rede, mas termina ao fechar o processo.
Para lembrar a última rua/filtro/pontuação e reabrir com os últimos marcadores,
o aplicativo pode adicionar `shared_preferences` e salvar um objeto JSON local.
Não precisa enviar esses dados para a API.

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> salvarEstadoLocal(
  ColetaSocketClient coleta,
  String ultimaRua,
  Map<String, dynamic> filtros,
  int pontuacao,
) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('coleta.estado.v1', jsonEncode({
    'ultimaRua': ultimaRua,
    'filtros': filtros,
    'pontuacao': pontuacao,
    'snapshots': coleta.snapshots,
    'salvoEm': DateTime.now().toUtc().toIso8601String(),
  }));
}

Future<Map<String, dynamic>?> restaurarEstadoLocal() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('coleta.estado.v1');
  if (raw == null) return null;
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}
```

Restaure esse objeto antes de abrir a conexão: apresente o cache salvo com
status offline e preencha os controles com a última rua e filtros. Depois
reaplique os filtros com `subscribeColetaComum`/`subscribeColetaSeletiva`.
O primeiro snapshot do servidor substitui o cache visual. A pontuação fica sob
responsabilidade do aplicativo. Para alertas, solicite a localização atual do
usuário; a coordenada salva pode estar antiga. Evite persistir coordenadas
quando elas não forem necessárias.

## Verificação no seu projeto

```text
dart format lib/coleta_socket.dart
dart analyze lib/coleta_socket.dart
```

Valide em dispositivo/emulador: dois tópicos ativos, mudança dos filtros,
servidor desligado, faixa offline com marcadores preservados e reconexão com
as duas assinaturas. Este repositório fornece um exemplo de integração; não
inclui um projeto Flutter nem um build Flutter validado.
