import 'package:a1_01/pages/calendar.dart';
import 'package:a1_01/pages/game.dart';
import 'package:a1_01/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  int index = 0;

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

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final pages = [Home(), Game(), Calendar()];

    return loading
        ? Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icon(Icons.menu),
                ),
              ),
              title: Row(
                spacing: 2,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Icon(Icons.recycling), Text('ColetaJá')],
              ),
            ),
            drawer: Drawer(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.close),
                      title: Row(
                        spacing: 2,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Icon(Icons.recycling), Text('ColetaJá')],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.recycling),
                      title: Text("ColetaJá"),
                      trailing: Text("Menu Principal"),
                    ),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text("Início"),
                      onTap: () {
                        setState(() {
                          index = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(CupertinoIcons.game_controller),
                      title: Text("Lixeira em Ação"),
                      onTap: () {
                        setState(() {
                          index = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_month),
                      title: Text("Calendário"),
                      onTap: () {
                        setState(() {
                          index = 2;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    Divider(),
                    Spacer(),
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      leading: Icon(Icons.logout),
                      title: Text("Sair", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: pages[index],
            ),
          );
  }
}
