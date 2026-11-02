import 'package:battery_plus/battery_plus.dart';
import 'package:c1_01/app.dart';
import 'package:c1_01/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  Future<void> startApp() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      index++;
    });
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      index++;
    });
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      index++;
    });
    await Future.delayed(Duration(seconds: 3));
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
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
            SizedBox(
              height: h * .4,
              child: Stack(
                children: [
                  ...[0, 1, 2, 3].map(
                    (e) => Positioned(
                      left: e % 2 == 0 ? null : 100,
                      right: e % 2 != 0 ? null : 100,
                      top: e * 100,
                      child: Icon(
                        Icons.circle,
                        color: index == e ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
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
