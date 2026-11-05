import 'package:attempt_02/pages/chat.dart';
import 'package:attempt_02/pages/game.dart';
import 'package:attempt_02/pages/profile.dart';
import 'package:attempt_02/pages/schools.dart';
import 'package:attempt_02/pages/time.dart';
import 'package:flutter/cupertino.dart';
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
      Chat(me: widget.me),
      Profile(me: widget.me),
      Menu(),
      Schools(me: widget.me),
      Time(me: widget.me),
    ];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        child: pages[index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Meu Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.game_controller),
            label: 'Mini Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Unidades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: 'Timeline',
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
      ),
    );
  }
}
