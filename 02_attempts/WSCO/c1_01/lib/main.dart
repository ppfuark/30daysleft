import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:c1_01/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
      if (await b.batteryLevel <= 15) {
        showDialog(
          context: key.currentContext!,
          builder: (context) => AlertDialog(
            title: Text('Bateria baixa, carregue seu dispositivo!'),
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
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: key,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.inriaSansTextTheme(),
      ),

      debugShowCheckedModeBanner: false,
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
  final pass = TextEditingController();
  bool obs = true;

  int erros = 0;
  bool blocked = false;

  Future<void> increment() async {
    if (blocked) return;

    Fluttertoast.showToast(
      msg: 'Usuário/Senha inválidos!',
      backgroundColor: Colors.red,
    );
    setState(() {
      erros++;
    });

    if (erros >= 3) {
      Fluttertoast.showToast(
        msg: 'Login bloqueado: aguarde 30 segundos!',
        backgroundColor: Colors.red,
      );
      setState(() {
        blocked = true;
      });

      await Future.delayed(Duration(seconds: 30));
      setState(() {
        blocked = false;
        erros = 0;
      });
    }
  }

  List users = [];

  Future<void> startApp() async {
    try {
      final raw = await rootBundle.loadString('assets/lista_de_usuarios.json');
      final json = jsonDecode(raw);
      setState(() {
        users = json;
      });
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
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  Text("Login"),
                  TextField(
                    enabled: !blocked,
                    controller: email,
                    decoration: InputDecoration(hintText: "Usuário"),
                  ),
                  TextField(
                    enabled: !blocked,
                    controller: pass,
                    obscureText: obs,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
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
                      hintText: "Senha",
                      helperText: 'Data de nascimento sem "/"',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: blocked
                        ? null
                        : () {
                            final exist = users.where(
                              (element) =>
                                  element['e-mail'] == email.text &&
                                  element['data de nascimento']
                                          .toString()
                                          .replaceAll('/', '') ==
                                      pass.text,
                            );

                            if (exist.isEmpty) {
                              increment();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainPage(me: exist.first),
                                ),
                              );
                            }
                          },
                    child: Text("Acessar"),
                  ),
                  ElevatedButton(
                    onPressed: blocked ? null : () {},
                    child: Text("Cadastre-se"),
                  ),
                  Text("ou entre com"),
                  FaIcon(FontAwesomeIcons.google),
                ],
              ),
            ),
          );
  }
}
