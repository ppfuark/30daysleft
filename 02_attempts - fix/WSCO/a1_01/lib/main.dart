import 'package:a1_01/pages/login.dart';
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
  bool off = false;

  late final fl = FToast()..init(key.currentState!.context);

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        fl.showToast(
          gravity: ToastGravity.BOTTOM,
          toastDuration: Duration(seconds: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/wifi-off.png', height: 50),
              Text("Sem conexão com internet"),
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: key,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Color(0xff003764)),
        textTheme: GoogleFonts.inriaSansTextTheme(),
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
  Future<void> startApp() async {
    try {
      setState(() {
        loading = false;
      });

      await _controller.forward();
      await _controller.reverse();

      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
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
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(color: Color(0xff0084ad)),
              padding: EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _controller,
                    child: Image.asset('assets/ic_launcher.png', height: 100),
                  ),
                ],
              ),
            ),
          );
  }
}
