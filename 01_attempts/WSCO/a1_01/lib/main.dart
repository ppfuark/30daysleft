import 'package:a1_01/login.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

  final ft = FToast();

  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((event) async {
      if (event.contains(ConnectivityResult.none)) {
        // ignore: use_build_context_synchronously
        ft.init(key.currentState!.context);

        ft.showToast(
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [Icon(Icons.wifi_off), Text("Sem conexão com internet")],
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
    return MaterialApp(
      navigatorKey: key,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.inriaSansTextTheme(),
        colorScheme: .fromSeed(seedColor: Color(0xff003764)),
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
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  );

  Future<void> startApp() async {
    await animationController.forward();
    await animationController.reverse();
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
        decoration: BoxDecoration(color: Color(0xff8ae2d1)),
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0).animate(animationController),
              child: Image.asset('assets/ic_launcher.png'),
            ),
          ],
        ),
      ),
    );
  }
}
