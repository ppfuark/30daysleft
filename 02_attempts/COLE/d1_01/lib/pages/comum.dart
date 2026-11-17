import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class Comum extends StatefulWidget {
  const Comum({super.key});
  @override
  State<Comum> createState() => _ComumState();
}

class _ComumState extends State<Comum> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  WebSocket? socket;
  bool connected = false;

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

              if (Geolocator.distanceBetween(
                        userP!.latitude,
                        userP!.longitude,
                        points.last.latitude,
                        points.last.longitude,
                      ) >
                      200 &&
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
              child: Column(
                spacing: 20,
                children: [
                  TextField(
                    key: Key('comum_search'),
                    controller: search,
                    decoration: InputDecoration(
                      hintText: "Digite para buscar o caminhão",
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
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(userP!.latitude, userP!.longitude),
                        zoom: 8,
                      ),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      polylines: {
                        if ("CAM-01".contains(search.text) && date.text.isEmpty)
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
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
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
