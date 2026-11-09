import 'package:a2_01/page/feed.dart';
import 'package:a2_01/page/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  final int index;
  const MainPage({super.key, this.index = 0});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  late int index = widget.index;

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
    final pages = [Feed(), Profile()];

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
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        ListTile(
                          title: Image.asset('assets/ic_launcher.png'),
                          subtitle: Text(
                            "Uma comunidade para a maior competicão de educação profissional do mundo!",
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
                          onTap: () async {
                            final share = await SharedPreferences.getInstance();
                            await share.setString('token', "");
                            Navigator.pop(context);
                          },
                          leading: Icon(Icons.logout),
                          title: Text("Sair"),
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
