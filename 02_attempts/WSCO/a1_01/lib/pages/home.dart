import 'dart:convert';

import 'package:a1_01/pages/explore.dart';
import 'package:a1_01/pages/ranking.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List modals = [];
  int center = 0;

  Future<void> startApp() async {
    try {
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/modalidades'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            modals = json;
          });
          print(modals);
        } else {}
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro ao realizar get: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Ok!'),
                ),
              ],
            );
          },
        );
      }

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
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 3))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          setState(() {
            _controller.value = 0.0;
          });
          print("Complete");
          try {
            final share = await SharedPreferences.getInstance();
            final t = share.getString('token') ?? '';
            final res = await http.post(
              Uri.parse(
                'http://10.109.66.126:3000/modalidades/${modals[center]['id']}/likes',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $t',
              },
            );
            if (res.statusCode == 201) {
              setState(() {
                print(res.body);
                Fluttertoast.showToast(
                  msg: 'Curtida realizada',
                  backgroundColor: Colors.green,
                );
              });
            } else {
              print(res.body);
              Fluttertoast.showToast(
                msg: 'Erro: ${jsonDecode(res.body)['mensagem']}',
                backgroundColor: Colors.red,
              );
            }
          } catch (e) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Erro ao realizar post: $e'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Ok!'),
                    ),
                  ],
                );
              },
            );
          }
        }
      });
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
    return loading
        ? Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Ranking()),
                  );
                },
                icon: Icon(Icons.emoji_events),
              ),
              title: Text("SP Skills"),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: () async {
                    final share = await SharedPreferences.getInstance();
                    await share.setString('token', "");
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  Text("Modalidades"),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity == null) return;

                        setState(() {
                          if (details.primaryVelocity! > 0) {
                            center =
                                (center - 1 + modals.length) % modals.length;
                          } else {
                            center = (center + 1) % modals.length;
                          }
                        });
                        print(center);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            Positioned(
                              right: -100,
                              bottom: 120,
                              child: Transform.rotate(
                                angle: 0.4,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    16,
                                  ),
                                  child: SizedBox(
                                    width: w * .6,
                                    height: h * .5,
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Image.asset(
                                              height: double.infinity,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              'assets/modalidades/${["", '08.jpg', '17.jpg', '50.jpg', '53.jpg'][modals[(center + 1) % modals.length]['id']]}',
                                            ),
                                          ),
                                          ListTile(
                                            title: Text(
                                              modals[(center + 1) %
                                                      modals.length]['titulo']
                                                  .toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(16),
                              child: GestureDetector(
                                onLongPressStart: (details) {
                                  setState(() {
                                    _controller.forward();
                                  });
                                },
                                onLongPressEnd: (details) {
                                  setState(() {
                                    _controller.reverse();
                                  });
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Explore(modal: modals[center]),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: w * .7,
                                  height: h * .5,
                                  child: Card(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Image.asset(
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  'assets/modalidades/${["", '08.jpg', '17.jpg', '50.jpg', '53.jpg'][modals[center]['id']]}',
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  modals[center]['titulo']
                                                      .toString(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_controller.value != 0.0)
                                          Align(
                                            alignment: AlignmentGeometry.center,
                                            child: SizedBox(
                                              height: 200,
                                              width: 200,
                                              child: Stack(
                                                alignment:
                                                    AlignmentGeometry.center,
                                                children: [
                                                  Icon(
                                                    size: 130,
                                                    Icons.favorite,
                                                    color: Colors.white,
                                                  ),
                                                  ClipRect(
                                                    clipper: Heart(
                                                      progress:
                                                          _controller.value,
                                                    ),
                                                    child: Icon(
                                                      size: 130,
                                                      Icons.favorite,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -150,
                              bottom: 120,
                              child: Transform.rotate(
                                angle: -0.3,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    16,
                                  ),
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: SizedBox(
                                      width: w * .6,
                                      height: h * .5,
                                      child: Card(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Image.asset(
                                                height: double.infinity,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                'assets/modalidades/${["", '08.jpg', '17.jpg', '50.jpg', '53.jpg'][modals[(center - 1 + modals.length) % modals.length]['id']]}',
                                              ),
                                            ),
                                            ListTile(
                                              title: Text(
                                                modals[(center -
                                                            1 +
                                                            modals.length) %
                                                        modals.length]['titulo']
                                                    .toString(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class Heart extends CustomClipper<Rect> {
  double progress;

  Heart({required this.progress});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      size.height - (size.height * progress),
      size.width,
      size.height * progress,
    );
  }

  @override
  bool shouldReclip(covariant Heart oldClipper) {
    return oldClipper.progress != progress;
  }
}
