import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:c1_01/main_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

  bool low = false;

  void startApp() {
    Battery().onBatteryStateChanged.listen((event) async {
      final b = Battery();
      final bL = await b.batteryLevel;

      if (bL <= 20) {
        print("baixo");
        showDialog(
          context: key.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: Text(
                "Bateria baixa! Retorne ao galpão para recarregar seu celular.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK!"),
                ),
              ],
            );
          },
        );
        setState(() {
          low = true;
        });
      } else {
        print("nah");
        setState(() {
          low = false;
        });
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.green)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int erros = 0;
  int blockLeft = 10;
  bool blocked = false;
  Timer? timer;

  bool showPass = false;

  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

  Future<void> startApp() async {
    return;
  }

  void increment() {
    Fluttertoast.showToast(
      msg: 'Senha incorreta.',
      backgroundColor: Colors.red,
    );
    setState(() {
      erros++;
      if (erros >= 3) {
        Fluttertoast.showToast(
          msg: 'Máximo de tentativas inválidas, aguarde e tente novamente.',
          backgroundColor: Colors.red,
        );

        setState(() {
          blocked = true;
          timer = Timer.periodic(Duration(seconds: 1), (timer) {
            setState(() {
              blockLeft--;
              if (blockLeft <= 0) {
                setState(() {
                  timer.cancel();
                  blockLeft = 10;
                  blocked = false;
                  erros = 0;
                });
              }
            });
          });
        });
      }
    });
  }

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
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Image.asset('assets/ic_launcher.jpg'),
            Text("Acesse sua conta"),
            TextField(
              enabled: !blocked,
              controller: email,
              decoration: InputDecoration(hintText: "E-mail"),
            ),

            if (showPass)
              TextField(
                controller: pass,
                enabled: !blocked,
                obscureText: obs,
                decoration: InputDecoration(
                  hintText: "Senha",
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obs = !obs;
                      });
                    },
                    icon: Icon(obs ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),

            if (blocked) Text("00:${blockLeft.toString().padLeft(2, '0')}s"),

            ElevatedButton.icon(
              onPressed: blocked
                  ? null
                  : () {
                      if (!RegExp(r'^[a-zA-Z0-9\.]+@[a-zA-Z0-9]+\.com\.br$')
                          .hasMatch(email.text)) {
                        Fluttertoast.showToast(
                          msg: 'E-mail inválido, por favor, confira seu e-mail e tente novamente.',
                          backgroundColor: Colors.red,
                        );
                        increment();
                        return;
                      }
                      final exist = users.where(
                        (element) => element['email'] == email.text,
                      );

                      if (exist.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Usuário adicionado com o a senha padrão "password123".',
                          backgroundColor: Colors.green,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(
                              me: {
                                "id": users.length + 1,
                                "nome": email.text
                                    .split('@')
                                    .first
                                    .replaceAll('.', " ")
                                    .toUpperCase(),
                                "email": email.text,
                                "senha": "password123",
                                "foto": "default.png",
                              },
                            ),
                          ),
                        );
                      } else {
                        if (showPass) {
                          if (exist.first['senha'] == pass.text) {
                            Fluttertoast.showToast(
                              msg: 'Credencias válidas.',
                              backgroundColor: Colors.green,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainPage(me: exist.first),
                              ),
                            );
                          } else {
                            increment();
                          }
                        } else {
                          setState(() {
                            showPass = true;
                          });
                        }
                      }
                    },
              label: Text("Continuar"),
              icon: Icon(Icons.arrow_forward),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Novo por aqui?"),
                TextButton(onPressed: () {}, child: Text("Crie uma conta")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

final users = [
  {
    "id": 1,
    "nome": "João Silva",
    "email": "joao.silva@coletaja.com.br",
    "senha": "password123",
    "foto": "joao.png",
  },
  {
    "id": 2,
    "nome": "Maria Oliveira",
    "email": "maria.oliveira@coletaja.com.br",
    "senha": "senhaSegura456",
    "foto": "maria.png",
  },
  {
    "id": 3,
    "nome": "Carlos Souza",
    "email": "carlos.souza@empresa.com.br",
    "senha": "carlos789",
    "foto": "carlos.png",
  },
  {
    "id": 4,
    "nome": "Ana Costa",
    "email": "ana.costa@ongverde.com.br",
    "senha": "eco2026",
    "foto": "ana.png",
  },
  {
    "id": 5,
    "nome": "Lucas Almeida",
    "email": "lucas.almeida@coletaja.com.br",
    "senha": "lucas_admin",
    "foto": "lucas.png",
  },
];
