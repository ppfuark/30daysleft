import 'package:a2_01/app.dart';
import 'package:a2_01/pages/dash.dart';
import 'package:a2_01/pages/delivery.dart';
import 'package:a2_01/pages/login.dart';
import 'package:a2_01/pages/orders.dart';
import 'package:a2_01/pages/profile.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  Future<void> startApp() async {}
  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [Dash(), Orders(), Delivery(), Profile()];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: App.theme.value == App.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  Text(
                    "Logotipo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: index == 0 ? Border.all() : null,
                    ),
                    child: IconButton(
                      iconSize: 70,
                      onPressed: () {
                        setState(() {
                          index = 0;
                        });
                      },
                      icon: Icon(Icons.bar_chart),
                    ),
                  ),

                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: index == 1 ? Border.all() : null,
                    ),
                    child: IconButton(
                      iconSize: 70,
                      onPressed: () {
                        setState(() {
                          index = 1;
                        });
                      },
                      icon: Icon(Icons.checklist),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: index == 2 ? Border.all() : null,
                    ),
                    child: IconButton(
                      iconSize: 70,
                      onPressed: () {
                        setState(() {
                          index = 2;
                        });
                      },
                      icon: Icon(Icons.bike_scooter),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: index == 3 ? Border.all() : null,
                    ),
                    child: IconButton(
                      iconSize: 70,
                      onPressed: () {
                        setState(() {
                          index = 3;
                        });
                      },
                      icon: Icon(Icons.person),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 100,
                    height: 100,

                    child: IconButton(
                      iconSize: 70,
                      onPressed: () {
                        setState(() {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                            (route) => false,
                          );
                        });
                      },
                      icon: Icon(Icons.logout),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 6, child: pages[index]),
        ],
      ),
    );
  }
}
