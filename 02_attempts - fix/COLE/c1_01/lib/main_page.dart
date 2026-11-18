import 'package:c1_01/pages/agenda.dart';
import 'package:c1_01/pages/home.dart';
import 'package:c1_01/pages/mapa.dart';
import 'package:c1_01/pages/profile.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> me;

  const MainPage({super.key, required this.me});
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
    final pages = [
      Home(me: widget.me, onTap: () {}, onTap1: () {}),
      Mapa(me: widget.me),
      Agenda(),
      Profile(me: widget.me),
    ];

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
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: index,
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.green,
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Início",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_pin),
                  label: "Mapa",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: "Agendar",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Perfil",
                ),
              ],
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
