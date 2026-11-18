import 'dart:convert';

import 'package:a1_01/main_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepOrangeAccent),
        textTheme: GoogleFonts.dosisTextTheme(),
      ),
      home: const MyHomePage(),
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
  final email2 = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

  Future<void> startApp() async {
    try {
      _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 2),
      );

      setState(() {
        loading = false;
      });

      _controller.forward();
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

  bool off = false;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sem conexão'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Ok!'),
              ),
            ],
          ),
        );
        setState(() {
          off = true;
        });
      } else {
        setState(() {
          off = false;
        });
      }
    });
    startApp();
  }

  bool loading2 = false;

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
            body: SlideTransition(
              position: Tween(
                begin: Offset(-1, 0),
                end: Offset.zero,
              ).animate(_controller),
              child: Container(
                width: w,
                height: h,
                decoration: BoxDecoration(),
                padding: EdgeInsets.all(0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Image.asset('assets/ic_launcher.png'),
                    ListTile(
                      title: Text("Bem-vindo de volta"),
                      subtitle: Text(
                        "Sabores frescos a apenas um login de distância.",
                      ),
                    ),
                    ListTile(
                      title: Text("E-mail"),
                      subtitle: TextField(
                        controller: email,
                        decoration: InputDecoration(
                          hintText: "name@example.com",
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text("Senha"),
                      trailing: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: ListTile(
                                  title: Text("E-mail"),
                                  subtitle: TextField(
                                    controller: email2,
                                    decoration: InputDecoration(
                                      hintText: "Digite seu e-mail",
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (!RegExp(
                                        r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+$',
                                      ).hasMatch(email2.text)) {
                                        Fluttertoast.showToast(
                                          msg: 'E-mail no formato inválido.',
                                          backgroundColor: Colors.red,
                                        );
                                        return;
                                      }

                                      final res = await http.post(
                                        Uri.parse(
                                          'http://10.109.66.126:3000/auth/forgot-password',
                                        ),
                                        headers: {
                                          'Content-Type': 'application/json',
                                        },
                                        body: jsonEncode({
                                          "email": email2.text,
                                        }),
                                      );
                                      if (res.statusCode == 200) {
                                        Fluttertoast.showToast(
                                          msg: 'Link enviado.',
                                          backgroundColor: Colors.green,
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'E-mail não cadastrado',
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                                    child: Text("Resetar Senha"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text("Esqueceu?"),
                      ),
                      subtitle: TextField(
                        controller: pass,
                        obscureText: obs,
                        obscuringCharacter: "▪",
                        decoration: InputDecoration(
                          hintText: "Digite sua senha",
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
                    ),
                    if (off) Icon(Icons.wifi_off),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final share = await SharedPreferences.getInstance();
                          final t = share.getString('token') ?? '';

                          if (off) {
                            Fluttertoast.showToast(
                              msg: 'Sem conexão com internet.',
                              backgroundColor: Colors.red,
                            );
                            return;
                          }
                          setState(() {
                            loading2 = true;
                          });
                          final res = await http.post(
                            Uri.parse('http://10.109.66.126:3000/auth/login/'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              "email": email.text,
                              "password": pass.text,
                            }),
                          );
                          final json = jsonDecode(res.body);
                          if (res.statusCode == 200) {
                            share.setString('token', json['token']);
                            setState(() {});
                            await Future.delayed(Duration(seconds: 1));
                            setState(() {
                              loading2 = false;
                            });
                            await _controller.reverse();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainPage(),
                              ),
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Dados de acesso inválidos',
                              backgroundColor: Colors.red,
                            );
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
                      child: loading2
                          ? CircularProgressIndicator()
                          : Text("ENTRAR"),
                    ),
                    Text("OU"),
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: Text("ENTRAR COM BIOMETRIA"),
                      icon: Icon(Icons.fingerprint),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
