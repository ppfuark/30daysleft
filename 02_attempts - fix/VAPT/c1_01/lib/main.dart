import 'dart:math';

import 'package:battery_plus/battery_plus.dart';
import 'package:c1_01/app.dart';
import 'package:c1_01/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    Battery().onBatteryStateChanged.listen((event) async {
      final b = Battery();

      if (await b.batteryLevel < 10) {
        showDialog(
          context: key.currentContext!,
          builder: (context) => AlertDialog(
            title: Text("Bateria-Baixa"),
            content: Image.asset('assets/ic_launcher.png'),
          ),
        );
      }
    });

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: App.theme,
      builder: (context, theme, child) {
        return MaterialApp(
          theme: theme,
          builder: (context, child) {
            if (!App.cont) return child!;
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                54.2,
                182.4,
                18.4,
                0,
                -32640,
                54.2,
                182.4,
                18.4,
                0,
                -32640,
                54.2,
                182.4,
                18.4,
                0,
                -32640,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: child!,
            );
          },
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

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  Future<void> startApp() async {
    final share = await SharedPreferences.getInstance();
    final time = share.getBool('first') ?? false ? 2500 : 1250;

    for (var i = 0; i < 3; i++) {
      await Future.delayed(Duration(milliseconds: time));
      setState(() {
        index++;
      });
    }
    await Future.delayed(Duration(milliseconds: time));
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  List colors = [
    Colors.amber,
    Colors.orange,
    Colors.red.shade300,
    Colors.red.shade900,
  ];

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
            SizedBox(
              height: h * .4,
              child: LayoutBuilder(
                builder: (context, c) {
                  // centro de cada bolinha (ícone tem 24px, então +12)
                  final pontos = [0, 1, 2, 3]
                      .map(
                        (e) => Offset(
                          e % 2 == 0 ? c.maxWidth - 100 - 12 : 100 + 12,
                          e * 100 + 12,
                        ),
                      )
                      .toList();

                  return Stack(
                    children: [
                      // linhas primeiro, para ficarem atrás das bolinhas
                      for (var i = 0; i < 3; i++)
                        linha(
                          pontos[i],
                          pontos[i + 1],
                          index > i ? colors[index] : Colors.grey.shade300,
                        ),

                      for (var e = 0; e < 4; e++)
                        Positioned(
                          left: pontos[e].dx - 12,
                          top: pontos[e].dy - 12,
                          child: Icon(
                            Icons.circle,
                            color: index >= e ? colors[index] : Colors.grey,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Divider(),
            Text(steps[index]['description'].toString()),
          ],
        ),
      ),
    );
  }
}

Widget linha(Offset a, Offset b, Color cor) {
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  final comprimento = sqrt(dx * dx + dy * dy);
  final angulo = atan2(dy, dx);

  return Positioned(
    left: a.dx,
    top: a.dy,
    child: Transform.rotate(
      angle: angulo,
      alignment: Alignment.topLeft, // gira em volta do ponto inicial
      child: Container(width: comprimento, height: 4, color: cor),
    ),
  );
}

final steps = [
  {
    "step": 1,
    "title": "Nova Solicitação",
    "description": "O motoboy recebe uma nova solicitação de entrega.",
  },
  {
    "step": 2,
    "title": "Coleta no Estabelecimento",
    "description": "O motoboy coleta o pedido no restaurante.",
  },
  {
    "step": 3,
    "title": "A Caminho",
    "description": "O motoboy está a caminho do endereço do cliente.",
  },
  {
    "step": 4,
    "title": "Entrega Finalizada",
    "description": "O pedido é entregue e finalizado com sucesso.",
  },
];
