import 'dart:convert';
import 'package:a2_01/app.dart';
import 'package:a2_01/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  final Function onTap;

  const Feed({super.key, required this.onTap});
  @override
  State<Feed> createState() => FeedState();
}

class FeedState extends State<Feed> {
  List modalidades = [];
  List comentarios = [];
  List competidores = [];
  List medals = [];
  dynamic me = {};
  List<dynamic> categorias = [];

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token');

    final response = await http.get(
      Uri.parse('http://10.109.66.126:3000/modalidades'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        modalidades = jsonDecode(response.body);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    final response1 = await http.get(
      Uri.parse('http://10.109.66.126:3000/categorias'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response1.statusCode == 200) {
      setState(() {
        final List<dynamic> temp = [
          {"id": 0, "name": "Todas"},
        ];
        categorias = temp + jsonDecode(response1.body);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    final response2 = await http.get(
      Uri.parse('http://10.109.66.126:3000/comentarios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response2.statusCode == 200) {
      setState(() {
        comentarios = jsonDecode(response2.body);

        comentarios = comentarios.reversed.toList();
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    final response3 = await http.get(
      Uri.parse('http://10.109.66.126:3000/medalhas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response3.statusCode == 200) {
      setState(() {
        medals = jsonDecode(response3.body);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    final response4 = await http.get(
      Uri.parse('http://10.109.66.126:3000/competidores'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response4.statusCode == 200) {
      setState(() {
        competidores = jsonDecode(response4.body);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
    final response5 = await http.get(
      Uri.parse('http://10.109.66.126:3000/competidores/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response5.statusCode == 200) {
      setState(() {
        me = jsonDecode(response5.body);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  final search = TextEditingController();
  final comment = TextEditingController();
  int selectedM = 0;
  String selectedMedal = "Todas";
  List medalTypes = ['Todas', 'Ouro', 'Prata', 'Bronze'];

  Map<String, dynamic>? modalidade;

  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return modalidade != null
        ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    modalidade = null;
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
              title: Text("Voltar para o Feed SENAI"),
              actions: [
                IconButton(
                  onPressed: () {
                    App.toogle();
                  },
                  icon: Icon(
                    App.theme.value == App.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onTap();
                  },
                  icon: Icon(Icons.person),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Chip(
                    label: Text(
                      categorias
                          .where(
                            (element) =>
                                element['id'] == modalidade!['categoriaId'],
                          )
                          .first['name']
                          .toString(),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      modalidade!['title'].toString(),
                      style: TextStyle(fontSize: 30),
                    ),
                    subtitle: Text(
                      modalidade!['summary'].toString(),
                      style: TextStyle(fontSize: 20),
                    ),
                    trailing: Chip(label: Text("Vagas Disponíveis")),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              "Detalhes da Modalidade",
                              style: TextStyle(fontSize: 24),
                            ),
                            subtitle: Text(
                              modalidade!['description'].toString(),
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Chip(
                              label: Text(
                                "${(modalidade!['vagasPreenchidas'] / modalidade!['totalVagas']) * 100}%",
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.thumb_up_alt),
                              Text(modalidade!['totalLikes'].toString()),
                              SizedBox(width: 10),
                              Icon(Icons.chat),
                              Text(
                                comentarios
                                    .where(
                                      (element) =>
                                          element['modalidadeId'] ==
                                          modalidade!['id'],
                                    )
                                    .length
                                    .toString(),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () async {
                                  final SharedPreferences sharedPreferences =
                                      await SharedPreferences.getInstance();
                                  final list =
                                      sharedPreferences.getStringList('favs') ??
                                      [];

                                  list.contains(modalidade!['id'].toString())
                                      ? list.remove(
                                          modalidade!['id'].toString(),
                                        )
                                      : list.add(modalidade!['id'].toString());

                                  await sharedPreferences.setStringList(
                                    'favs',
                                    list,
                                  );

                                  setState(() {});
                                },
                                icon: Icon(Icons.favorite),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.share),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              "Comentários",
                              style: TextStyle(fontSize: 24),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/avatar-teste.jpg',
                              ),
                            ),
                            subtitle: TextField(
                              controller: comment,
                              maxLength: 500,
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                if (comment.text.isNotEmpty) {
                                  final SharedPreferences sharedPreferences =
                                      await SharedPreferences.getInstance();
                                  final t = sharedPreferences.getString(
                                    'token',
                                  );
                                  final response = await http
                                      .post(
                                        Uri.parse(
                                          'http://10.109.66.126:3000/modalidades/${modalidade!['id']}/comentarios',
                                        ),
                                        headers: {
                                          "Content-Type": "application/json",
                                          'Authorization': 'Bearer $t',
                                        },
                                        body: jsonEncode({
                                          'content': comment.text,
                                        }),
                                      )
                                      .timeout(Duration(seconds: 5));
                                  if (response.statusCode == 201) {
                                    startApp();
                                    comment.clear();
                                  } else {
                                    print(response.body);
                                  }
                                }
                              },
                              icon: Icon(Icons.send),
                            ),
                          ),
                          ...comentarios
                              .where(
                                (element) =>
                                    element['modalidadeId'] ==
                                    modalidade!['id'],
                              )
                              .map((e) {
                                final author = competidores
                                    .where(
                                      (element) =>
                                          element['id'] == e['authorId'],
                                    )
                                    .first;

                                print(author);

                                return ListTile(
                                  leading: Icon(Icons.person),
                                  title: Text(
                                    "@${author['name'] ?? "Sem nome"}",
                                  ),
                                  subtitle: Text(e['content']),
                                  trailing: author['id'] == me['id']
                                      ? IconButton(
                                          onPressed: () async {
                                            final SharedPreferences
                                            sharedPreferences =
                                                await SharedPreferences.getInstance();
                                            final t = sharedPreferences
                                                .getString('token');
                                            final res = await http
                                                .delete(
                                                  Uri.parse(
                                                    'http://10.109.66.126:3000/comentarios/${e['id']}',
                                                  ),
                                                  headers: {
                                                    "Content-Type":
                                                        "application/json",
                                                    'Authorization':
                                                        'Bearer $t',
                                                  },
                                                )
                                                .timeout(Duration(seconds: 5));
                                            if (res.statusCode == 200) {
                                              startApp();
                                            }
                                          },
                                          icon: Icon(Icons.delete),
                                        )
                                      : null,
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                spacing: 30,
                children: [
                  Text("WSConecta"),
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: search,
                      onChanged: (value) {
                        setState(() {});
                      },
                      placeholder: "Buscar...",
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    App.toogle();
                  },
                  icon: Icon(
                    App.theme.value == App.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    widget.onTap();
                  },
                  icon: Icon(Icons.person),
                ),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        "Modalidades",
                        style: TextStyle(fontSize: 30),
                      ),
                      subtitle: Text(
                        "Explore as modalidades no ecossistema SENAI.",
                      ),
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        ...categorias.map(
                          (e) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedM = e['id'] as int;
                              });
                            },
                            child: Chip(
                              label: Text(e['name'].toString()),
                              backgroundColor: e['id'] == selectedM
                                  ? Colors.blue.shade300
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final i = modalidades
                              .where(
                                (element) =>
                                    element['categoriaId'] == selectedM ||
                                    selectedM == 0,
                              )
                              .where(
                                (element) => element['title']
                                    .toString()
                                    .contains(search.text),
                              )
                              .toList()[index];

                          return SizedBox(
                            width: 300,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text(i['title'].toString()),
                                      subtitle: Text(i['summary'].toString()),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.favorite),
                                        Text(i['totalLikes'].toString()),
                                        SizedBox(width: 10),
                                        Icon(Icons.chat),
                                        Text(
                                          comentarios
                                              .where(
                                                (element) =>
                                                    element['modalidadeId'] ==
                                                    i['id'],
                                              )
                                              .length
                                              .toString(),
                                        ),
                                        Spacer(),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              modalidade = i;
                                            });
                                          },
                                          child: Text("Ver Detalhes"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: modalidades
                            .where(
                              (element) =>
                                  element['categoriaId'] == selectedM ||
                                  selectedM == 0,
                            )
                            .where(
                              (element) => element['title'].toString().contains(
                                search.text,
                              ),
                            )
                            .length,
                      ),
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        ...medalTypes.map(
                          (e) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMedal = e;
                              });
                            },
                            child: Chip(
                              label: Text(e.toString()),
                              backgroundColor: e == selectedMedal
                                  ? Colors.blue.shade300
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                ...medals
                                    .where(
                                      (element) => element['pais'] == "Brasil",
                                    )
                                    .map(
                                      (e) => FlSpot(
                                        double.parse(
                                          e['data'].toString().split("'").last,
                                        ),
                                        medals
                                            .where(
                                              (element) =>
                                                  element['pais'] == "Brasil" &&
                                                  (selectedMedal == "Todas" ||
                                                      selectedMedal
                                                              .toLowerCase() ==
                                                          e['tipo']),
                                            )
                                            .length
                                            .toDouble(),
                                      ),
                                    ),
                              ],
                            ),
                          ],
                          minY: 0,
                          maxY: 5,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) => Text(
                                  "'${(value - 2000).toStringAsFixed(0)}",
                                ),
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            rightTitles: AxisTitles(),
                            topTitles: AxisTitles(),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("Abrir Site")),
                  ],
                ),
              ),
            ),
          );
  }
}
