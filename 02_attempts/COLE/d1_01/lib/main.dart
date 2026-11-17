import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:d1_01/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool off = false;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        ScaffoldMessenger.of(key.currentContext!).showSnackBar(
          SnackBar(
            content: Text(
              "Sem conexão com a internet. A autenticação não poderá ser realizada",
            ),
            backgroundColor: Colors.red,
            duration: Duration(days: 99),
          ),
        );
        setState(() {
          off = true;
        });
      } else {
        ScaffoldMessenger.of(key.currentContext!).clearSnackBars();
        setState(() {
          off = true;
        });
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
        colorScheme: .fromSeed(seedColor: Colors.green),
        textTheme: GoogleFonts.poppinsTextTheme(),
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

  bool off = false;

  Future<void> startApp() async {
    try {
      Connectivity().onConnectivityChanged.listen((event) {
        if (event.contains(ConnectivityResult.none)) {
          setState(() {
            off = true;
          });
        } else {
          setState(() {
            off = false;
          });
        }
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

  final pin = TextEditingController();
  int erros = 0;
  bool blocked = false;

  bool obs = true;

  void increment() {
    setState(() {
      erros++;

      if (erros != 3) {
        Fluttertoast.showToast(
          msg: 'Dados de acesso inválidos.',
          backgroundColor: Colors.red,
        );
      }
      if (erros == 3) {
        Fluttertoast.showToast(
          msg: 'Acesso bloqueado, aguarde 10 segundos',
          backgroundColor: Colors.red,
        );
        setState(() async {
          blocked = true;
          await Future.delayed(Duration(seconds: 10));
          blocked = false;
          erros = 0;
        });
      }
    });
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
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(30),
              child: Column(
                spacing: 20,
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  ListTile(
                    title: Text("Bem-vindo ao ColetaJá"),
                    subtitle: Text("Insira seu código para começar."),
                  ),
                  TextField(
                    key: Key('main_pin'),
                    enabled: !blocked,
                    controller: pin,
                    obscureText: obs,
                    decoration: InputDecoration(
                      hintText: "Digite seu PIN",
                      suffixIcon: GestureDetector(
                        onLongPressStart: (details) {
                          setState(() {
                            obs = false;
                          });
                        },
                        onLongPressEnd: (details) {
                          setState(() {
                            obs = true;
                          });
                        },
                        child: Icon(
                          obs ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),

                  ElevatedButton(
                    onPressed: blocked
                        ? null
                        : () {
                            if (pin.text.length < 4) {
                              Fluttertoast.showToast(
                                msg: 'O PIN deve conter 4 dígitos.',
                                backgroundColor: Colors.red,
                              );
                              return;
                            }
                            if (pin.text.length > 4) {
                              Fluttertoast.showToast(
                                msg: 'O PIN não deve exceder 4 dígitos.',
                                backgroundColor: Colors.red,
                              );
                              return;
                            }

                            final exist = users.where(
                              (element) => element['pin_acesso'] == pin.text,
                            );

                            if (exist.isEmpty) {
                              increment();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Menu(me: exist.first),
                                ),
                              );
                            }
                          },
                    child: Text("Entrar"),
                  ),
                  Spacer(),
                  if (off) ...[Icon(Icons.wifi_off)] else Icon(Icons.wifi),
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
    "pin_acesso": "1234",
    "score_persistente": 450,
    "coletas_ids": [
      "COL-0001",
      "COL-0002",
      "COL-0003",
      "COL-0004",
      "COL-0005",
      "COL-0006",
      "COL-0007",
      "COL-0008",
      "COL-0009",
      "COL-0010",
      "COL-0011",
      "COL-0012",
      "COL-0013",
      "COL-0014",
      "COL-0015",
      "COL-0016",
      "COL-0017",
      "COL-0018",
      "COL-0019",
      "COL-0020",
      "COL-0021",
      "COL-0022",
      "COL-0023",
      "COL-0024",
      "COL-0025",
      "COL-0026",
      "COL-0027",
      "COL-0028",
      "COL-0029",
      "COL-0030",
      "COL-0031",
      "COL-0032",
      "COL-0033",
      "COL-0034",
      "COL-0035",
      "COL-0036",
      "COL-0037",
      "COL-0038",
      "COL-0039",
      "COL-0040",
      "COL-0041",
      "COL-0042",
      "COL-0043",
      "COL-0044",
      "COL-0045",
    ],
  },
  {
    "id": 2,
    "nome": "Ana Souza",
    "pin_acesso": "2345",
    "score_persistente": 10,
    "coletas_ids": ["COL-0046"],
  },
  {
    "id": 3,
    "nome": "Carlos Oliveira",
    "pin_acesso": "3456",
    "score_persistente": 5,
    "coletas_ids": ["COL-0047"],
  },
  {
    "id": 4,
    "nome": "Mariana Santos",
    "pin_acesso": "4567",
    "score_persistente": 10,
    "coletas_ids": ["COL-0048"],
  },
  {
    "id": 5,
    "nome": "Pedro Costa",
    "pin_acesso": "5678",
    "score_persistente": 5,
    "coletas_ids": ["COL-0049"],
  },
  {
    "id": 6,
    "nome": "Juliana Almeida",
    "pin_acesso": "6789",
    "score_persistente": 10,
    "coletas_ids": ["COL-0050"],
  },
  {
    "id": 7,
    "nome": "Rafael Pereira",
    "pin_acesso": "7890",
    "score_persistente": 5,
    "coletas_ids": ["COL-0051"],
  },
  {
    "id": 8,
    "nome": "Beatriz Lima",
    "pin_acesso": "8901",
    "score_persistente": 10,
    "coletas_ids": ["COL-0052"],
  },
  {
    "id": 9,
    "nome": "Lucas Rodrigues",
    "pin_acesso": "9012",
    "score_persistente": 5,
    "coletas_ids": ["COL-0053"],
  },
  {
    "id": 10,
    "nome": "Camila Ferreira",
    "pin_acesso": "0123",
    "score_persistente": 10,
    "coletas_ids": ["COL-0054"],
  },
];
