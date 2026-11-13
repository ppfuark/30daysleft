import 'dart:convert';

import 'package:a1_01/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Ranking extends StatefulWidget {
  const Ranking({super.key});
  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  List modalidades = [];

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final res = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://10.109.66.126:3000/modalidades/'),
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

  final serch = TextEditingController();

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
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  CupertinoSearchTextField(
                    controller: serch,
                    placeholder: "Pesquisar por...",
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            modalidades
                                .where(
                                  (element) => element['titulo']
                                      .toString()
                                      .contains(serch.text),
                                )
                                .toList()[index]['titulo']
                                .toString(),
                          ),
                          subtitle: Text(
                            modalidades
                                .where(
                                  (element) => element['titulo']
                                      .toString()
                                      .contains(serch.text),
                                )
                                .toList()[index]['resumo']
                                .toString(),
                          ),
                          leading: Image.asset(
                            height: 300,
                            fit: BoxFit.cover,
                            "assets/modalidades/${["00", '08', '17', '50', '54'][modalidades.where((element) => element['titulo'].toString().contains(serch.text)).toList()[index]['id']]}.jpg",
                          ),
                          trailing: Column(
                            children: [
                              Icon(Icons.favorite),
                              Text(
                                modalidades
                                    .where(
                                      (element) => element['titulo']
                                          .toString()
                                          .contains(serch.text),
                                    )
                                    .toList()[index]['totalLikes']
                                    .toString(),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: modalidades
                          .where(
                            (element) => element['titulo'].toString().contains(
                              serch.text,
                            ),
                          )
                          .length,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.sort),
                    VerticalDivider(),
                    IconButton(
                      onPressed: () {
                        modalidades.sort(
                          (a, b) => a['titulo'].toString().compareTo(
                            b['titulo'].toString(),
                          ),
                        );
                        setState(() {});
                      },
                      icon: Text("ABC"),
                    ),
                    IconButton(
                      onPressed: () {
                        modalidades.sort(
                          (a, b) =>
                              a['id'].toString().compareTo(b['id'].toString()),
                        );
                        setState(() {});
                      },
                      icon: Text("123"),
                    ),
                    IconButton(
                      onPressed: () {
                        modalidades.sort(
                          (a, b) => b['totalLikes'].toString().compareTo(
                            a['totalLikes'].toString(),
                          ),
                        );
                        setState(() {});
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
