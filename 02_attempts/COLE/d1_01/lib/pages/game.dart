import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Game extends StatefulWidget {
  final Map<String, dynamic> me;

  const Game({super.key, required this.me});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  Future<void> startApp() async {
    try {
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
    _controller = AnimationController(vsync: this);
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late double points = widget.me['score_persistente'].toDouble();
  int lifes = 3;
  int rank = 1;

  final raking = [
    {"usuario_id": 1, "nome": "João Silva", "score": 450},
    {"usuario_id": 2, "nome": "Ana Souza", "score": 10},
    {"usuario_id": 3, "nome": "Carlos Oliveira", "score": 5},
    {"usuario_id": 4, "nome": "Mariana Santos", "score": 10},
    {"usuario_id": 5, "nome": "Pedro Costa", "score": 5},
    {"usuario_id": 6, "nome": "Juliana Almeida", "score": 10},
    {"usuario_id": 7, "nome": "Rafael Pereira", "score": 5},
    {"usuario_id": 8, "nome": "Beatriz Lima", "score": 10},
    {"usuario_id": 9, "nome": "Lucas Rodrigues", "score": 5},
    {"usuario_id": 10, "nome": "Camila Ferreira", "score": 10},
  ];

  bool trash = false;

  String radioValue = "Busca de Coleta em Casa";
  bool showBen = false;

  final pin = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return loading
        ? Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  Icon(Icons.person),
                  ListTile(
                    title: Text("Pontuação: "),
                    subtitle: Text(points.toStringAsFixed(0)),
                  ),
                  ListTile(
                    title: Text("Vidas Restantes: "),
                    subtitle: Row(
                      children: [
                        for (int i = 0; i < lifes; i++)
                          Icon(Icons.favorite, color: Colors.red),
                        for (int i = 0; i < 3 - lifes; i++)
                          Icon(Icons.favorite_border, color: Colors.grey),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                              ],
                            );
                          },
                        );

                        if (pin.text == "1234") {
                          Fluttertoast.showToast(
                            msg: 'Correto',
                            backgroundColor: Colors.green,
                          );
                          setState(() {
                            showBen = true;
                          });
                        } else {
                          setState(() {
                            pin.clear();
                          });
                          Fluttertoast.showToast(
                            msg: 'PIN incorreto',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: Text("Resgatar Pontos"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Digite o pin'),
                              content: TextField(
                                key: Key('game_pin'),
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
                              ],
                            );
                          },
                        );

                        if (pin.text == "1234") {
                          Fluttertoast.showToast(
                            msg: 'Correto',
                            backgroundColor: Colors.green,
                          );
                          setState(() {
                            showBen = true;
                          });
                        } else {
                          setState(() {
                            pin.clear();
                          });
                          Fluttertoast.showToast(
                            msg: 'PIN incorreto',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: Text("Trocar por Benefícios"),
                    ),
                  ),
                  ListTile(
                    title: Text("Material Sujo?"),
                    trailing: Switch(
                      key: Key('game_trash'),
                      value: trash,
                      onChanged: (value) {
                        trash = value;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Start"),
                    ),
                  ),
                  if (showBen) ...[
                    RadioGroup(
                      onChanged: (value) {
                        setState(() {
                          radioValue = value.toString();
                        });
                      },
                      child: Column(
                        children: [
                          ...['1 Coleta Grátis', 'Busca de Coleta em Casa'].map(
                            (e) => RadioMenuButton(
                              key: Key(e),
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
                    ElevatedButton(
                      onPressed: () {
                        Fluttertoast.showToast(
                          msg: 'Benefício Coletado!',
                          backgroundColor: Colors.green,
                        );
                      },
                      child: Text("Coletar"),
                    ),
                    IconButton(
                      key: Key('game_pop_home'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.home),
                    ),
                  ],
                ],
              ),
            ),
          );
  }
}
