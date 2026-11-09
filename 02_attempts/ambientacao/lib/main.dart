import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
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
  bool off = false;
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        showDialog(
          context: key.currentContext!,
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
          off = true;
        });
      }
    });

    startApp();
  }

  Future<void> startApp() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  WebSocket? socket;
  bool connected = false;
  Future<void> initWeSock() async {
    socket = await WebSocket.connect('ws://');
    socket?.listen(
      (event) {
        setState(() {
          connected = true;
        });
        final data = jsonDecode(event);
        print(data);
      },
      onDone: () {
        setState(() {
          connected = false;
        });
      },
      onError: () {
        setState(() {
          connected = false;
        });
      },
    );
  }

  Future<void> startApp() async {}

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
              padding: EdgeInsets.all(0),
              child: Column(children: []),
            ),
          );
  }
}
