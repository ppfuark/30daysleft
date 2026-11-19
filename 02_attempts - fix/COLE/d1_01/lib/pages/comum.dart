import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:d1_01/pages/seletiva.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';

class Comum extends StatefulWidget {
  final Map<String, dynamic> me;

  const Comum({super.key, required this.me});
  @override
  State<Comum> createState() => _ComumState();
}

class _ComumState extends State<Comum> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  WebSocket? socket;
  bool connected = false;

  double duration = 0.0;

  Future<void> initWeSock() async {
    try {
      final ws = await WebSocket.connect(
        'ws://10.109.66.126:8080/ws',
      ).timeout(const Duration(seconds: 10));

      socket = ws;

      ws.listen(
        (event) {
          try {
            final message = jsonDecode(event);

            if (message['type'] == 'connected') {
              setState(() => connected = true);
            } else if (message['type'] == 'snapshot' ||
                message['type'] == 'update') {
              final data = message['data'];
              final caminhoes = data['caminhoes'];

              print(caminhoes);

              setState(() {
                points.add(
                  LatLng(
                    caminhoes.first['posicao_atual']['lat'] ?? 0.0,
                    caminhoes.first['posicao_atual']['lat'] ?? 0.0,
                  ),
                );
                userP = LatLng(
                  caminhoes.first['posicao_atual']['lat'] ?? 0.0,
                  caminhoes.first['posicao_atual']['lat'] ?? 0.0,
                );
              });

              print(caminhoes.first['roteamento']['distancia_metros']);
              print(caminhoes.first['roteamento']['duracao_segundos']);
              setState(() {
                duration = caminhoes.first['roteamento']['duracao_segundos'];
              });

              if (caminhoes.first['roteamento']['distancia_metros'] > 200 &&
                  notify) {
                HapticFeedback.vibrate();
                flutterTts.speak('Chegando.');
              }

              setState(() => connected = true);
            } else if (message['type'] == 'error') {
              print('Erro da API: ${message['message']}');
            }
          } catch (e) {
            print('Mensagem WebSocket inválida: $e');
          }
        },
        onDone: () {
          if (mounted) setState(() => connected = false);
        },
        onError: (Object error) {
          debugPrint('Erro no WebSocket: $error');
          if (mounted) setState(() => connected = false);
        },
      );

      ws.add(
        jsonEncode({
          'type': 'subscribe',
          'requestId': 'flutter-1',
          'topic': 'coleta_comum',
          'filters': {'logradouro': 'Rua Osvaldo Lelis'},
        }),
      );

      if (mounted) setState(() => connected = true);
    } catch (e) {
      debugPrint('Erro ao conectar: $e');
      if (mounted) setState(() => connected = false);
      Fluttertoast.showToast(msg: 'Erro: $e', backgroundColor: Colors.red);
    }
  }

  List funcionamentos = [];

  Future<void> startApp() async {
    try {
      final share = await SharedPreferences.getInstance();
      final value = share.getString('last') ?? "";

      setState(() {
        search.text = value;
      });

      final raw = await rootBundle.loadString(
        'assets/período-de-funcionamento.xml',
      );
      final xml = XmlDocument.parse(raw);
      List data = [];
      for (var element in xml.findAllElements('periodo')) {
        setState(() {
          data.add({
            'numero_iso': (data.length).toString(),
            'inicio': element.getAttribute('inicio'),
            'fim': element.getAttribute('fim'),
          });
        });
      }

      setState(() {
        funcionamentos = data;
      });

      initWeSock();

      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      setState(() {});

      setState(() {
        loading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro ao iniciar a Widget'),
          content: Text(e.toString()),
        ),
      );
      setState(() {
        loading = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..forward();
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    socket?.close();
    super.dispose();
  }

  LatLng? userP;

  FlutterTts flutterTts = FlutterTts()..setLanguage('pt-BR');
  final SpeechToText speechToText = SpeechToText()..initialize();

  List<LatLng> points = [];

  final search = TextEditingController();
  final date = TextEditingController();
  final time = TextEditingController();
  final pin = TextEditingController();

  String radioValue = "Outros";
  String dropValue1 = "Manhã";

  bool notify = false;

  bool public = false;
  final key = GlobalKey();

  GoogleMapController? mapController;
  int selecionado = 1;

  LatLng? ruaDestaque;

  Future<void> buscarRua(String texto) async {
    final t = texto.trim().toLowerCase();
    if (t.isEmpty) return;

    final achadas = lixeiras
        .where((e) => e['logradouro'].toString().toLowerCase().contains(t))
        .toList();

    if (achadas.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Rua não encontrada, verifique as disponíveis no json',
        backgroundColor: Colors.red,
      );
      return;
    }

    final c = achadas.first['coordenadas'];
    final ponto = LatLng(c['lat'] as double, c['lng'] as double);

    setState(() => ruaDestaque = ponto);
    await mapController?.animateCamera(CameraUpdate.newLatLngZoom(ponto, 18));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final color = radioValue == "Orgânico"
        ? Colors.green.shade300
        : Colors.white;

    return loading
        ? Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: color,
            appBar: AppBar(
              leading: IconButton(
                key: Key('comum_pop'),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    TextField(
                      key: Key('comum_search'),
                      controller: search,
                      decoration: InputDecoration(
                        hintText: "Digite para buscar o caminhão",
                        suffixIcon: IconButton(
                          onPressed: () async {
                            await speechToText.listen(
                              listenOptions: SpeechListenOptions(
                                localeId: 'pt_BR',
                              ),
                              onResult: (result) {
                                setState(() {
                                  buscarRua(result.recognizedWords);
                                });
                              },
                            );
                          },
                          icon: Icon(Icons.mic),
                        ),
                      ),

                      onChanged: (value) async {
                        setState(() {});

                        final share = await SharedPreferences.getInstance();
                        await share.setString('last', value);
                      },
                    ),
                    TextField(
                      controller: date,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Clique para selecionar a data",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              date.clear();
                            });
                          },
                          icon: Icon(Icons.close),
                        ),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          currentDate: DateTime.now(),
                        );

                        if (date != null) {
                          setState(() {
                            this.date.text =
                                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    DropdownButton(
                      key: Key('comum_drop'),
                      items: [
                        ...["Manhã", "Tarde", "Noite"].map(
                          (e) => DropdownMenuItem(
                            value: e.toString(),
                            child: Text(e),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          dropValue1 = value.toString();
                        });
                      },
                      value: dropValue1,
                    ),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Início')),
                        ButtonSegment(value: 1, label: Text('Coleta Comum')),
                        ButtonSegment(value: 2, label: Text('Coleta Seletiva')),
                      ],
                      selected: {selecionado},
                      onSelectionChanged: (s) {
                        if (s.first == 2) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Seletiva(me: widget.me),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          RadioGroup(
                            onChanged: (value) {
                              setState(() {
                                radioValue = value.toString();
                              });
                            },
                            child: Row(
                              children: [
                                ...['Orgânico', 'Outros', 'Rejeitos'].map(
                                  (e) => RadioMenuButton(
                                    value: e,
                                    groupValue: radioValue,
                                    onChanged: (value) {
                                      setState(() {
                                        radioValue = e;
                                      });
                                    },
                                    child: Text(e),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: RepaintBoundary(
                        key: key,
                        child: GoogleMap(
                          onMapCreated: (c) => mapController = c,
                          circles: {
                            if (ruaDestaque != null)
                              Circle(
                                circleId: const CircleId('destaque'),
                                center: ruaDestaque!,
                                radius: 60,
                                strokeColor: Colors.red,
                                strokeWidth: 3,
                                fillColor: Colors.red.shade300,
                              ),
                          },
                          initialCameraPosition: CameraPosition(
                            target: userP == null
                                ? LatLng(50000, 50000)
                                : LatLng(userP!.latitude, userP!.longitude),
                            zoom: 8,
                          ),
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          polylines: {
                            if ("CAM-01".contains(search.text) &&
                                date.text.isEmpty)
                              Polyline(
                                polylineId: PolylineId('rota'),
                                points: points,
                              ),
                          },
                          markers: {
                            if (public) ...[
                              ...lixeiras
                                  .where(
                                    (e) => e['logradouro'].toString().contains(
                                      search.text,
                                    ),
                                  )
                                  .map(
                                    (e) => Marker(
                                      markerId: MarkerId(e['id'].toString()),
                                      position: LatLng(
                                        e['coordenadas']['lat'] as double,
                                        e['coordenadas']['lng'] as double,
                                      ),
                                      icon:
                                          BitmapDescriptor.defaultMarkerWithHue(
                                            BitmapDescriptor.hueViolet,
                                          ),
                                    ),
                                  ),
                            ],

                            if (userP != null &&
                                "CAM-01".contains(search.text) &&
                                date.text.isEmpty)
                              Marker(
                                onTap: () async {
                                  final myLocation =
                                      await Geolocator.getCurrentPosition();

                                  flutterTts.speak(
                                    '${(Geolocator.distanceBetween(userP!.latitude, userP!.longitude, myLocation.latitude, myLocation.longitude) / 1000).toStringAsFixed(0)} km',
                                  );
                                },
                                markerId: MarkerId('caminhao'),

                                position: userP!,
                              ),
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Previsão: ${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day} ${DateTime.now().add(Duration(seconds: duration.round())).hour.toString().padLeft(2, '0')}:${DateTime.now().add(Duration(seconds: duration.round())).hour.toString().padLeft(2, '0')}",
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Digite o pin'),
                              content: TextField(
                                controller: pin,
                                decoration: InputDecoration(
                                  hintText: "Digite seu PIN",
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Ok!'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    return;
                                  },
                                  child: Text('Fechar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (pin.text == "1234") {
                          Fluttertoast.showToast(
                            msg: 'Correto',
                            backgroundColor: Colors.green,
                          );

                          try {
                            final object =
                                key.currentContext!.findRenderObject()
                                    as RenderRepaintBoundary;
                            final image = await object.toImage();
                            final bytes = await image.toByteData(
                              format: ImageByteFormat.png,
                            );
                            final dir =
                                await getApplicationDocumentsDirectory();
                            final file = File(
                              "/storage/emulated/0/Download/${DateTime.now().millisecondsSinceEpoch}.pdf",
                            );

                            final pdf = pw.Document();
                            pdf.addPage(
                              pw.Page(
                                pageFormat: PdfPageFormat.a4,
                                build: (context) => pw.Center(
                                  child: pw.Image(
                                    pw.MemoryImage(bytes!.buffer.asUint8List()),
                                    fit: pw.BoxFit.contain,
                                  ),
                                ),
                              ),
                            );

                            await file.writeAsBytes(await pdf.save());
                            Fluttertoast.showToast(
                              msg: 'Criado em: ${file.path}',
                              backgroundColor: Colors.green,
                            );
                            print('Criado em: ${file.path}');
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: 'Erro: $e',
                              backgroundColor: Colors.red,
                            );
                          }
                        } else {
                          setState(() {
                            pin.clear();
                          });
                          Fluttertoast.showToast(
                            msg: 'Errado',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: Text("Relatório detalhado"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Digite o pin'),
                              content: TextField(
                                controller: pin,
                                decoration: InputDecoration(
                                  hintText: "Digite seu PIN",
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Ok!'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    return;
                                  },
                                  child: Text('Fechar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (pin.text == "1234") {
                          Fluttertoast.showToast(
                            msg: 'Correto',
                            backgroundColor: Colors.green,
                          );
                          await launchUrl(
                            Uri.parse('https://osasco.sp.gov.br/'),
                            mode: LaunchMode.inAppWebView,
                          );
                        } else {
                          setState(() {
                            pin.clear();
                          });
                          Fluttertoast.showToast(
                            msg: 'Errado',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: Text("Chat com a Prefeitura"),
                    ),

                    ListTile(
                      title: Text("Mostrar Lixeiras Públicas de Coleta Comum"),
                      trailing: Checkbox(
                        key: Key('comum_check'),
                        value: public,
                        onChanged: (value) {
                          setState(() {
                            public = value!;
                          });
                        },
                      ),
                    ),

                    ListTile(
                      title: Text("Notificar Chegada"),
                      trailing: Switch(
                        key: Key('comum_not'),
                        value: notify,
                        onChanged: (value) {
                          setState(() {
                            notify = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

final dynamic lixeiras = [
  {
    "coordenadas": {"lat": -22.1074444, "lng": -50.172956},
    "id": 1001,
    "logradouro": "Rua Osvaldo Lelis",
    "nivel_ocupacao": 20,
    "nome": "Lixeira pública - 1001",
    "referencia":
        "Trecho entre Rua Senador Rodolfo Miranda e João da Costa Vieira.",
    "tipos_residuo_aceitos": ["Orgânico"],
  },
  {
    "coordenadas": {"lat": -22.1082086, "lng": -50.1729761},
    "id": 1002,
    "logradouro": "João da Costa Vieira",
    "nivel_ocupacao": 49,
    "nome": "Lixeira pública - 1002",
    "referencia":
        "Trecho entre Rua Osvaldo Lelis e Rua Durval de Carvalho e Silva.",
    "tipos_residuo_aceitos": ["Rejeitos"],
  },
  {
    "coordenadas": {"lat": -22.1086247, "lng": -50.1743086},
    "id": 1003,
    "logradouro": "Rua Durval de Carvalho e Silva",
    "nivel_ocupacao": 50,
    "nome": "Lixeira pública - 1003",
    "referencia":
        "Trecho entre João da Costa Vieira e Rua Doutor Luiz Miranda.",
    "tipos_residuo_aceitos": ["Outros"],
  },
  {
    "coordenadas": {"lat": -22.1091551, "lng": -50.1744516},
    "id": 1004,
    "logradouro": "Rua Doutor Luiz Miranda",
    "nivel_ocupacao": 51,
    "nome": "Lixeira pública - 1004",
    "referencia":
        "Trecho entre Rua Durval de Carvalho e Silva e Rua Julio da Costa Barros.",
    "tipos_residuo_aceitos": ["Orgânico", "Rejeitos"],
  },
  {
    "coordenadas": {"lat": -22.1088428, "lng": -50.1753049},
    "id": 1005,
    "logradouro": "Rua Julio da Costa Barros",
    "nivel_ocupacao": 90,
    "nome": "Lixeira pública - 1005",
    "referencia":
        "Trecho entre Rua Doutor Luiz Miranda e Rua Senador Rodolfo Miranda.",
    "tipos_residuo_aceitos": ["Rejeitos", "Outros"],
  },
  {
    "coordenadas": {"lat": -22.1074313, "lng": -50.174943},
    "id": 1006,
    "logradouro": "Rua Senador Rodolfo Miranda",
    "nivel_ocupacao": 100,
    "nome": "Lixeira pública - 1006",
    "referencia": "Trecho entre Rua Julio da Costa Barros e Rua Osvaldo Lelis.",
    "tipos_residuo_aceitos": ["Orgânico", "Rejeitos", "Outros"],
  },
];
