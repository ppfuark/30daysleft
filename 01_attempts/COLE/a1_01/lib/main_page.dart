import 'package:a1_01/pages/calend.dart';
import 'package:a1_01/pages/game.dart';
import 'package:a1_01/pages/home.dart';
import 'package:a1_01/pages/login.dart';
import 'package:flutter/cupertino.dart';
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
    final pages = [Home(), Game(), Calend()];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),
            );
          },
        ),
        title: Row(
          spacing: 10,
          children: [Icon(Icons.recycling), Text("ColetaJá")],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).closeDrawer();
                    },
                    icon: Icon(Icons.close),
                  );
                },
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.recycling, size: 20), Text("ColetaJá")],
              ),
              trailing: Text("Menu Principal"),
            ),
            Divider(),
            ListTile(
              onTap: () {
                setState(() {
                  index = 0;
                  Navigator.pop(context);
                });
              },
              leading: Icon(Icons.home),
              title: Text("Início"),
              tileColor: index == 0 ? Colors.grey.shade200 : null,
            ),
            ListTile(onTap: () {
                setState(() {
                  index = 1;
                  Navigator.pop(context);
                });
              },
              leading: Icon(CupertinoIcons.gamecontroller_fill),
              title: Text("Lixeira em Ação"),
              tileColor: index == 1 ? Colors.grey.shade200 : null,
            ),
            ListTile(onTap: () {
                setState(() {
                  index = 2;
                  Navigator.pop(context);
                });
              },
              leading: Icon(Icons.calendar_month),
              title: Text("Calendário"),
              tileColor: index == 2 ? Colors.grey.shade200 : null,
            ),
            Spacer(),
            ListTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Sair", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      body: SizedBox(width: w, height: h, child: pages[index]),
    );
  }
}
