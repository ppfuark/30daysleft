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
      Home(
        me: widget.me,
        onTap1: () {
          setState(() {
            index = 1;
          });
        },
        onTap2: () {
          setState(() {
            index = 2;
          });
        },
        onTap3: () {
          setState(() {
            index = 3;
          });
        },
      ),
      Mapa(me: widget.me),
      Agenda(me: widget.me),
      Profile(me: widget.me),
    ];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_pin),
            label: "Mapa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Agendar",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
        unselectedItemColor: Colors.grey.shade200,
        selectedItemColor: Colors.green,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        currentIndex: index,
      ),
      body: SizedBox(width: w, height: h, child: pages[index]),
    );
  }
}
