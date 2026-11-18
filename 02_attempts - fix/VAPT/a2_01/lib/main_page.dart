import 'package:a2_01/login.dart';
import 'package:a2_01/pages/delivery.dart';
import 'package:a2_01/pages/home.dart';
import 'package:a2_01/pages/orders.dart';
import 'package:a2_01/pages/profile.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  Future<void> startApp() async {
    try {
      setState(() {
        loading = false;
      });
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
    _controller = AnimationController(vsync: this);
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final pages = [Home(), Orders(), Delivery(), Profile()];

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
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        spacing: 10,
                        children: [
                          Image.asset('assets/ic_launcher.png'),
                          Text("Logotipo"),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                index = 0;
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: index == 0 ? Border.all() : null,
                              ),
                              child: Center(
                                child: Icon(Icons.bar_chart, size: 60),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                index = 1;
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: index == 1 ? Border.all() : null,
                              ),
                              child: Center(
                                child: Icon(Icons.assignment, size: 60),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                index = 2;
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: index == 2 ? Border.all() : null,
                              ),
                              child: Center(
                                child: Icon(Icons.bike_scooter, size: 60),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                index = 3;
                              });
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: index == 3 ? Border.all() : null,
                              ),
                              child: Center(
                                child: Icon(Icons.person, size: 60),
                              ),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 100,
                              height: 100,

                              child: Center(
                                child: Icon(Icons.logout, size: 60),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 5, child: pages[index]),
                ],
              ),
            ),
          );
  }
}
