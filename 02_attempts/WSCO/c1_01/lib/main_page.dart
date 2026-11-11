import 'package:c1_01/pages/chat.dart';
import 'package:c1_01/pages/game.dart';
import 'package:c1_01/pages/profile.dart';
import 'package:c1_01/pages/timeline.dart';
import 'package:c1_01/pages/unidadades.dart';
import 'package:c1_01/pages/widget.dart';
import 'package:flutter/cupertino.dart';
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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final pages = [
      Timeline(me: widget.me),
      WidgetE(
        me: widget.me,
        onTap: () {
          setState(() {
            index = 0;
          });
        },
      ),
      Chat(me: widget.me),
      Game(me: widget.me),
      Unidadades(me: widget.me),
      Profile(me: widget.me),
    ];

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
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.watch_later),
                  label: 'Timeline',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.widgets),
                  label: 'Widget',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.game_controller_solid),
                  label: 'Mini Game',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.apartment),
                  label: 'Unidades',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
              currentIndex: index,
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.blue,
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
