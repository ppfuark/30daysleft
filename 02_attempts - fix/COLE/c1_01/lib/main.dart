import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:c1_01/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  @override
  void initState() {
    super.initState();
    Battery().onBatteryStateChanged.listen((event) async {
      final b = Battery();
      if (await b.batteryLevel <= 20) {
        showDialog(
          context: key.currentContext!,
          builder: (context) => AlertDialog(
            title: Text(
              'Bateria baixa! Retorne ao galpão para recarregar seu celular.',
            ),
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
      }
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: key,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
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

  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

  int errors = 0;
  int left = 10;
  bool blocked = false;
  Timer? timer;

  bool showPass = false;

  void increment() {
    setState(() {
      errors++;
    });

    if (errors >= 3) {
      setState(() {
        blocked = true;
        timer?.cancel();
      });
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          left--;
        });

        if (left <= 0) {
          setState(() {
            blocked = false;
            left = 10;
            errors = 0;
            timer.cancel();
          });
        }
      });
    }
  }

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
              padding: EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  ListTile(
                    title: Text("ColetaJá"),
                    subtitle: Text("Acesse sua conta"),
                  ),
                  ListTile(
                    title: Text("E-mail"),
                    subtitle: TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "Digite seu e-mail",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  if (showPass)
                    ListTile(
                      title: Text("Senha"),
                      subtitle: TextField(
                        controller: pass,
                        obscureText: obs,
                        decoration: InputDecoration(
                          hintText: "Digite sua senha",
                          prefixIcon: Icon(Icons.lock),
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
                  if (blocked) Text("00:${left.toString().padLeft(2, '0')}"),

                  ElevatedButton.icon(
                    onPressed: blocked
                        ? null
                        : () {
                            if (!RegExp(
                              r'^[a-zA-Z0-9\.]+@[a-zA-Z0-9]+\.com\.br$',
                            ).hasMatch(email.text)) {
                              Fluttertoast.showToast(
                                msg:
                                    'E-mail inválido, por favor confira seu e-mail e tente novamente.',
                                backgroundColor: Colors.red,
                              );
                              increment();

                              return;
                            }

                            final exist = users.where(
                              (element) => element['email'] == email.text,
                            );

                            if (showPass) {
                              if (exist.first['senha'] != pass.text) {
                                Fluttertoast.showToast(
                                  msg: 'Senha incorreta.',
                                  backgroundColor: Colors.red,
                                );
                                increment();
                                return;
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MainPage(me: exist.first),
                                  ),
                                );
                              }
                            }

                            if (exist.isNotEmpty) {
                              setState(() {
                                showPass = true;
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainPage(
                                    me: {
                                      "id": users.length + 1,
                                      "nome": email.text
                                          .split("@")
                                          .first
                                          .toUpperCase(),
                                      "email": email.text,
                                      "senha": "password123",
                                      "foto": "joao.png",
                                    },
                                  ),
                                ),
                              );
                              return;
                            }
                          },
                    label: Text("Continuar"),
                    icon: Icon(Icons.arrow_forward),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Novo por aqui?"),
                      TextButton(
                        onPressed: () {},
                        child: Text("Crie uma conta"),
                      ),
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
