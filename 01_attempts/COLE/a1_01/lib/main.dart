import 'dart:async';

import 'package:a1_01/pages/login.dart';
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
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
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
  int index = 0;

  late final AnimationController animationController1 =
      AnimationController(vsync: this, duration: Duration(milliseconds: 800))
        ..forward()
        ..repeat(reverse: false);
  late final AnimationController animationController2 =
      AnimationController(vsync: this, duration: Duration(milliseconds: 800))
        ..forward()
        ..repeat(reverse: true);
  late final AnimationController animationControlle3 = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 5000),
  );

  Future<void> startApp() async {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        index++;
      });
    });

    await animationControlle3.forward();
    await Future.delayed(Duration(seconds: 1));

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
      body: AnimatedBuilder(
        animation: animationControlle3,
        builder: (context, c) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorTween(
                    begin: Colors.white,
                    end: const Color.fromARGB(255, 116, 216, 120),
                  ).animate(animationControlle3).value!,
                  ColorTween(
                    begin: Colors.white,
                    end: const Color.fromARGB(255, 4, 66, 6),
                  ).animate(animationControlle3).value!,
                ],
                begin: AlignmentGeometry.topLeft,
                end: AlignmentGeometry.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 30,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RotationTransition(
                      turns: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(animationController1),
                      child: Icon(Icons.recycling),
                    ),
                    SlideTransition(
                      position: Tween(
                        begin: Offset.zero,
                        end: Offset(0, -1),
                      ).animate(animationController2),
                      child: Icon(Icons.eco),
                    ),
                  ],
                ),
                Text("Coleta Já"),
                Text(
                  "Use a tecnologia a favor do planeta: transforme seu celular em uma ferramenta de sustentabilidade",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 5,
                  children: [
                    ...[0, 1, 2].map(
                      (e) => Icon(
                        Icons.circle,
                        color: index % 3 >= e
                            ? Colors.green
                            : Colors.grey.shade200,
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
