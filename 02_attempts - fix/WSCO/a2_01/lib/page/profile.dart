import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
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
      final share = await SharedPreferences.getInstance();
      final t = share.getString('token') ?? '';
      final res = await http.get(
        Uri.parse('http://10.109.66.126:3000/competidores/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $t',
        },
      );
      final json = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          me = json;
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
            fields = [
              TextEditingController(text: me['name'].toString()),
              TextEditingController(text: me['email'].toString()),
              MaskedTextController(
                mask: '00/00/0000',
                text: me['birthDate'].toString(),
              ),
              MaskedTextController(
                mask: '(00) 00000-0000',
                text: me['phone'].toString(),
              ),
            ];

            double temp = 0.0;

            for (var element in fields) {
              if (element.text.isNotEmpty) {
                setState(() {
                  temp += 0.2;
                });
              }
              if (me['modalidadeId'].toString().isNotEmpty) {
                setState(() {
                  temp += 0.1;
                });
              }
              if (me['escolaId'].toString().isNotEmpty) {
                setState(() {
                  temp += 0.1;
                });
              }
            }

            setState(() {
              progress = temp.clamp(0.0, 1.0);
            });
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

  dynamic me = {};
  double progress = 0.0;

  bool editing = false;

  List fields = [];
  List labels = ['Nome Completo', "E-mail", "Data de Nascimento", "Telefone"];

  final pin = TextEditingController();

  late dynamic meCopy = Map<String, dynamic>.from(me);

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
            appBar: AppBar(
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
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      "Editar Perfil",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      style: TextStyle(fontSize: 20),
                      "Gerencie suas informações pessoais e educacionais.",
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        if (editing) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Digite o pin corretamente (1234)'),
                                content: TextField(controller: pin),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      if (pin.text == "1234") {
                                        try {
                                          meCopy['name'] = fields[0].text;
                                          meCopy['email'] = fields[1].text;
                                          meCopy['birthdate'] = fields[2].text;
                                          meCopy['phone'] = fields[3].text;

                                          final share =
                                              await SharedPreferences.getInstance();
                                          final t =
                                              share.getString('token') ?? '';
                                          final res = await http.patch(
                                            Uri.parse(
                                              'http://10.109.66.126:3000/competidores/me',
                                            ),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization': 'Bearer $t',
                                            },
                                            body: jsonEncode(meCopy),
                                          );
                                          jsonDecode(res.body);
                                          if (res.statusCode == 200 ||
                                              res.statusCode == 201) {
                                            setState(() {});
                                            startApp();
                                            Navigator.pop(context);
                                            setState(() {
                                              editing = false;
                                            });
                                          } else {}
                                        } catch (e) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Erro ao realizar put: $e',
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
                                        }
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Erro: pin incorreto',
                                          backgroundColor: Colors.red,
                                        );
                                        setState(() {
                                          pin.clear();
                                          Navigator.pop(context);
                                        });
                                      }
                                    },
                                    child: Text('Ok!'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          setState(() {
                            editing = true;
                          });
                        }
                      },
                      label: Text(editing ? "Salvar Alterações" : "Editar"),
                      icon: Icon(editing ? Icons.save : Icons.edit),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                width: 1,
                                color: ColorScheme.of(context).inverseSurface,
                              ),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(children: [Text("Meu Perfil")]),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                width: 1,
                                color: ColorScheme.of(context).inverseSurface,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text("Informações Pessoais"),
                                    contentPadding: EdgeInsets.all(0),
                                  ),
                                  ...fields.map(
                                    (e) => ListTile(
                                      contentPadding: EdgeInsets.all(0),
                                      title: Text(labels[fields.indexOf(e)]),
                                      subtitle: TextField(
                                        controller: e,
                                        enabled: editing,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text("Informações Educacionais"),
                                    contentPadding: EdgeInsets.all(0),
                                  ),
                                  ListTile(
                                    title: Text("Escola SENAI"),
                                    contentPadding: EdgeInsets.all(0),
                                    subtitle: DropdownButton(
                                      items: [
                                        ...escolas.map(
                                          (e) => DropdownMenuItem(
                                            value: e['id'],
                                            child: Text(e['name'].toString()),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (!editing) return;

                                        meCopy['escolaId'] = value!;
                                        setState(() {});
                                      },
                                      value: meCopy['escolaId'],
                                    ),
                                  ),
                                  ListTile(
                                    title: Text("Modalidade Padrão"),
                                    contentPadding: EdgeInsets.all(0),
                                    subtitle: DropdownButton(
                                      items: [
                                        ...modalidades.map(
                                          (e) => DropdownMenuItem(
                                            value: e['id'],
                                            child: Text(e['title'].toString()),
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (!editing) return;
                                        meCopy['modalidadeId'] = value!;
                                        setState(() {});
                                      },
                                      value: meCopy['modalidadeId'],
                                    ),
                                  ),
                                  ListTile(
                                    title: Text("Modalidades Favoritas"),
                                    contentPadding: EdgeInsets.all(0),
                                    subtitle: ReorderableListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        final m = modalidades.firstWhere(
                                          (element) =>
                                              element['id'].toString() ==
                                              favorites[index],
                                          orElse: () => {},
                                        );

                                        return ListTile(
                                          key: Key(m['id'].toString()),
                                          title: Text(m['title'].toString()),
                                          trailing: Icon(Icons.reorder),
                                        );
                                      },
                                      itemCount: favorites.length,
                                      onReorder: (oldIndex, newIndex) async {
                                        final item = favorites.removeAt(
                                          oldIndex,
                                        );
                                        favorites.insert(newIndex, item);

                                        meCopy['modalidadeId'] = int.parse(
                                          favorites[0],
                                        );

                                        final share =
                                            await SharedPreferences.getInstance();

                                        await share.setStringList(
                                          'favs',
                                          favorites,
                                        );
                                        setState(() {});
                                      },
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
                ],
              ),
            ),
          );
  }
}
