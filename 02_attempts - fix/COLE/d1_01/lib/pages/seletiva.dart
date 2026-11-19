import 'package:d1_01/pages/comum.dart';
import 'package:d1_01/pages/game.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class Seletiva extends StatefulWidget {
  final Map<String, dynamic> me;

  const Seletiva({super.key, required this.me});
  @override
  State<Seletiva> createState() => _SeletivaState();
}

class _SeletivaState extends State<Seletiva> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  Future<void> startApp() async {
    try {
      final share = await SharedPreferences.getInstance();
      final last = share.getString('radio') ?? "";

      if (last.isNotEmpty) {
        setState(() {
          radioValue = last;
        });
      }
      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      userP = await Geolocator.getCurrentPosition();
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
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..forward()
          ..repeat(reverse: true);
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String radioValue = "Metal";
  final search = TextEditingController();
  Color routeC = Colors.black;

  Position? userP;
  late final SpeechToText speechToText = SpeechToText()
    ..initialize(
      onStatus: (status) {},
      onError: (errorNotification) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Erro ao inicializar speech: ${errorNotification.errorMsg}',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Ok!'),
                ),
              ],
            );
          },
        );
      },
    );

  List<LatLng> points = [];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
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
            appBar: AppBar(),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: search,
                    decoration: InputDecoration(
                      hintText: "Busque um ponto de coleta...",
                      suffixIcon: IconButton(
                        onPressed: () async {
                          speechToText.listen(
                            onResult: (result) {
                              final text = result.recognizedWords;
                              setState(() {
                                search.text = text;
                              });
                            },
                            listenOptions: SpeechListenOptions(
                              localeId: 'pt_BR',
                              cancelOnError: true,
                            ),
                          );
                        },
                        icon: Icon(Icons.mic),
                      ),
                    ),
                  ),

                  RadioGroup(
                    onChanged: (value) {
                      setState(() {
                        radioValue = value.toString();
                      });
                    },
                    child: Column(
                      children: [
                        ...['Metal', 'Plástico', 'Papel', 'Vidro'].map(
                          (e) => RadioMenuButton(
                            value: e,
                            groupValue: radioValue,
                            onChanged: (value) async {
                              setState(() {
                                radioValue = e;
                              });

                              points = [
                                LatLng(userP!.latitude, userP!.longitude),
                                LatLng(
                                  seletivas.firstWhere(
                                        (e) => e['material'] == radioValue,
                                      )['coordenadas']['lat']
                                      as double,
                                  seletivas.firstWhere(
                                        (e) => e['material'] == radioValue,
                                      )['coordenadas']['lng']
                                      as double,
                                ),
                              ];
                              routeC = switch (seletivas.firstWhere(
                                (e) => e['material'] == radioValue,
                              )['material']) {
                                "Metal" => Colors.yellow,
                                "Plástico" => Colors.red,
                                "Papel" => Colors.blue,
                                _ => Colors.green,
                              };

                              setState(() {});

                              final share =
                                  await SharedPreferences.getInstance();
                              await share.setString('radio', value.toString());
                            },
                            child: Text(e),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Início')),
                      ButtonSegment(value: 1, label: Text('Coleta Comum')),
                      ButtonSegment(value: 2, label: Text('Coleta Seletiva')),
                    ],
                    selected: {2},
                    onSelectionChanged: (s) {
                      if (s.first == 1) {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Comum(me: widget.me),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(userP!.latitude, userP!.longitude),
                      ),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      polylines: {
                        Polyline(
                          polylineId: PolylineId('routes'),
                          points: points,
                          color: routeC,
                        ),
                      },
                      markers: {
                        ...seletivas
                            .where(
                              (e) =>
                                  e['material'] == radioValue &&
                                  e['nome'].toString().contains(search.text),
                            )
                            .map(
                              (e) => Marker(
                                onTap: () {
                                  setState(() {
                                    points = [
                                      LatLng(userP!.latitude, userP!.longitude),
                                      LatLng(
                                        e['coordenadas']['lat'] as double,
                                        e['coordenadas']['lng'] as double,
                                      ),
                                    ];

                                    routeC = switch (e['material']) {
                                      "Metal" => Colors.yellow,
                                      "Plástico" => Colors.red,
                                      "Papel" => Colors.blue,
                                      _ => Colors.green,
                                    };
                                  });
                                },
                                markerId: MarkerId(e['id'].toString()),
                                position: LatLng(
                                  e['coordenadas']['lat'] as double,
                                  e['coordenadas']['lng'] as double,
                                ),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueRed,
                                ),
                              ),
                            ),
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final s = seletivas
                            .where(
                              (e) =>
                                  e['material'] == radioValue &&
                                  e['nome'].toString().contains(search.text),
                            )
                            .toList()[index];
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) => ListTile(
                            tileColor: s['nivel_ocupacao'] > 50
                                ? ColorTween(
                                    begin: Colors.red.shade100,
                                    end: Colors.red,
                                  ).animate(_controller).value
                                : null,
                            title: Text(s['nome'].toString()),
                            subtitle: Text(s['logradouro'].toString()),
                            leading: CircleAvatar(
                              backgroundColor: Colors.purpleAccent,
                              child: Center(child: Text(s['id'].toString())),
                            ),
                            trailing: IconButton(
                              key: Key('delete_${s['id'].toString()}'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Game(me: widget.me),
                                  ),
                                );
                              },
                              icon: Icon(Icons.delete),
                            ),
                          ),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: seletivas
                          .where(
                            (e) =>
                                e['material'] == radioValue &&
                                e['nome'].toString().contains(search.text),
                          )
                          .toList()
                          .length,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

final dynamic seletivas = [
  {
    "coordenadas": {"lat": -22.1076527, "lng": -50.1727385},
    "id": 35,
    "logradouro": "Rua Osvaldo Lelis",
    "material": "Metal",
    "nivel_ocupacao": 0,
    "nome": "Ponto de coleta - 35",
    "referencia":
        "Trecho entre Rua Senador Rodolfo Miranda e João da Costa Vieira.",
  },
  {
    "coordenadas": {"lat": -22.1079447, "lng": -50.1727054},
    "id": 36,
    "logradouro": "Rua Osvaldo Lelis",
    "material": "Vidro",
    "nivel_ocupacao": 49,
    "nome": "Ponto de coleta - 36",
    "referencia":
        "Trecho entre Rua Senador Rodolfo Miranda e João da Costa Vieira.",
  },
  {
    "coordenadas": {"lat": -22.1082442, "lng": -50.1735079},
    "id": 37,
    "logradouro": "João da Costa Vieira",
    "material": "Papel",
    "nivel_ocupacao": 50,
    "nome": "Ponto de coleta - 37",
    "referencia":
        "Trecho entre Rua Osvaldo Lelis e Rua Durval de Carvalho e Silva.",
  },
  {
    "coordenadas": {"lat": -22.1081808, "lng": -50.1740504},
    "id": 38,
    "logradouro": "João da Costa Vieira",
    "material": "Plástico",
    "nivel_ocupacao": 51,
    "nome": "Ponto de coleta - 38",
    "referencia":
        "Trecho entre Rua Osvaldo Lelis e Rua Durval de Carvalho e Silva.",
  },
  {
    "coordenadas": {"lat": -22.1085, "lng": -50.1742},
    "id": 34,
    "logradouro": "Rua Durval de Carvalho e Silva",
    "material": "Plástico",
    "nivel_ocupacao": 85,
    "nome": "Ponto de coleta - 34",
    "referencia":
        "Trecho entre João da Costa Vieira e Rua Doutor Luiz Miranda.",
  },
  {
    "coordenadas": {"lat": -22.1089793, "lng": -50.1743934},
    "id": 39,
    "logradouro": "Rua Durval de Carvalho e Silva",
    "material": "Metal",
    "nivel_ocupacao": 89,
    "nome": "Ponto de coleta - 39",
    "referencia":
        "Trecho entre João da Costa Vieira e Rua Doutor Luiz Miranda.",
  },
  {
    "coordenadas": {"lat": -22.109, "lng": -50.175},
    "id": 31,
    "logradouro": "Rua Doutor Luiz Miranda",
    "material": "Papel",
    "nivel_ocupacao": 30,
    "nome": "Ponto de coleta - 31",
    "referencia":
        "Trecho entre Rua Durval de Carvalho e Silva e Rua Julio da Costa Barros.",
  },
  {
    "coordenadas": {"lat": -22.1090819, "lng": -50.1748584},
    "id": 40,
    "logradouro": "Rua Doutor Luiz Miranda",
    "material": "Vidro",
    "nivel_ocupacao": 90,
    "nome": "Ponto de coleta - 40",
    "referencia":
        "Trecho entre Rua Durval de Carvalho e Silva e Rua Julio da Costa Barros.",
  },
  {
    "coordenadas": {"lat": -22.1083495, "lng": -50.1753513},
    "id": 41,
    "logradouro": "Rua Julio da Costa Barros",
    "material": "Papel",
    "nivel_ocupacao": 91,
    "nome": "Ponto de coleta - 41",
    "referencia":
        "Trecho entre Rua Doutor Luiz Miranda e Rua Senador Rodolfo Miranda.",
  },
  {
    "coordenadas": {"lat": -22.1078468, "lng": -50.1752903},
    "id": 42,
    "logradouro": "Rua Julio da Costa Barros",
    "material": "Plástico",
    "nivel_ocupacao": 100,
    "nome": "Ponto de coleta - 42",
    "referencia":
        "Trecho entre Rua Doutor Luiz Miranda e Rua Senador Rodolfo Miranda.",
  },
  {
    "coordenadas": {"lat": -22.1073703, "lng": -50.1742729},
    "id": 43,
    "logradouro": "Rua Senador Rodolfo Miranda",
    "material": "Metal",
    "nivel_ocupacao": 65,
    "nome": "Ponto de coleta - 43",
    "referencia": "Trecho entre Rua Julio da Costa Barros e Rua Osvaldo Lelis.",
  },
  {
    "coordenadas": {"lat": -22.1074109, "lng": -50.1735901},
    "id": 44,
    "logradouro": "Rua Senador Rodolfo Miranda",
    "material": "Vidro",
    "nivel_ocupacao": 20,
    "nome": "Ponto de coleta - 44",
    "referencia": "Trecho entre Rua Julio da Costa Barros e Rua Osvaldo Lelis.",
  },
];
