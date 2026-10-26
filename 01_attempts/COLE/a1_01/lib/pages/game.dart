import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<Game> createState() => _GameState();
}

class Item {
  double x, y;
  String emoji;
  String name;
  bool isRecy;
  Item({
    required this.emoji,
    required this.isRecy,
    required this.name,
    required this.x,
    required this.y,
  });
}

class _GameState extends State<Game> {
  List<Item> items = [];

  final recy = {
    "Plástico": "🍶",
    "Papel": "📄",
    "Vidro": "🍾",
    "Metal": "🥫",
    "Orgânico": "🍎",
  };

  final nRecy = {"Lixo": "🗑", "Pilha": "🔋", "Espelho": "💎"};

  double areaW = 0, areaH = 0, boxX = 0, boxH = 80, boxW = 80;

  int progress = 0;

  bool playing = false, paused = false;

  Future<void> startApp() async {
    setState(() {});

    Timer.periodic(Duration(milliseconds: 128), (timer) {
      if (!playing || paused) {
        return;
      }

      for (var element in List<Item>.from(items)) {
        setState(() {
          element.y += 10;
        });

        final hitBox = element.x < boxX + boxW && boxX < element.x + 50;
        final inBox = element.y > areaH - boxH * 2;

        if (inBox && hitBox) {
          if (element.isRecy) {
            setState(() {
              progress++;
            });

            if (progress == 5) {
              showSucces();
            }
          } else {
            showEnd(element.name);
          }

          items.remove(element);
          setState(() {});
        }

        if (element.y > areaH) {
          items.remove(element);
        }
      }
    });

    Timer.periodic(Duration(seconds: 4), (timer) {
      if (!playing || paused) {
        return;
      }
      final isRec = Random().nextBool();

      final map = isRec ? recy : nRecy;
      final index = Random().nextInt(map.length);

      setState(() {
        items.add(
          Item(
            emoji: map.entries.elementAt(index).value,
            isRecy: isRec,
            name: map.entries.elementAt(index).key,
            x: Random().nextDouble() * areaW,
            y: 0,
          ),
        );
      });
    });
  }

  void showSucces() {
    setState(() {
      paused = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Parabéns", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events),
            Text(
              "Completou o desafio com sucesso! Você esá ajudando a salvar o planeta!",
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  items.clear();
                  progress = 0;

                  paused = false;
                  Navigator.pop(context);
                });
              },
              label: Text("Tentar Novamente"),
              icon: Icon(Icons.replay),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              label: Text("Voltar ao Início"),
              icon: Icon(Icons.home),
            ),
          ],
        ),
      ),
    );
  }

  void showEnd(String name) {
    setState(() {
      paused = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Ops! Item Errado",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, -10),
              child: Icon(Icons.warning_outlined, size: 40),
            ),
            Row(
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(" não é reciclável."),
              ],
            ),
            Text("Tente novamente e colete apenas os items recicláveis"),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  items.clear();
                  progress = 0;

                  paused = false;
                  Navigator.pop(context);
                });
              },
              label: Text("Tentar Novamente"),
              icon: Icon(Icons.replay),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => startApp());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    areaW = w;
    areaH = h;

    return Scaffold(
      body: SizedBox(
        width: w,
        height: h,
        child: !playing
            ? Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.delete),
                    Text("Como Jogar"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mova a lixeira para apanhar apenas os itens"),
                        Row(
                          children: [
                            Text(
                              "recicláveis",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("!"),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "Colete 5 itens recicláveis para vencer. Cuidado com o lixo não reciclável",
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          playing = true;
                        });
                      },
                      child: Text("Começar Jogo"),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                onHorizontalDragUpdate: (details) {
                  if (paused || !playing) return;

                  setState(() {
                    boxX = (boxX + details.delta.dx).clamp(0, areaW - boxW);
                  });
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.white],
                            begin: AlignmentGeometry.topCenter,
                            end: AlignmentGeometry.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    ...items.map(
                      (e) => Positioned(
                        top: e.y,
                        left: e.x,
                        child: Text(e.emoji, style: TextStyle(fontSize: 30)),
                      ),
                    ),
                    Positioned(
                      left: boxX,
                      bottom: 0,
                      child: Container(
                        height: boxH,
                        width: boxW,
                        decoration: BoxDecoration(color: Colors.red),
                        child: Center(
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 50,
                      right: 50,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        width: w,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(100),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Progresso"),
                                Text("$progress/5"),
                              ],
                            ),
                            LinearProgressIndicator(value: progress / 5),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
