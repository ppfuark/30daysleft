import 'package:a2_01/app.dart';
import 'package:a2_01/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.valueNotifier,
      builder: (context, value, child) {
        return MaterialApp(
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller1;
  late AnimationController _controller2;
  bool loading = true;
  Future<void> startApp() async {
    try {
      setState(() {
        loading = false;
      });
      await _controller.forward();
      await _controller1.forward();
      await _controller2.forward();
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
      duration: Duration(seconds: 5),
    );
    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
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
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 0.0, end: 1.0).animate(_controller2),
                    child: Image.asset('assets/ic_launcher.png'),
                  ),
                  SlideTransition(
                    position: Tween(
                      begin: Offset(15, 0),
                      end: Offset.zero,
                    ).animate(_controller1),
                    child: Text(
                      "VaptFood",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, c) {
                      return SizedBox(
                        width: w * .7,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SlideTransition(
                              position: Tween(
                                begin: Offset(-3.5, 0),
                                end: Offset(3.5, 0),
                              ).animate(_controller),
                              child: Image.asset(
                                height: 100,
                                'assets/images/motoqueiro-vaptfood.png',
                              ),
                            ),
                            LinearProgressIndicator(
                              value: _controller.value,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.deepOrangeAccent,
                            ),
                            Text(
                              "${(_controller.value * 100).toStringAsFixed(0)}%",
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
