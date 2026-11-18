import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Ranking extends StatefulWidget {
  const Ranking({super.key});
  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  final search = TextEditingController();

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
            appBar: AppBar(title: Text("Ranking")),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      children: [
                        TextField(
                          controller: search,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),

                            hintText: "Pesquisar por...",
                            suffixIcon: IconButton(
                              onPressed: () {
                                search.clear();
                                setState(() {});
                              },
                              icon: Icon(Icons.close),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: AssetImage(
                                    'assets/modalidades/${["", '08.jpg', '17.jpg', '50.jpg', '53.jpg'][modals.where((element) => element['titulo'].toString().contains(search.text)).toList()[index]['id']]}',
                                  ),
                                ),
                                title: Text(
                                  modals
                                      .where(
                                        (element) => element['titulo']
                                            .toString()
                                            .contains(search.text),
                                      )
                                      .toList()[index]['titulo']
                                      .toString(),
                                ),
                                subtitle: Text(
                                  modals
                                      .where(
                                        (element) => element['titulo']
                                            .toString()
                                            .contains(search.text),
                                      )
                                      .toList()[index]['resumo']
                                      .toString(),
                                ),
                                trailing: Column(
                                  children: [
                                    Text(
                                      modals
                                          .where(
                                            (element) => element['titulo']
                                                .toString()
                                                .contains(search.text),
                                          )
                                          .toList()[index]['totalLikes']
                                          .toString(),
                                    ),
                                    Icon(Icons.favorite, color: Colors.red),
                                  ],
                                ),
                              );
                            },
                            itemCount: modals
                                .where(
                                  (element) => element['titulo']
                                      .toString()
                                      .contains(search.text),
                                )
                                .length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 30,
                    right: 30,

                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.sort),
                          VerticalDivider(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                modals.sort(
                                  (a, b) => a['titulo'].toString().compareTo(
                                    b['titulo'].toString(),
                                  ),
                                );
                              });
                            },
                            icon: Text("ABC"),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                modals.sort(
                                  (a, b) => a['id'].toString().compareTo(
                                    b['id'].toString(),
                                  ),
                                );
                              });
                            },
                            icon: Text("123"),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                modals.sort(
                                  (a, b) => b['totalLikes']
                                      .toString()
                                      .compareTo(a['totalLikes'].toString()),
                                );
                              });
                            },
                            icon: Text("S2"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
