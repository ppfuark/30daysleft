import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:d1_01/app.dart';
import 'package:d1_01/login.dart';
import 'package:flutter/material.dart';

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
    Battery().onBatteryStateChanged.listen((event) async {
      final b = Battery();
      if (await b.batteryLevel <= 10) {
        showDialog(
          context: key.currentContext!,
          builder: (context) => AlertDialog(
            title: Text('Atenção! Bateria Baixa'),
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
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        showDialog(
          context: key.currentContext!,
          builder: (context) => AlertDialog(
            title: Text('Atenção sem internet'),
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
          off = true;
        });
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.valueNotifier,
      builder: (context, value, child) {
        return MaterialApp(
          navigatorKey: key,
          title: 'Flutter Demo',
          theme: value,
          home: const Login(),
        );
      },
    );
  }
}
