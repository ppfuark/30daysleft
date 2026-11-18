import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(const MaterialApp(home: Menu()));

class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final name = TextEditingController();
  final age = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/icons/caminhão.png', height: 80),
            const Text(
              "Coleta Já - Rota da Coleta",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.screen_rotation),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Mova o dispositivo para direita ou esquerda para mover o caminhão",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.warning_amber),
                          SizedBox(width: 8),
                          Expanded(child: Text("Desvie de obstáculos na via.")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TextField(
              controller: name,
              decoration: const InputDecoration(hintText: "Insira seu nome"),
            ),
            TextField(
              controller: age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Sua idade"),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.text.isEmpty || age.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Campos vazios',
                    backgroundColor: Colors.red,
                  );
                  return;
                }
                if ((int.tryParse(age.text) ?? 0) < 16) {
                  Fluttertoast.showToast(
                    msg:
                        'Idade insuficiente para operar o caminhão, por favor, volte no futuro.',
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
              child: const Text("Jogar"),
            ),
          ],
        ),
      ),
    );
  }
}

enum Kind { bag, hole, cone }

class Item {
  double x, y;
  Kind kind;

  Item(this.x, this.y, this.kind);
}

class Game extends StatefulWidget {
  final String name;

  const Game({super.key, required this.name});
  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final double truckW = 60, truckH = 90, itemSize = 44, rowGap = 130;

  double areaW = 0,
      areaH = 0,
      laneW = 0,
      speed = 5,
      baseSpeed = 5,
      scroll = 0,
      tiltZ = 0,
      power = 0,
      bagChance = .6;

  int lane = 1, kg = 0, damages = 0, invencibleLeft = 10;

  bool over = false,
      paused = false,
      invencible = false,
      canChangeLane = true,
      listening = false,
      speechReady = false;

  final musicP = AudioPlayer();
  final bagP = AudioPlayer();
  final speech = SpeechToText();

  Timer? gameT, invencT, speedT;
  StreamSubscription? accelSub;

  List<Item> items = [];

  int get trashCans => kg < 100
      ? 1
      : kg < 150
      ? 2
      : kg < 200
      ? 3
      : kg < 250
      ? 4
      : 5;

  String get date {
    final now = DateTime.now();

    if (now.day >= 10) return "${now.day}/${now.month}/'${now.year % 100}";

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

    return "${weekd[now.weekday - 1]}, ${now.day.toString().padLeft(2, '0')} de ${months[now.month - 1]} de ${now.year}";
  }

  double laneCenter(int laneIndex) => laneIndex * laneW + laneW / 2;

  void spawnRow() {
    final random = Random();
    final obstacleLane = random.nextInt(3);

    if (random.nextDouble() < .7) {
      items.add(
        Item(
          laneCenter(obstacleLane),
          -itemSize,
          random.nextBool() ? Kind.hole : Kind.cone,
        ),
      );
    }

    if (random.nextDouble() < bagChance) {
      final bagLane = (obstacleLane + 1 + random.nextInt(2)) % 3;
      items.add(Item(laneCenter(bagLane), -itemSize, Kind.bag));
    }

    bagChance = max(.1, bagChance - .01);
  }

  void gameOver() {
    if (over) return;
    setState(() => over = true);
    musicP.stop();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Fim de Turno"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < trashCans; i++)
                  Image.asset('assets/icons/lixeira.png', width: 36),
              ],
            ),
            const SizedBox(height: 8),
            Text("$kg Kg coletados"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text:
                      "${widget.name} coletou $kg Kg de lixo e alcançou $trashCans lixeiras\n$date",
                ),
              );
            },
            child: const Text("Compartilhar Score"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startApp();
            },
            child: const Text("Tentar novamente"),
          ),
        ],
      ),
    );
  }

  Future<void> startApp() async {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    gameT?.cancel();
    invencT?.cancel();
    speedT?.cancel();

    setState(() {
      areaH = MediaQuery.of(context).size.height;
      areaW = MediaQuery.of(context).size.width;
      laneW = areaW / 3;
      lane = 1;
      kg = 0;
      damages = 0;
      invencibleLeft = 10;
      speed = 5;
      baseSpeed = 5;
      scroll = 0;
      power = 0;
      bagChance = .6;
      over = false;
      paused = false;
      invencible = false;
      canChangeLane = true;
      listening = false;
      items = [];
    });

    if (!speechReady) {
      speechReady = await speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') listening = false;
        },
      );
    }

    await musicP.setReleaseMode(ReleaseMode.loop);
    musicP.play(AssetSource('media-files/trilha_sonora_jogo.mp3'));

    speedT = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!over && !paused) baseSpeed += 1;
    });

    gameT = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (over || paused) return;

      final target = tiltZ > 2
          ? baseSpeed + 5
          : tiltZ < -2
          ? max(2.0, baseSpeed - 3)
          : baseSpeed;
      speed += (target - speed).clamp(-.3, .3).toDouble();

      scroll += speed;
      if (scroll >= rowGap) {
        scroll -= rowGap;
        spawnRow();
      }

      final truckCenterX = laneCenter(lane);
      final truckCenterY = areaH - 24 - truckH / 2;

      for (final e in List<Item>.from(items)) {
        e.y += speed;

        if (invencible && e.kind == Kind.bag) {
          e.x += (truckCenterX - e.x) * .15;
          e.y += (truckCenterY - (e.y + itemSize / 2)) * .15;
        }

        final touching =
            (e.x - truckCenterX).abs() < (itemSize + truckW) / 2 - 8 &&
            (e.y + itemSize / 2 - truckCenterY).abs() <
                (itemSize + truckH) / 2 - 8;

        if (!touching) continue;

        if (e.kind == Kind.bag) {
          items.remove(e);
          kg += 10;
          power = (power + 10).clamp(0, 100).toDouble();
          bagP.play(AssetSource('media-files/pega_sacola.mp3'));
        } else if (!invencible) {
          items.remove(e);
          damages++;
          if (damages > 3) {
            gameOver();
            return;
          }
        }
      }

      items.removeWhere((e) => e.y > areaH);

      if (speechReady && power >= 70 && !invencible && !listening) {
        listening = true;
        speech.listen(
          onResult: (result) {
            if (result.recognizedWords.toLowerCase().contains('reciclar') &&
                power >= 70 &&
                !invencible) {
              speech.stop();
              setState(() {
                invencible = true;
                power = 0;
                invencibleLeft = 10;
              });
              invencT = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (paused || over) return;
                setState(() => invencibleLeft--);
                if (invencibleLeft <= 0) {
                  setState(() => invencible = false);
                  timer.cancel();
                }
              });
            }
          },
        );
      }

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    accelSub = accelerometerEventStream().listen((event) {
      tiltZ = event.z;

      if (over || paused) return;

      if (event.x.abs() < 2) {
        canChangeLane = true;
        return;
      }
      if (!canChangeLane) return;
      canChangeLane = false;

      lane += event.x < 0 ? 1 : -1;

      if (lane < 0 || lane > 2) {
        gameOver();
        return;
      }
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => startApp());
  }

  @override
  void dispose() {
    gameT?.cancel();
    invencT?.cancel();
    speedT?.cancel();
    accelSub?.cancel();
    musicP.dispose();
    bagP.dispose();
    speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.grey.shade700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    VerticalDivider(width: 20),
                    VerticalDivider(width: 20),
                  ],
                ),
              ),
            ),

            for (final e in items)
              Positioned(
                width: itemSize,
                height: itemSize,
                top: e.y,
                left: e.x - itemSize / 2,

                child: e.kind == Kind.bag
                    ? Image.asset('assets/icons/Itens Sacola.png')
                    : e.kind == Kind.hole
                    ? Image.asset('assets/icons/Obstaculos.png')
                    : Image.asset('assets/icons/lixeira.png'),
              ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              width: truckW,
              height: truckH,
              left: laneCenter(lane) - truckW / 2,
              top: areaH - 24 - truckH,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: invencible
                      ? [
                          const BoxShadow(
                            color: Colors.yellowAccent,
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ]
                      : [],
                ),
                child: Image.asset(
                  'assets/icons/caminhão.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: power / 100,
                      minHeight: 20,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$kg Kg",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < damages; i++)
                        const Icon(Icons.heart_broken, color: Colors.white),
                    ],
                  ),
                  if (invencible)
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              value: invencibleLeft / 10,
                              color: Colors.yellowAccent,
                            ),
                          ),
                          Text(
                            invencibleLeft.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() => paused = true);
                      musicP.pause();
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Jogo Pausado"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() => paused = false);
                                musicP.resume();
                              },
                              child: const Text("Continuar"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.pause, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
