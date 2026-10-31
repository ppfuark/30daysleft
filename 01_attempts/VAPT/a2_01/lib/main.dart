import 'package:a2_01/app.dart';
import 'package:a2_01/pages/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.theme,
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
  late final AnimationController animationController1 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 5),
  );
  late final AnimationController animationController2 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  );
  late final AnimationController animationController3 = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 500),
  );

  Future<void> startApp() async {
    await animationController1.forward();
    await animationController2.forward();
    await animationController3.forward();
    await animationController3.reverse();
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
          spacing: 10,
          children: [
            SlideTransition(
              position: Tween(
                begin: Offset(10, 0),
                end: Offset.zero,
              ).animate(animationController2),
              child: ScaleTransition(
                scale: Tween(
                  begin: 1.0,
                  end: 1.2,
                ).animate(animationController3),
                child: Image.asset('assets/ic_launcher.png', height: 200),
              ),
            ),

            AnimatedBuilder(
              animation: animationController1,
              builder: (context, c) {
                return Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideTransition(
                      position: Tween(
                        begin: Offset(0, 0),
                        end: Offset(8.8, 0),
                      ).animate(animationController1),
                      child: Image.asset(
                        'assets/images/motoqueiro-vaptfood.png',
                        height: 100,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: animationController1.value,
                      color: Colors.deepOrange,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                          textAlign: TextAlign.center,
                          "${(animationController1.value * 100).toStringAsFixed(0)}%",
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
