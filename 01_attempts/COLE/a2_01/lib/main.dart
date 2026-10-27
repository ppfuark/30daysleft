import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/login.dart';
import 'package:a2_01/main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  late final AnimationController animationController1 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  );
  late final AnimationController animationController2 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 3),
  );
  late final AnimationController animationController3 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 2),
  );
  late final AnimationController animationController4 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  );

  Future<void> startApp() async {
    await animationController1.forward();
    await animationController2.forward();
    await animationController3.forward();
    await animationController4.forward();

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://192.168.56.1:8080/api/v1/coletas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      });
    } else {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => startApp());
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: AnimatedBuilder(
        animation: animationController3,
        builder: (context, c) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: ColorTween(
                begin: Colors.white,
                end: Color(0xFF0d3321),
              ).animate(animationController3).value,
            ),
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 30,
              children: [
                AnimatedBuilder(
                  animation: animationController2,
                  builder: (context, c) {
                    final p = TweenSequence([
                      TweenSequenceItem(
                        tween: Tween<Offset>(
                          begin: Offset(0.0, 0.0),
                          end: Offset(0.0, -150),
                        ),
                        weight: 1,
                      ),
                      TweenSequenceItem(
                        tween: Tween<Offset>(
                          begin: Offset(0.0, -150),
                          end: Offset(-150, -150),
                        ),
                        weight: 1,
                      ),
                      TweenSequenceItem(
                        tween: Tween<Offset>(
                          begin: Offset(-150, -150),
                          end: Offset(150, -150),
                        ),
                        weight: 1,
                      ),
                      TweenSequenceItem(
                        tween: Tween<Offset>(
                          begin: Offset(150, -150),
                          end: Offset(150, 0.0),
                        ),
                        weight: 1,
                      ),
                      TweenSequenceItem(
                        tween: Tween<Offset>(
                          begin: Offset(150, 0.0),
                          end: Offset.zero,
                        ),
                        weight: 1,
                      ),
                    ]).animate(animationController2);

                    return Transform.translate(
                      offset: Offset(p.value.dx, p.value.dy),
                      child: Image.asset('assets/ic_launcher.png'),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: animationController4,
                  builder: (context, c) {
                    return Opacity(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(animationController4).value,
                      child: Column(
                        children: [
                          Text(
                            "Coleta Já",
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                          CircularProgressIndicator(color: Colors.white),
                        ],
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: animationController1,
                  builder: (context, c) {
                    return Opacity(
                      opacity: Tween<double>(
                        begin: 1.0,
                        end: 0.0,
                      ).animate(animationController1).value,
                      child: Text("Preparando"),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
