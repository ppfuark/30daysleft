import 'package:a2_01/pages/colab.dart';
import 'package:a2_01/pages/coleta.dart';
import 'package:a2_01/pages/dash.dart';
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
    final pages = [
      Coleta(
        onTap: () {
          setState(() {
            index = 1;
          });
        },
      ),
      Colab(onTap: () {}),
      Dash(onTap: () {}),
    ];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: w,
        height: h,
        child: Row(
          children: [
            Container(
              width: w * .2,
              height: double.infinity,
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(title: Text("ColetaJá")),
                  ListTile(
                    leading: Icon(Icons.local_shipping),
                    title: Text("Coleta"),
                    onTap: () {
                      setState(() {
                        index = 0;
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text("Colaboradores"),
                    onTap: () {
                      setState(() {
                        index = 1;
                      });
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text("Dahsboard"),
                    onTap: () {
                      setState(() {
                        index = 2;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(child: pages[index]),
          ],
        ),
      ),
    );
  }
}
