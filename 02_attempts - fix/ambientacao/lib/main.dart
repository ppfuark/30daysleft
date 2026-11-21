import 'dart:async';
import 'dart:convert';

import 'package:ambientacao/app.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final key = GlobalKey<NavigatorState>();
  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        showDialog(
          context: key.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: Text('Sem conexão'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK!'),
                ),
              ],
            );
          },
        );
      }
    });
    Battery().onBatteryStateChanged.listen((event) async {
      final b = Battery();
      if (await b.batteryLevel <= 10) {
        showDialog(
          context: key.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: Text('Bateria-Baixa'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK!'),
                ),
              ],
            );
          },
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.theme,
      builder: (context, value, child) {
        return MaterialApp(
          navigatorKey: key,
          title: 'Flutter Demo',
          theme: value,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List data = [];

  Future<void> startApp() async {
    try {
      try {
        final share = await SharedPreferences.getInstance();
        final token = share.getString('token') ?? '';
        final get = await http
            .get(
              Uri.parse('https://api.restful-api.dev/objects'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(Duration(seconds: 10));
        final jsonget = jsonDecode(get.body);
        if (get.statusCode == 200) {
          setState(() {
            data = jsonget;
          });
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Erro na busca GET: ${get.body}'),
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
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro na busca GET: $e'),
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
      }

      try {
        final share = await SharedPreferences.getInstance();
        final token = share.getString('token') ?? '';
        final post = await http
            .post(
              Uri.parse('https://api.restful-api.dev/objects'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                "name": "Apple MacBook Pro 16",
                "data": {
                  "year": 2019,
                  "price": 1849.99,
                  "CPU model": "Intel Core i9",
                  "Hard disk size": "1 TB",
                },
              }),
            )
            .timeout(Duration(seconds: 10));
        final jsonpost = jsonDecode(post.body);

        if (post.statusCode == 200) {
          setState(() {
            data.add(jsonpost);
          });
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Erro no post: ${post.body}'),
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
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro no post: $e'),
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
      }

      Fluttertoast.showToast(msg: '', backgroundColor: Colors.red);
      Fluttertoast.showToast(msg: '', backgroundColor: Colors.green);

      await awesomeNotifications.requestPermissionToSendNotifications();
      await awesomeNotifications.requestPermissionToSendNotifications();
      await awesomeNotifications.requestPermissionToSendNotifications();

      awesomeNotifications.initialize(null, [
        NotificationChannel(
          channelKey: 'default',
          channelName: 'default',
          channelDescription: 'default',
          importance: NotificationImportance.High,
        ),
      ]);

      awesomeNotifications.createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'defalt',
          title: 'Bom-dia',
          body: DateTime.now().toString(),
        ),
      );

      setState(() {
        loading = false;
        setState(() {});
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro ao inciar a Widget: $e'),
          actions: [TextButton(onPressed: () {}, child: Text('OK!'))],
        ),
      );
    }
  }

  bool recording = false;
  String? recordingPath;
  Timer? recordingTimer;
  int duration = 0;
  late final FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder()
    ..openRecorder();
  Future<void> toogleRecord() async {
    try {
      if (recording) {
        setState(() {
          recording = false;
        });
        final path = await flutterSoundRecorder.stopRecorder();
        recordingTimer?.cancel();
        if (path != null) {
          setState(() {
            audios.add({
              'path': recordingPath,
              'maxDuration': duration,
              'name': recordingPath!
                  .toString()
                  .split('/')
                  .last
                  .replaceAll('.aac', '')
                  .toUpperCase(),
            });
            print(audios.last);
            recordingPath = null;
            duration = 0;
          });
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
        await flutterSoundRecorder.startRecorder(
          codec: Codec.aacADTS,
          toFile: file,
        );
        recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            duration++;
          });
        });
        setState(() {
          recordingPath = file;
          recording = true;
        });
      }
    } catch (e) {
      setState(() {
        recording = false;
        recordingPath = null;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro ao Iniciar gravação'),
            content: Text('Permission?: $e'),
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
    }
  }

  bool listening = false;
  String? listeningPath;
  bool is2x = false;
  int currentPosition = 0;
  late final AudioPlayer audioPlayer = AudioPlayer()
    ..onDurationChanged.listen((event) {
      setState(() {
        setState(() {
          currentPosition = event.inSeconds;
        });
      });
    })
    ..onPlayerComplete.listen((event) {
      setState(() {
        listening = false;
        currentPosition = 0;
        listeningPath = null;
      });
    });
  Future<void> toogleListening() async {
    if (listening) {
      await audioPlayer.stop();
      setState(() {
        listening = false;
        listeningPath = null;
      });
    } else {
      await audioPlayer.stop();
      await audioPlayer.setPlaybackRate(is2x ? 2 : 1);
      await audioPlayer.play(DeviceFileSource(listeningPath ?? ''));
    }
  }

  final AwesomeNotifications awesomeNotifications = AwesomeNotifications();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..forward();
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List audios = [];

  @override
  Widget build(BuildContext context) {
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
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final bio = await LocalAuthentication().authenticate(
                            localizedReason: "Bio",
                            biometricOnly: true,
                          );

                          if (bio) {
                            Fluttertoast.showToast(
                              msg: 'Success',
                              backgroundColor: Colors.green,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Error',
                              backgroundColor: Colors.red,
                            );
                          }
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: 'Erro bio: $e',
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: Text("Test Bio"),
                    ),
                    ListTile(
                      title: Text("Tema"),
                      trailing: Switch(
                        value: App.theme.value == App.dark,
                        onChanged: (value) {
                          setState(() {
                            App.toogle();
                          });
                        },
                      ),
                    ),
                    ...audios.map(
                      (e) => ListTile(
                        leading: IconButton(
                          onPressed: () {
                            setState(() {
                              listeningPath = e['path'];
                              listening = false;
                              toogleListening();
                            });
                          },
                          icon: Icon(
                            listeningPath == e['path'] && listening
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                        title: Text(e['name'].toString()),
                        subtitle: SizedBox(
                          width: double.infinity,

                          child: Slider(
                            min: 0.0,
                            max: e['maxDuration'].toDouble(),
                            value: e['path'] == listeningPath
                                ? (currentPosition / e['maxDuration'])
                                      .toDouble()
                                : 0.0,
                            onChanged: (value) {
                              audioPlayer.seek(
                                Duration(seconds: value.round()),
                              );
                              setState(() {});
                            },
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              is2x = !is2x;
                            });
                          },
                          icon: Text(is2x ? "2x" : "1x"),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text("Record here"),
                      trailing: IconButton(
                        onPressed: () {
                          toogleRecord();
                        },
                        icon: Icon(recording ? Icons.stop : Icons.mic),
                      ),
                    ),
                    ...data.map(
                      (e) => ListTile(title: Text(e['name'].toString())),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
