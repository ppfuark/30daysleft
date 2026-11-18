import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Colab extends StatefulWidget {
  final Function onTap;

  const Colab({super.key, required this.onTap});
  @override
  State<Colab> createState() => _ColabState();
}

class _ColabState extends State<Colab> {
  List colabs = [];

  void startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://10.109.66.126:8080/api/v1/colaboradores'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print(response.body);

      setState(() {
        colabs = jsonDecode(response.body)['data'];
      });
    } else {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startApp();
  }

  String radioValue = "supervisor";
  List<String> levels = ["operador", "supervisor", "gestor"];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Colaboradores"),
        actions: [
          ElevatedButton(
            onPressed: () {
              widget.onTap();
            },
            child: Text("Voltar"),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                App.toogle();
              });
            },
            icon: Icon(
              App.valueNotifier.value == App.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: ReorderableListView.builder(
          itemBuilder: (context, index) {
            final c = colabs[index];

            return GestureDetector(
              key: Key(c['id'].toString()),
              onDoubleTap: () {
                if (c['nivel'] == "gestor") {
                  Fluttertoast.showToast(
                    msg: 'Este colaborador já possui o nível máximo (Gestor)',
                    backgroundColor: Colors.red,
                  );
                } else if (c['nivel'] == "operador") {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Deseja promover ${c['nome'].toString()} para Supervisor?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                c['nivel'] = "supervisor";
                                final share =
                                    await SharedPreferences.getInstance();
                                final t = share.getString('token') ?? '';
                                final res = await http.patch(
                                  Uri.parse(
                                    'http://10.109.66.126:8080/api/v1/colaboradores/${c['id']}',
                                  ),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $t',
                                  },
                                  body: jsonEncode(c),
                                );
                                if (res.statusCode == 200) {
                                  Fluttertoast.showToast(
                                    msg: "Sucesso!",
                                    backgroundColor: Colors.green,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: res.body,
                                    backgroundColor: Colors.red,
                                  );
                                }
                                setState(() {});
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Erro ao realizar put: e'),
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
                            },
                            child: Text('Confirmar'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          'Deseja promover ${c['nome'].toString()} para Gestor?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                c['nivel'] = "gestor";
                                final share =
                                    await SharedPreferences.getInstance();
                                final t = share.getString('token') ?? '';
                                final res = await http.patch(
                                  Uri.parse(
                                    'http://10.109.66.126:8080/api/v1/colaboradores/${c['id']}',
                                  ),
                                  headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': 'Bearer $t',
                                  },
                                  body: jsonEncode(c),
                                );
                                if (res.statusCode == 200) {
                                  Fluttertoast.showToast(
                                    msg: "Sucesso!",
                                    backgroundColor: Colors.green,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: res.body,
                                    backgroundColor: Colors.red,
                                  );
                                }
                                setState(() {});
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Erro ao realizar put: e'),
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
                            },
                            child: Text('Confirmar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, s) {
                          return AlertDialog(
                            title: Text('Detalhes #0${c['id']}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(c['nome'].toString()),
                                  trailing: Chip(label: Text(c['nivel'])),
                                  leading: Image.network(c['avatar']),
                                  subtitle: ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    title: Text(c['cargo']),
                                    subtitle: Text(
                                      c['dataCadastro'].toString().replaceAll(
                                        '-',
                                        '/',
                                      ),
                                    ),
                                  ),
                                ),
                                RadioGroup(
                                  onChanged: (value) async {
                                    setState(() {
                                      radioValue = value.toString();
                                    });
                                    try {
                                      c['nivel'] = radioValue;
                                      final share =
                                          await SharedPreferences.getInstance();
                                      final t = share.getString('token') ?? '';
                                      final res = await http.patch(
                                        Uri.parse(
                                          'http://10.109.66.126:8080/api/v1/colaboradores/${c['id']}',
                                        ),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': 'Bearer $t',
                                        },
                                        body: jsonEncode(c),
                                      );
                                      if (res.statusCode == 200) {
                                        Fluttertoast.showToast(
                                          msg: "Sucesso!",
                                          backgroundColor: Colors.green,
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: res.body,
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                      setState(() {});
                                    } catch (e) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                              'Erro ao realizar put: e',
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
                                    s(() {});
                                  },
                                  groupValue: radioValue,
                                  child: Column(
                                    children: [
                                      ...levels.map(
                                        (e) => RadioListTile(
                                          value: e,
                                          title: Text(e.toUpperCase()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                    },
                  );
                },
                tileColor: c['status'] == "afastado" ? Color(0x15F4A300) : null,
                key: Key(c['id'].toString()),
                title: Text(
                  c['nome'].toString(),
                  style: TextStyle(
                    fontStyle: c['status'] == "afastado"
                        ? FontStyle.italic
                        : null,
                    color: c['status'] == "afastado" ? Colors.grey : null,
                  ),
                ),
                trailing: Chip(label: Text(c['nivel'])),
                leading: Image.network(c['avatar']),
                subtitle: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(c['cargo']),
                  subtitle: Text(
                    c['dataCadastro'].toString().replaceAll('-', '/'),
                  ),
                  leading: Chip(label: Text(c['status'])),
                ),
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;

            final item = colabs.removeAt(oldIndex);
            colabs.insert(newIndex, item);
            setState(() {});
          },
          itemCount: colabs.length,
        ),
      ),
    );
  }
}
