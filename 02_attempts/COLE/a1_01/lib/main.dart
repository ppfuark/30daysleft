import 'dart:async';

import 'package:a1_01/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  int index = 0;
  bool loading = true;
  Future<void> startApp() async {
    try {
      Timer.periodic(Durations.extralong4, (timer) {
        setState(() {
          index++;
        });
      });

      setState(() {
        loading = false;
      });

      await Future.delayed(Duration(seconds: 6));

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
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..forward()
          ..repeat(reverse: true);

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
            body: AnimatedBuilder(
              animation: _controller,
              builder: (context, c) {
                return Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: ColorTween(
                      begin: Colors.white,
                      end: Colors.green,
                    ).animate(_controller).value,
                  ),
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RotationTransition(
                            turns: _controller,
                            child: Icon(size: 60, Icons.recycling),
                          ),
                          SlideTransition(
                            position: Tween(
                              begin: Offset.zero,
                              end: Offset(0, -.5),
                            ).animate(_controller),
                            child: Icon(size: 60, Icons.eco),
                          ),
                        ],
                      ),
                      Text(
                        "ColetaJá",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Use a tecnologia a favor do planeta: transforme seu celular em uma ferramenta de sustentabilidade",
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ...[0, 1, 2].map(
                            (e) => Icon(
                              Icons.circle,
                              color: index % 3 >= e
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
  }
}
