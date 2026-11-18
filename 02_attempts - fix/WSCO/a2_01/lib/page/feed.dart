import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});
  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List competidores = [];
  List escolas = [];
  List categorias = [
    {"id": 0, "name": "Todas"},
  ];
  int selectedC = 0;

  List medalsCat = [
    {"id": 0, "tipo": "Todas"},
    {"id": 1, "tipo": "ouro"},
    {"id": 2, "tipo": "prata"},
    {"id": 3, "tipo": "bronze"},
  ];
  String selectedM = "Todas";

  List medalhas = [];
  List modalidades = [];
  List comentarios = [];
  List<String> favorites = [];
  List likes = [];

  bool loadMore = false;

  final comment = TextEditingController();

  Future<void> startApp() async {
    Connectivity().onConnectivityChanged.listen((event) async {
      if (event.contains(ConnectivityResult.none)) {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Sem conexão com a internet, ao se reconectar, entre novamente.',
              ),
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
        return;
      }
    });

    try {
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';

        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/competidores'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            competidores = json;
            favorites = share.getStringList('favs') ?? [];
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          Fluttertoast.showToast(
            msg: 'Erro: Token inválido',
            backgroundColor: Colors.red,
          );
        }
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
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/escolas'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            escolas = json;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          Fluttertoast.showToast(
            msg: 'Erro: Token inválido',
            backgroundColor: Colors.red,
          );
        }
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
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/categorias'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            categorias += json;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          Fluttertoast.showToast(
            msg: 'Erro: Token inválido',
            backgroundColor: Colors.red,
          );
        }
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
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/medalhas'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            medalhas = json;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          Fluttertoast.showToast(
            msg: 'Erro: Token inválido',
            backgroundColor: Colors.red,
          );
        }
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
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/comentarios'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            comentarios = json;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          Fluttertoast.showToast(
            msg: 'Erro: Token inválido',
            backgroundColor: Colors.red,
          );
        }
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
            modalidades = json;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          Fluttertoast.showToast(
            msg: 'Erro: Token inválido',
            backgroundColor: Colors.red,
          );
        }
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
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/curtidas'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            likes = json;
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
          Fluttertoast.showToast(
            msg: 'Erro: Token inválido',
            backgroundColor: Colors.red,
          );
        }
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

      await Future.delayed(Duration(seconds: 2));

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

  final search = TextEditingController();
  Map<String, dynamic>? selected;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700))
          ..forward()
          ..repeat(reverse: true);
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget skeleton(double h, double w) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    print(modalidades.length);

    return selected != null
        ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    selected = null;
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
              title: Row(spacing: 30, children: [Text("Voltar ao Feed SENAI")]),
              actions: [
                IconButton(
                  onPressed: () async {
                    setState(() {
                      App.toogle();
                    });
                  },
                  icon: Icon(
                    App.theme.value == App.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.person)),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              padding: EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: ColorScheme.of(context).inverseSurface,
                        ),
                      ),
                      width: w,
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ListTile(
                            title: Text(
                              selected!['title'].toString(),
                              style: TextStyle(fontSize: 30),
                            ),
                            subtitle: Text(
                              style: TextStyle(fontSize: 20),
                              categorias
                                  .firstWhere(
                                    (element) =>
                                        element['id'] ==
                                        selected!['categoriaId'],
                                    orElse: () => {},
                                  )['name']
                                  .toString(),
                            ),
                            trailing: Chip(
                              label: Text(
                                selected!['totalVagas'] >
                                        selected!['vagasPreenchidas']
                                    ? "Vagas Disponíveis"
                                    : "Sem Vagas",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: ColorScheme.of(context).inverseSurface,
                        ),
                      ),
                      width: double.infinity,
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListTile(
                            title: Text(
                              "Detalhes da Modalidade",
                              style: TextStyle(fontSize: 24),
                            ),
                            subtitle: Text(selected!['description'].toString()),
                            trailing: Chip(
                              label: Text(
                                "${(selected!['vagasPreenchidas'] / selected!['totalVagas']) * 100}%",
                              ),
                            ),
                          ),
                          ListTile(
                            subtitle: Row(
                              spacing: 10,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.comment),
                                    Text(
                                      comentarios
                                          .where(
                                            (element) =>
                                                element['modalidadeId'] ==
                                                selected!['id'],
                                          )
                                          .length
                                          .toString(),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.thumb_up),
                                    Text(
                                      likes
                                          .where(
                                            (element) =>
                                                element['modalidadeId'] ==
                                                selected!['id'],
                                          )
                                          .length
                                          .toString(),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.share_sharp),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final share =
                                        await SharedPreferences.getInstance();

                                    favorites.contains(
                                          selected!['id'].toString(),
                                        )
                                        ? favorites.remove(
                                            selected!['id'].toString(),
                                          )
                                        : favorites.add(
                                            selected!['id'].toString(),
                                          );
                                    await share.setStringList(
                                      'favs',
                                      favorites,
                                    );

                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.favorite,
                                    color:
                                        favorites.contains(
                                          selected!['id'].toString(),
                                        )
                                        ? Colors.red
                                        : Colors.grey.shade200,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: ColorScheme.of(context).inverseSurface,
                        ),
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(
                              "Comentários",
                              style: TextStyle(fontSize: 24),
                            ),
                            subtitle: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                  'assets/avatar/avatar-teste.jpg',
                                ),
                              ),
                              title: TextField(
                                controller: comment,
                                maxLength: 500,
                                decoration: InputDecoration(
                                  hintText: "Comentar...",
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  if (comment.text.isNotEmpty) {}
                                },
                                icon: Icon(Icons.send),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 70.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final e = comentarios
                                        .where(
                                          (element) =>
                                              element['modalidadeId'] ==
                                              selected!['id'],
                                        )
                                        .toList()[index];

                                    final author = competidores.firstWhere(
                                      (element) =>
                                          element['id'] == e['authorId'],
                                      orElse: () => {},
                                    );

                                    return ListTile(
                                      title: Text(author['name'].toString()),
                                      subtitle: Text(e['content'].toString()),
                                      leading: Icon(Icons.person),
                                      trailing: Text(
                                        "há ${DateTime.parse(e['createdAt'].toString()).difference(DateTime.now()).inDays.abs()} dias",
                                      ),
                                    );
                                  },
                                  itemCount: loadMore
                                      ? comentarios
                                            .where(
                                              (element) =>
                                                  element['modalidadeId'] ==
                                                  selected!['id'],
                                            )
                                            .toList()
                                            .length
                                      : 2,
                                ),
                                if (!loadMore)
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        loadMore = true;
                                      });
                                    },
                                    child: Text("Carregar mais comentários"),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          width: 1,
                          color: ColorScheme.of(context).inverseSurface,
                        ),
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListTile(
                            title: Text(
                              "Inscrições Abertas",
                              style: TextStyle(fontSize: 24),
                            ),
                            subtitle: ElevatedButton(
                              onPressed: () {},
                              child: Text("Inscrever-se Agora"),
                            ),
                            trailing: Chip(
                              label: Text(
                                "${(selected!['vagasPreenchidas'] / selected!['totalVagas']) * 100}%",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    child: TextField(
                      controller: search,
                      decoration: InputDecoration(hintText: "Pesquisar..."),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    setState(() {
                      App.toogle();
                    });
                  },
                  icon: Icon(
                    App.theme.value == App.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.person)),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        "Modalidades",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        style: TextStyle(fontSize: 20),
                        "Explore as modalidades no ecossistema SENAI",
                      ),
                    ),
                    if (!loading)
                      Row(
                        spacing: 10,
                        children: [
                          ...categorias.map(
                            (e) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedC = e['id'];
                                });
                              },
                              child: Chip(
                                label: Text(
                                  e['name'].toString(),
                                  style: TextStyle(
                                    color: selectedC == e['id']
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                backgroundColor: selectedC == e['id']
                                    ? Colors.blue
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 300,
                      width: w,
                      child: loading
                          ? skeleton(300, w)
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ...modalidades.map(
                                    (m) => SizedBox(
                                      width: 300,
                                      height: 300,
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Icon(Icons.broken_image),
                                              ),
                                              ListTile(
                                                contentPadding: EdgeInsets.all(
                                                  0,
                                                ),
                                                title: Text(
                                                  m['title'].toString(),
                                                ),
                                                subtitle: Text(
                                                  m['description'].toString(),
                                                ),
                                              ),
                                              Row(
                                                spacing: 10,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.comment),
                                                      Text(
                                                        comentarios
                                                            .where(
                                                              (element) =>
                                                                  element['modalidadeId'] ==
                                                                  m['id'],
                                                            )
                                                            .length
                                                            .toString(),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.favorite),
                                                      Text(
                                                        likes
                                                            .where(
                                                              (element) =>
                                                                  element['modalidadeId'] ==
                                                                  m['id'],
                                                            )
                                                            .length
                                                            .toString(),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        selected = m;
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    if (!loading)
                      Row(
                        spacing: 10,
                        children: [
                          ...medalsCat.map(
                            (e) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedM = e['tipo'];
                                });
                              },
                              child: Chip(
                                label: Text(
                                  e['tipo'].toString().toUpperCase(),
                                  style: TextStyle(
                                    color: selectedM == e['tipo']
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                backgroundColor: selectedM == e['tipo']
                                    ? Colors.blue
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      width: w,
                      height: 300,
                      child: loading
                          ? skeleton(300, w)
                          : LineChart(
                              LineChartData(
                                minY: 0,
                                maxY: 5,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      ...medalhas
                                          .where(
                                            (element) =>
                                                element['pais'] == "Brasil" &&
                                                (selectedM == "Todas" ||
                                                    element['tipo'] ==
                                                        selectedM),
                                          )
                                          .map(
                                            (e) => FlSpot(
                                              double.parse(
                                                e['data']
                                                    .toString()
                                                    .split("'")
                                                    .last,
                                              ),
                                              medalhas
                                                  .where(
                                                    (element) =>
                                                        element['pais'] ==
                                                            "Brasil" &&
                                                        (selectedM == "Todas" ||
                                                            element['tipo'] ==
                                                                selectedM) &&
                                                        e['data']
                                                                .toString()
                                                                .split("'")
                                                                .last ==
                                                            element['data']
                                                                .toString()
                                                                .split("'")
                                                                .last,
                                                  )
                                                  .length
                                                  .toDouble(),
                                            ),
                                          ),
                                    ],
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      reservedSize: 30,
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(reservedSize: 30),
                                  ),
                                  topTitles: AxisTitles(),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          (value % 2000).toStringAsFixed(0),
                                        );
                                      },
                                      interval: 2,
                                      showTitles: true,
                                    ),
                                  ),
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
