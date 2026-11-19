import 'dart:convert';

import 'package:battery_plus/battery_plus.dart';
import 'package:c1_01/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_widget/home_widget.dart';

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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
      onGenerateInitialRoutes: (initialRoute) {
        if (Uri.parse(initialRoute).host == 'time' ||
            Uri.parse(initialRoute).path.contains('time')) {
          print("AIAIAIAI");

          return [
            MaterialPageRoute(
              builder: (context) => MainPage(
                me: {
                  "cidade": "São Paulo",
                  "data de nascimento": "16/02/2009",
                  "e-mail": "gabriel.melo@senai.sp.br",
                  "escola": "SENAI Brás",
                  "foto": "foto_20.png",
                  "id": 20,
                  "modalidade": "Desenvolvimento de Aplicativos Mobile",
                  "nome": "Gabriel Melo",
                  "perfil": "competidor",
                  "treinamento": [
                    {
                      "data": "01/11/2026",
                      "entrada": "07:21",
                      "saida": "12:00",
                    },
                    {
                      "data": "07/11/2026",
                      "entrada": "08:50",
                      "saida": "11:02",
                    },
                    {
                      "data": "09/11/2026",
                      "entrada": "07:53",
                      "saida": "12:45",
                    },
                    {
                      "data": "11/11/2026",
                      "entrada": "07:34",
                      "saida": "11:51",
                    },
                    {
                      "data": "12/11/2026",
                      "entrada": "08:08",
                      "saida": "12:54",
                    },
                    {
                      "data": "14/11/2026",
                      "entrada": "08:57",
                      "saida": "12:59",
                    },
                    {
                      "data": "16/11/2026",
                      "entrada": "08:14",
                      "saida": "11:53",
                    },
                    {
                      "data": "17/11/2026",
                      "entrada": "08:27",
                      "saida": "11:13",
                    },
                    {
                      "data": "18/11/2026",
                      "entrada": "07:49",
                      "saida": "12:05",
                    },
                    {
                      "data": "19/11/2026",
                      "entrada": "08:27",
                      "saida": "12:47",
                    },
                    {
                      "data": "22/11/2026",
                      "entrada": "08:31",
                      "saida": "12:57",
                    },
                    {
                      "data": "24/11/2026",
                      "entrada": "07:52",
                      "saida": "11:53",
                    },
                    {
                      "data": "28/11/2026",
                      "entrada": "08:29",
                      "saida": "12:03",
                    },
                    {
                      "data": "29/11/2026",
                      "entrada": "07:31",
                      "saida": "12:48",
                    },
                    {
                      "data": "30/11/2026",
                      "entrada": "07:45",
                      "saida": "11:56",
                    },
                  ],
                  "ultimas_avaliacoes": [
                    {"data": "05/08/2026", "nota": 93},
                    {"data": "20/08/2026", "nota": 82},
                    {"data": "15/09/2026", "nota": 85},
                  ],
                },
              ),
            ),
          ];
        }
        print("UIUIUIUI");
        return [MaterialPageRoute(builder: (context) => MyHomePage())];
      },
      routes: {'/home': (context) => MyHomePage()},
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
                        : () async {
                            try {
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
                                final mins =
                                    ((exist.first['treinamento'] ?? []) as List)
                                        .fold(0, (previousValue, element) {
                                          final start =
                                              double.parse(
                                                    element['entrada']
                                                        .toString()
                                                        .split(':')
                                                        .first,
                                                  ) *
                                                  60 +
                                              double.parse(
                                                element['entrada']
                                                    .toString()
                                                    .split(':')
                                                    .last,
                                              );
                                          final end =
                                              double.parse(
                                                    element['saida']
                                                        .toString()
                                                        .split(':')
                                                        .first,
                                                  ) *
                                                  60 +
                                              double.parse(
                                                element['saida']
                                                    .toString()
                                                    .split(':')
                                                    .last,
                                              );

                                          return previousValue +
                                              (start - end).abs().toInt();
                                        });

                                final month = "11/2026";

                                final monthEval =
                                    ((exist.first['ultimas_avaliacoes'] ?? [])
                                            as List)
                                        .where(
                                          (element) => element['data']
                                              .toString()
                                              .endsWith(month),
                                        )
                                        .toList();
                                final aver = monthEval.isEmpty
                                    ? 0
                                    : monthEval.fold(
                                            0,
                                            (previousValue, element) =>
                                                previousValue +
                                                int.parse(
                                                  element['nota'].toString(),
                                                ),
                                          ) /
                                          monthEval.length;

                                await HomeWidget.saveWidgetData(
                                  'name',
                                  "${exist.first['nome']}",
                                );
                                await HomeWidget.saveWidgetData(
                                  'modal',
                                  "${exist.first['modalidade']} ${exist.first['escola']}",
                                );
                                await HomeWidget.saveWidgetData(
                                  'date',
                                  month.toString(),
                                );
                                await HomeWidget.saveWidgetData(
                                  'aver',
                                  aver.round(),
                                );
                                await HomeWidget.saveWidgetData(
                                  'hours',
                                  (mins / 60).round(),
                                );
                                await HomeWidget.saveWidgetData(
                                  'last',
                                  monthEval.isEmpty
                                      ? 0
                                      : int.parse(
                                          monthEval.last['nota'].toString(),
                                        ),
                                );
                                await HomeWidget.updateWidget(
                                  androidName: 'External',
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MainPage(me: exist.first),
                                  ),
                                );
                              }
                            } catch (e) {
                              print(e);
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
