import 'dart:convert';

import 'package:a1_01/explore.dart';
import 'package:a1_01/login.dart';
import 'package:a1_01/ranking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(seconds: 3))
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener((status) async {
          if (status == AnimationStatus.completed) {
            final SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            final t = sharedPreferences.getString('token');

            final response = await http.post(
              Uri.parse(
                'http://192.168.56.1:3000/modalidades/${modalidades[index % modalidades.length]['id']}/likes',
              ),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer $t",
              },
            );
            if (response.statusCode == 201) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Curtida publicada.'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro: ${response.body}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() {
              animationController.value = 0;
            });
          }
        });

  int index = 0;

  List modalidades = [];

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final res = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://192.168.56.1:3000/modalidades/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $res",
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        modalidades = jsonDecode(response.body);
      });
      print(response.body);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
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
        actions: [
          IconButton(
            onPressed: () async {
              final SharedPreferences sharedPreferences =
                  await SharedPreferences.getInstance();
              await sharedPreferences.setString('token', "");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
        centerTitle: true,
      ),
      body: SizedBox(
        width: w,
        height: h,
        child: Column(
          spacing: 150,
          children: [
            Text("Modalidades"),

            AnimatedBuilder(
              animation: animationController,
              builder: (context, c) {
                return Expanded(
                  child: modalidades.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity == null) return;
                            if (details.primaryVelocity! > 0) {
                              setState(() {
                                index--;
                              });
                            } else {
                              setState(() {
                                index++;
                              });
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -100,
                                  top: 40,
                                  child: Transform.rotate(
                                    angle: .4,

                                    child: SizedBox(
                                      width: 250,
                                      child: Card(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                height: 300,
                                                fit: BoxFit.cover,
                                                "assets/modalidades/${['08', '17', '50', '53', '54'][index % modalidades.length == modalidades.length - 1 ? 0 : index % modalidades.length + 1]}.jpg",
                                              ),
                                              ListTile(
                                                title: Text(
                                                  modalidades[index %
                                                                  modalidades
                                                                      .length ==
                                                              modalidades
                                                                      .length -
                                                                  1
                                                          ? 0
                                                          : index %
                                                                    modalidades
                                                                        .length +
                                                                1]['titulo']
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

                                Align(
                                  alignment: AlignmentGeometry.topCenter,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Explore(
                                            modal:
                                                modalidades[index %
                                                    modalidades.length],
                                          ),
                                        ),
                                      );
                                    },
                                    onLongPressStart: (details) {
                                      setState(() {
                                        animationController.forward();
                                      });
                                    },
                                    onLongPressEnd: (details) {
                                      animationController.reverse();
                                    },
                                    child: SizedBox(
                                      width: 250,
                                      child: Card(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                height: 300,
                                                fit: BoxFit.cover,
                                                "assets/modalidades/${['08', '17', '50', '53', '54'][index % modalidades.length]}.jpg",
                                              ),
                                              ListTile(
                                                title: Text(
                                                  modalidades[index %
                                                          modalidades
                                                              .length]['titulo']
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
                                if (animationController.value != 0)
                                  Align(
                                    alignment: AlignmentGeometry.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 100.0,
                                      ),
                                      child: Stack(
                                        alignment: AlignmentGeometry.center,
                                        children: [
                                          Icon(
                                            size: 90,
                                            Icons.favorite,
                                            color: Colors.white,
                                          ),
                                          ClipRect(
                                            clipper: Heart(
                                              progress:
                                                  animationController.value,
                                            ),
                                            child: Icon(
                                              size: 90,
                                              Icons.favorite,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  left: -100,
                                  top: 40,
                                  child: Transform.rotate(
                                    angle: -.4,

                                    child: SizedBox(
                                      width: 250,
                                      child: Card(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.asset(
                                                height: 300,
                                                fit: BoxFit.cover,
                                                "assets/modalidades/${['08', '17', '50', '53', '54'][index % modalidades.length == 0 ? modalidades.length - 1 : (index % modalidades.length) - 1]}.jpg",
                                              ),
                                              ListTile(
                                                title: Text(
                                                  modalidades[index %
                                                                  modalidades
                                                                      .length ==
                                                              0
                                                          ? modalidades.length -
                                                                1
                                                          : (index %
                                                                    modalidades
                                                                        .length) -
                                                                1]['titulo']
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
                              ],
                            ),
                          ),
                        ),
                );
              },
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
      size.height - size.height * progress,
      size.width,
      size.height * progress,
    );
  }

  @override
  bool shouldReclip(covariant Heart oldClipper) {
    return oldClipper.progress != progress;
  }
}
