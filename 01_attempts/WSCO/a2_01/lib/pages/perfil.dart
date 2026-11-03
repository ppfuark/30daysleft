import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:a2_01/app.dart';
import 'package:a2_01/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  final Function onTap;

  const Perfil({super.key, required this.onTap});
  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  bool loadin = true;

  List modalidades = [];
  List comentarios = [];
  List competidores = [];
  List escolas = [];
  List medals = [];
  List<String> favs = [];
  dynamic me = {};
  List<dynamic> categorias = [];

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token');

    final response = await http.get(
      Uri.parse('http://192.168.56.1:3000/modalidades'),
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
      Uri.parse('http://192.168.56.1:3000/categorias'),
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
      Uri.parse('http://192.168.56.1:3000/comentarios'),
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
      Uri.parse('http://192.168.56.1:3000/medalhas'),
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
      Uri.parse('http://192.168.56.1:3000/competidores'),
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
      Uri.parse('http://192.168.56.1:3000/competidores/me'),
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
    final response6 = await http.get(
      Uri.parse('http://192.168.56.1:3000/escolas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response6.statusCode == 200) {
      setState(() {
        escolas = jsonDecode(response6.body);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }

    favs = sharedPreferences.getStringList('favs') ?? [];

    setState(() {
      inputs[0].text = me['name'];
      inputs[1].text = me['email'];
      inputs[2].text = me['birthdate'];
      inputs[3].text = me['phone'];
    });

    if (me['name'].toString().isNotEmpty) {
      setState(() {
        progress += 0.2;
      });
    }
    if (me['email'].toString().isNotEmpty) {
      setState(() {
        progress += 0.2;
      });
    }
    if (me['birthdate'].toString().isNotEmpty) {
      setState(() {
        progress += 0.2;
      });
    }
    if (me['phone'].toString().isNotEmpty) {
      setState(() {
        progress += 0.2;
      });
    }
    if (me['modalidadeId'].toString().isNotEmpty) {
      setState(() {
        progress += 0.1;
      });
    }
    if (me['escolaId'].toString().isNotEmpty) {
      setState(() {
        progress += 0.1;
      });
    }

    setState(() {
      loadin = false;
    });
  }

  @override
  void initState() {
    super.initState();
    startApp();
  }

  bool editing = true;
  double progress = 0.0;

  List labs = ["Nome Completo", "E-mail", "Data de Nascimento", "Telefone"];

  List inputs = [
    TextEditingController(),
    TextEditingController(),
    MaskedTextController(mask: '00/00/0000'),
    MaskedTextController(mask: '(00) 00000-0000'),
  ];
  final pin = TextEditingController();
  File? file;

  late final meCopy = Map<String, dynamic>.from(me);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            widget.onTap();
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
              App.theme.value == App.dark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.person)),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: loadin
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      "Editar Perfil",
                      style: TextStyle(fontSize: 30),
                    ),
                    subtitle: Text(
                      "Gerencie suas informações pessoais e educacionais.",
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (editing) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("PIN"),
                              content: TextField(
                                controller: pin,
                                decoration: InputDecoration(hintText: "1234"),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () async {
                                    if (pin.text == '1234') {
                                      final SharedPreferences
                                      sharedPreferences =
                                          await SharedPreferences.getInstance();
                                      final t = sharedPreferences.getString(
                                        'token',
                                      );
                                      final response = await http
                                          .patch(
                                            Uri.parse(
                                              'http://192.168.56.1:3000/competidores/me',
                                            ),
                                            headers: {
                                              "Content-Type":
                                                  "application/json",
                                              'Authorization': 'Bearer $t',
                                            },
                                            body: jsonEncode(meCopy),
                                          )
                                          .timeout(Duration(seconds: 5));
                                      if (response.statusCode == 200) {
                                        startApp();
                                        Fluttertoast.showToast(
                                          msg: "Dados atualizado com sucesso",
                                          backgroundColor: Colors.green,
                                        );

                                        setState(() {
                                          editing = false;
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "Erro: ${response.body}",
                                          backgroundColor: Colors.red,
                                        );
                                        print(response.body);
                                      }
                                    }
                                    setState(() {
                                      pin.clear();
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text("Salvar!"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          setState(() {
                            editing = true;
                          });
                        }
                      },
                      child: Text(
                        editing ? "Salvar Alterações" : "Editar Perfil",
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text(
                                      "Meu Perfil",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Padding(
                                            padding: EdgeInsetsGeometry.all(10),
                                            child: CircleAvatar(
                                              backgroundImage: file != null
                                                  ? FileImage(file!)
                                                  : AssetImage(
                                                      'assets/avatar-teste.jpg',
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 7,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text(
                                      me['name'].toString(),
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text(
                                      modalidades
                                          .where(
                                            (element) =>
                                                element['id'] ==
                                                me['modalidadeId'],
                                          )
                                          .first['title']
                                          .toString(),
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: !editing
                                        ? null
                                        : () async {
                                            final image = await ImagePicker()
                                                .pickImage(
                                                  source: ImageSource.gallery,
                                                );

                                            if (image != null) {
                                              setState(() {
                                                file = File(image.path);
                                              });
                                            }
                                          },
                                    child: Text("Alterar foto"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
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
                                            "Informações Pessoais",
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),

                                        ...inputs.map(
                                          (e) => TextField(
                                            enabled: editing,
                                            controller: e,
                                            decoration: InputDecoration(
                                              hintText: labs[inputs.indexOf(e)],
                                            ),
                                          ),
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
                                            "Informações Educacionais",
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            DropdownButton(
                                              items: [
                                                ...escolas.map(
                                                  (e) => DropdownMenuItem(
                                                    value: e['id'],
                                                    child: Text(
                                                      e['name'].toString(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              value: meCopy['escolaId'],
                                              onChanged: (value) {
                                                if (editing) {
                                                  meCopy['escolaId'] = value;
                                                  setState(() {});
                                                }
                                              },
                                            ),
                                            DropdownButton(
                                              items: [
                                                ...modalidades.map(
                                                  (e) => DropdownMenuItem(
                                                    value: e['id'],
                                                    child: Text(
                                                      e['title'].toString(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              value: meCopy['modalidadeId'],
                                              onChanged: (value) {
                                                if (editing) {
                                                  meCopy['modalidadeId'] =
                                                      value;
                                                  setState(() {});
                                                }
                                              },
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
                                            "Informações Pessoais",
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),

                                        ReorderableListView.builder(
                                          shrinkWrap: true,
                                          onReorderItem: (oldIndex, newIndex) {
                                            final item = favs.removeAt(
                                              oldIndex,
                                            );
                                            favs.insert(newIndex, item);
                                          },
                                          itemBuilder: (context, index) {
                                            final e = modalidades
                                                .where(
                                                  (element) => favs.contains(
                                                    element['id'].toString(),
                                                  ),
                                                )
                                                .toList()[index];

                                            return ListTile(
                                              leading: Icon(Icons.reorder),
                                              key: Key(e['id'].toString()),
                                              title: Text(
                                                e['title'].toString(),
                                              ),
                                            );
                                          },
                                          itemCount: modalidades
                                              .where(
                                                (element) => favs.contains(
                                                  element['id'].toString(),
                                                ),
                                              )
                                              .length,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
