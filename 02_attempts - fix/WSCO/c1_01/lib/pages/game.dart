import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

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

  final name = TextEditingController();
  final age = TextEditingController();

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
            appBar: AppBar(
              leading: Icon(Icons.directions_car),
              title: Text("WSConecta Mini Game"),
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                spacing: 20,
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.tips_and_updates),
                          title: Text("Incline para frente para acelerar"),
                        ),
                        ListTile(
                          leading: Icon(Icons.tips_and_updates),
                          title: Text("Incline para trás para frear"),
                        ),
                        ListTile(
                          leading: Icon(Icons.tips_and_updates),
                          title: Text("Teclado ↑↓←→"),
                        ),
                        ListTile(
                          leading: Icon(Icons.tips_and_updates),
                          title: Text(
                            "Colete medalha para carregar o power-up",
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.tips_and_updates),
                          title: Text(
                            "Sacuda o dispositivo com 70%+ para ativar",
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: name,
                    decoration: InputDecoration(hintText: "Insira seu nome"),
                  ),
                  TextField(
                    controller: age,
                    decoration: InputDecoration(hintText: "Sua idade"),
                    keyboardType: TextInputType.numberWithOptions(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (name.text.isEmpty || age.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Os campos não podem estar vazios.',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }
                      if (int.parse(age.text) < 16) {
                        Fluttertoast.showToast(
                          msg: 'Idade insuficente, por favor, volte no futuro.',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RealGame(name: name.text),
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

class RealGame extends StatefulWidget {
  final String name;

  const RealGame({super.key, required this.name});
  @override
  State<RealGame> createState() => _RealGameState();
}

class Track {
  double x, y;
  bool? medal;

  Track(this.x, this.y, [this.medal]);
}

class _RealGameState extends State<RealGame> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  Future<void> startApp() async {
    try {
      areaH = MediaQuery.of(context).size.height;
      areaW = MediaQuery.of(context).size.width;

      for (var i = 0; i < (areaH / 100).ceil(); i++) {
        tracks.add(Track(0, areaH - i * 100, false));
      }

      tSpeed = Timer.periodic(Duration(seconds: 15), (timer) {
        if (paused) return;

        speed = (speed += 0.2).clamp(5, 15);
      });

      tInvencible = Timer.periodic(Duration(seconds: 1), (timer) {
        if (paused || !invencible || !mounted) return;

        setState(() {
          powerLeft--;
          if (powerLeft <= 0) {
            powerLeft = 10; // reseta para a próxima ativação
            power = 0;
            invencible = false;
          }
        });
      });

      tTicker = Timer.periodic(Durations.medium1, (timer) async {
        if (paused) return;

        distance += speed;

        final top = tracks.map((e) => e.y).reduce(min);

        for (var element in tracks) {
          element.y += speed;

          if ((element.medal ?? false) && element.y < areaH - carH - 50) {
            if (carX > 0 && carX < 100) {
              power = (power + .1).clamp(0, 1.0);
              mdP.play(AssetSource('pegou-medalha.mp3'));
              element.medal = false;
              setState(() {});
            }
          }

          if (element.y > areaH) {
            final c = (1.0 - distance * 0.01).clamp(0.2, 1.0);

            element.y = top - 100 + speed;
            element.medal = Random().nextDouble() < c;
          }
        }
      });

      accelS = accelerometerEventStream().listen((event) {
        if (paused) return;

        if (event.y > 2.0) {
          accel = true;
          speed = (speed + 0.2).clamp(5, 15).toDouble();
        } else if (event.y < -2.0) {
          accel = false;
          speed = (speed - 0.2).clamp(5, 15).toDouble();
        }

        if (accel && event.x.abs() > 2.0 && !invencible) {
          gameOver();
          return;
        }

        setState(() {
          carX = (carX - event.x * 2).clamp(0, areaW - carW).toDouble();
        });

        if (carX > 100) {
          if (!currentOff) {
            currentOff = true;

            if (!invencible) {
              lifes--;
              if (lifes < 0) gameOver();
            }
          }
        } else {
          currentOff = false;
        }
      });

      startSpeech();
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => startApp());
  }

  @override
  void dispose() {
    _controller.dispose();
    bgP.dispose();
    mdP.dispose();
    speechToText.cancel();
    tInvencible?.cancel();
    tTicker?.cancel();
    tSpeed?.cancel();
    accelS?.cancel();
    tSpeech?.cancel();
    speechToText.cancel();
    super.dispose();
  }

  Timer? tSpeech; // campo da classe

  Future<void> startSpeech() async {
    final ok = await speechToText.initialize(
      onError: (e) {}, // erros de timeout/no_match são normais, ignore
    );
    if (!ok) return;

    tSpeech?.cancel();
    tSpeech = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted || paused || over) return;
      if (speechToText.isListening) return;

      speechToText.listen(
        onResult: (result) {
          final text = result.recognizedWords.toLowerCase();
          if (text.contains('mobile') && power >= 0.7 && !invencible) {
            setState(() => invencible = true);
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: 'pt_BR',
          listenFor: Duration(seconds: 3),
          pauseFor: Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
        ),
      );
    });
  }

  void listenSpeech() {
    if (speechToText.isListening || !mounted) return;

    speechToText.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();
        if (text.contains('mobile') && power >= 0.7 && !invencible) {
          setState(() => invencible = true);
          speechToText.stop();
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'pt_BR',
        listenFor: Duration(minutes: 10),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  int get score => switch (distance) {
    > 100 => 1,
    > 150 => 2,
    > 200 => 3,
    > 250 => 4,
    _ => 5,
  };

  final SpeechToText speechToText = SpeechToText();

  void gameOver() {
    if (over) return;
    over = true;
    paused = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < score; i++)
              Icon(Icons.star, color: Colors.amber),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              tInvencible?.cancel();
              tTicker?.cancel();
              tSpeed?.cancel();

              setState(() {
                tracks = [];
                carX = 0;
                speed = 5;
                distance = 0;
                power = 0;
                lifes = 3;
                powerLeft = 10;
                accel = false;
                paused = false;
                currentOff = false;
                invencible = false;
                over = false;
                tSpeech?.cancel();
                speechToText.cancel();
              });
              startApp();
            },
            child: Text('Tentar Novamente!'),
          ),
        ],
      ),
    );
  }

  List<Track> tracks = [];
  double carX = 0, carH = 80, carW = 60;
  double areaW = 0, areaH = 0;
  double speed = 5, distance = 0, power = 0;
  int lifes = 3, powerLeft = 10;

  bool accel = false,
      paused = false,
      currentOff = false,
      invencible = false,
      over = false;

  Timer? tInvencible, tTicker, tSpeed;
  StreamSubscription<AccelerometerEvent>? accelS;

  final AudioPlayer bgP = AudioPlayer()
    ..setReleaseMode(ReleaseMode.loop)
    ..setVolume(0.5)
    ..play(AssetSource('trilha-sonora.mp3'));
  final AudioPlayer mdP = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return loading
        ? Center(
            child: Scaffold(
              body: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/icons/background.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  ...tracks.map(
                    (e) => Positioned(
                      top: e.y,
                      left: e.x,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/icons/rua.png'),
                          ),
                        ),
                        child: e.medal ?? false
                            ? Center(
                                child: Image.asset(
                                  'assets/icons/medalha.png',
                                  width: 50,
                                  height: 50,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),

                  Positioned(
                    top: areaH - carH - 30,
                    left: carX,
                    child: Image.asset(
                      'assets/icons/carro-topdown.png',
                      height: carH,
                      width: carW,
                    ),
                  ),
                  if (invencible)
                    Positioned(
                      top: areaH - carH - 30,
                      left: carX,
                      child: Opacity(
                        opacity: 0.3,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.amber),
                          height: carH,
                          width: carW,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 60,
                    left: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      width: w - 60,
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text("Power: ${(power * 100).toStringAsFixed(0)}%"),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: power,
                              minHeight: 10,
                              color: Colors.blueAccent,
                              backgroundColor: Colors.grey,
                            ),
                          ),
                          for (int i = 0; i < lifes; i++)
                            Icon(Icons.favorite, color: Colors.red),
                          for (int i = 0; i < 3 - lifes; i++)
                            Icon(Icons.heart_broken, color: Colors.red),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                paused = true;
                              });
                              bgP.pause();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Jogo Pausado'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            paused = false;
                                            bgP.resume();
                                          });
                                        },
                                        child: Text('Continuar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.pause),
                          ),
                          if (invencible)
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CircularProgressIndicator(
                                      value: powerLeft / 10,
                                    ),
                                  ),
                                  Center(child: Text(powerLeft.toString())),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
