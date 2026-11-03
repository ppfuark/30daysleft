import 'package:a2_01/main.dart';
import 'package:a2_01/pages/feed.dart';
import 'package:a2_01/pages/perfil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final pages = [
      Feed(
        onTap: () {
          setState(() {
            index = 1;
          });
        },
      ),
      Perfil(
        onTap: () {
          setState(() {
            index = 0;
          });
        },
      ),
    ];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  ListTile(
                    title: Text(
                      "Uma comunidade para a maior competicição de educação profissional do mundo!",
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        index = 0;
                      });
                    },
                    leading: Icon(Icons.feed),
                    title: Text("Feed"),
                  ),
                  ListTile(
                    onTap: () {
                      setState(() {
                        index = 1;
                      });
                    },
                    leading: Icon(Icons.person),
                    title: Text("Perfil"),
                  ),
                  Spacer(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Sair"),
                    onTap: () async {
                      final SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      await sharedPreferences.setString('token', "");

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(flex: 4, child: pages[index]),
          ],
        ),
      ),
    );
  }
}
