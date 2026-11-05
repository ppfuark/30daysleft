import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final name = TextEditingController();
  final age = TextEditingController();

  Future<void> startApp() async {}
  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.directions_car),
            Text("WSConecta Mini Game"),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📱 Incline para frente para acelerarar"),
                      Text("📱 Incline para trás para frear"),
                      Text("📱 Teclado: ↑↓←→"),
                      Text("📱 Colete medalhas para carregar o power-up"),
                      Text("📱 Sacuda o dispositivo com +70% para ativar"),
                    ],
                  ),
                ),
              ),
            ),
            TextField(
              controller: name,
              decoration: InputDecoration(hintText: "Insira seu nome"),
            ),
            TextField(
              controller: age,
              decoration: InputDecoration(hintText: "Sua idade"),
            ),
            ElevatedButton(
              onPressed: () {
                if (age.text.isEmpty || name.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Campos vazios',
                    backgroundColor: Colors.red,
                  );
                  return;
                }
                if (int.parse(age.text) < 16) {
                  Fluttertoast.showToast(
                    msg: 'Idade insuficiente, por favor, volte no futuro.',
                    backgroundColor: Colors.red,
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Game(name: name.text),
                  ),
                );
              },
              child: Text("Jogar"),
            ),
          ],
        ),
      ),
    );
  }
}

class Game extends StatefulWidget {
  final String name;

  const Game({super.key, required this.name});
  @override
  State<Game> createState() => _GameState();
}

class Item {
  double x, y;
  double? medalX;

  Item(this.x, this.y, [this.medalX]);
}

class _GameState extends State<Game> {
  double trackSize = 130, medalSize = 30, carH = 80, carW = 60;

  double areaW = 0,
      areaH = 0,
      carX = 0,
      distance = 0,
      speed = 5,
      power = 0,
      damages = 0,
      invencibleLeft = 10;

  bool over = false,
      paused = false,
      offTrack = false,
      invencible = false,
      accel = false;

  final musicP = AudioPlayer();
  final medalP = AudioPlayer();

  Timer? gameT, invencT, speedT;

  List<Item> items = [];

  int get stars => distance < 100
      ? 1
      : distance < 150
      ? 2
      : distance < 200
      ? 3
      : distance < 250
      ? 4
      : 5;

  String get date {
    final now = DateTime.now();

    if (now.day < 10) return "${now.day}/${now.month}/'${now.year % 100}";

    final weekd = [
      'segunda-feira',
      'terça-feira',
      'quarta-feira',
      'quinta-feira',
      'sexta-feira',
      'sábado',
      'domingo',
    ];

    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return "${weekd[now.weekday]}, ${now.day.toString().padLeft(2, '0')} de ${months[now.month - 1]} de ${now.year}";
  }

  void spawn() {
    final last = items.last;
    final x = (last.x + Random().nextDouble() * 80 - 40).clamp(
      0,
      areaW - trackSize,
    );
    final y = last.y - trackSize;

    items.add(
      Item(x.toDouble(), y, Random().nextBool() ? x + trackSize / 2 : null),
    );
  }

  Future<void> startApp() async {
    setState(() {
      gameT?.cancel();
      areaW = 0;
      areaH = 0;
      carX = 0;
      distance = 0;
      speed = 5;
      power = 0;
      damages = 0;
      invencibleLeft = 10;

      over = false;
      paused = false;
      offTrack = false;
      invencible = false;
      accel = false;

      areaH = MediaQuery.of(context).size.height;
      areaW = MediaQuery.of(context).size.width;
      carX = areaW / 2;
    });

    final needed = (areaH / trackSize).ceil();
    items.add(Item(areaW / 2, areaH - trackSize));

    for (var i = 0; i < needed; i++) {
      spawn();
    }

    musicP.play(AssetSource('trilha-sonora.mp3'));

    gameT = Timer.periodic(Duration(milliseconds: 64), (timer) {
      if (over || paused) return;

      distance += speed / 100;

      for (var element in List<Item>.from(items)) {
        element.y += speed;

        if (element.medalX == null) continue;

        final medalY = element.y + trackSize / 2;

        final touching =
            medalY < areaH - carH - 24 + carH &&
            areaH - carH - 24 < medalY + medalSize &&
            carX < (element.x + trackSize / 2) + medalSize &&
            element.x + trackSize / 2 < carX + carW;

        if (touching) {
          setState(() {
            element.medalX = null;
            power = (power + 10).clamp(0, 100);
            medalP.play(AssetSource('pegou-medalha.mp3'));
          });
        }
      }

      if (items.first.y > areaH) {
        items.removeAt(0);
        spawn();
      }

      setState(() {});
      final trackY = items.where(
        (element) =>
            element.y <= carH - areaH - 24 &&
            carH - areaH - 24 < element.y + trackSize,
      );

      if (trackY.isEmpty) return;

      final notOut =
          carX < trackY.first.x + trackSize && trackY.first.x < carX + carW;

      if (notOut) {
        offTrack = false;
      } else if (!notOut && !invencible && !offTrack) {
        setState(() {
          offTrack = true;
          damages++;
        });
        if (damages > 3) {
          if (over) return;
          setState(() {
            over = true;
          });
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Game Over"),
              content: Row(
                children: [
                  for (int i = 0; i < stars; i++)
                    Icon(Icons.star, color: Colors.amber),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text: "${widget.name} conseguiu $stars troféus\n$date",
                      ),
                    );
                  },
                  child: Text("Compartilhar Score"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    startApp();
                  },
                  child: Text("Tentar novamente"),
                ),
              ],
            ),
          );
        }
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    accelerometerEventStream().listen((event) {
      accel = event.z > 2.0;

      if (accel){
        speed = (speed + .2).clamp(5, 15);
      }else{
        speed = (speed - .2).clamp(5, 15);
      }

      if (accel && event.y.abs() > 2.0) {
        if (over) return;
        setState(() {
          over = true;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Game Over"),
            content: Row(
              children: [
                for (int i = 0; i < stars; i++)
                  Icon(Icons.star, color: Colors.amber),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: "${widget.name} conseguiu $stars troféus\n$date",
                    ),
                  );
                },
                child: Text("Compartilhar Score"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  startApp();
                },
                child: Text("Tentar novamente"),
              ),
            ],
          ),
        );
      } else if (!accel && event.y.abs() > 2.0 && power >= 70) {
        invencible = true;
        power = 0;
        setState(() {});
        invencT = Timer.periodic(Duration(seconds: 1), (timer) {
          invencibleLeft--;
          setState(() {});
          if (invencibleLeft <= 0) {
            setState(() {
              invencible = false;
              invencibleLeft = 10;
              invencT?.cancel();
            });
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => startApp());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragUpdate: (details) => setState(() {
          carX = (carX + details.delta.dx).clamp(0, areaW - carW);
        }),
        child: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/icons/background.png',
                  fit: BoxFit.cover,
                ),
              ),
              for (final e in items) ...[
                Positioned(
                  width: trackSize,
                  height: trackSize,
                  top: e.y,
                  left: e.x,
                  child: Image.asset('assets/icons/rua.png'),
                ),
                if (e.medalX != null)
                  Positioned(
                    width: medalSize,
                    height: medalSize,
                    top: e.y + trackSize / 2,
                    left: e.medalX,
                    child: Image.asset('assets/icons/medalha.png'),
                  ),
              ],
              Positioned(
                width: carW,
                height: carH,
                left: carX,
                top: areaH - 24 - carH,
                child: Image.asset(
                  'assets/icons/carro-topdown.png',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: power / 100,
                        minHeight: 20,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < damages; i++)
                          Icon(Icons.heart_broken, color: Colors.white),
                      ],
                    ),
                    if (invencible)
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                value: invencibleLeft / 10,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              invencibleLeft.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          paused = true;
                        });
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Jogo pausado"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    paused = false;
                                  });
                                },
                                child: Text("Continuar"),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(Icons.pause, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
