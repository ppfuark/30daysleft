import 'dart:async';
import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
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
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.theme,
      builder: (context, value, child) {
        return MaterialApp(
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

  bool bio = false;

  bool blocked = false;
  Timer? timer;
  int erros = 0;
  int left = 10;

  void increment() {
    setState(() {
      erros++;
    });

    Fluttertoast.showToast(
      msg: 'Credenciais inválidas! Revise seus dados e tente novamente.',
      backgroundColor: Colors.red,
    );

    if (erros >= 3) {
      Fluttertoast.showToast(
        msg: 'Login Bloqueado! Tente novamente em 10 segundos.',
        backgroundColor: Colors.red,
      );
      setState(() {
        blocked = true;
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            left--;
          });

          if (left <= 0) {
            timer.cancel();
            blocked = false;
            left = 10;
            erros = 0;
          }
        });
      });
    }
  }

  Future<void> startApp() async {
    try {
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/curtidas'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        if (res.statusCode == 200) {
          setState(() {
            bio = true;
          });
        } else {
          setState(() {
            bio = false;
          });
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro ao realizar get: $e'),
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
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      "Bem-vindo ao WSConecta",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Uma comunidade para a maior competicão de educação profissional do mundo!",
                    ),
                  ),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(hintText: "E-mail"),
                  ),
                  TextField(
                    obscureText: obs,
                    controller: pass,
                    decoration: InputDecoration(
                      hintText: "Senha",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obs = !obs;
                          });
                        },
                        icon: Icon(
                          obs ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Você deseja realmente sair?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      SystemNavigator.pop();
                                    },
                                    child: Text('Sim'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Não'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text("Sair"),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final share = await SharedPreferences.getInstance();
                        final t = share.getString('token') ?? '';
                        final res = await http.post(
                          Uri.parse('http://10.109.66.126:3000/auth/login'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $t',
                          },
                          body: jsonEncode({
                            'email': email.text,
                            'password': pass.text,
                          }),
                        );
                        final json = jsonDecode(res.body);
                        if (res.statusCode == 200) {
                          final share = await SharedPreferences.getInstance();
                          await share.setString('token', json['token']);

                          setState(() {});
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MainPage()),
                          );
                        } else {
                          increment();
                        }
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Erro ao realizar post: $e'),
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
                    },
                    child: Text("Entrar"),
                  ),
                  Text("ou"),
                  ElevatedButton.icon(
                    onPressed: !bio
                        ? null
                        : () async {
                            final auth = await LocalAuthentication()
                                .authenticate(
                                  localizedReason: 'Biometria',
                                  biometricOnly: true,
                                );
                            if (auth) {
                            } else {}
                          },
                    label: Text("Entrar com Biometria"),
                    icon: Icon(Icons.fingerprint),
                  ),
                ],
              ),
            ),
          );
  }
}
