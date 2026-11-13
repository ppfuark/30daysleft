import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});
  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List recents = [];
  dynamic me = {};

  Future<void> startApp() async {
    try {
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/profile'),
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
        } else {}

        final res1 = await http.get(
          Uri.parse('http://10.109.66.126:3000/cart'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json1 = jsonDecode(res1.body);
        if (res1.statusCode == 200) {
          setState(() {
            recents = json1;
          });
        } else {}

        double temp = 0.0;

        for (var element in recents) {
          temp += element['price'] * element['quantity'];
        }
        setState(() {
          total = temp;
        });
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro ao realizar get: e'),
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

  bool cut = false;
  double total = 0.0;

  @override
  Widget build(BuildContext context) {
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
            appBar: AppBar(
              title: Text("Carrinho"),
              actions: [
                CircleAvatar(backgroundImage: AssetImage('assets/avatar.png')),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    ListTile(
                      leading: Icon(Icons.swipe_left),
                      title: Text("Deslize para remover"),
                    ),
                    ListView.builder(
                      itemBuilder: (context, index) {
                        final p = recents[index];

                        return Dismissible(
                          onDismissed: (direction) async {
                            try {
                              final share =
                                  await SharedPreferences.getInstance();
                              final t = share.getString('token') ?? '';
                              final res = await http.delete(
                                Uri.parse(
                                  'http://10.109.66.126:3000/cart/${p['id']}',
                                ),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $t',
                                },
                              );
                              if (res.statusCode == 200) {
                                Fluttertoast.showToast(
                                  msg: 'Removido',
                                  backgroundColor: Colors.green,
                                );
                                recents.remove(p);
                                setState(() {});
                                startApp();
                              } else {}
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Erro ao realizar delete: e'),
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
                          direction: DismissDirection.endToStart,
                          background: Container(color: Colors.red),
                          key: Key(p['id'].toString()),
                          child: ListTile(
                            leading: Image.asset('assets/${p['image']}'),
                            title: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text(p['name'].toString()),
                              subtitle: Text(p['description'].toString()),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "R\$ ${(p['price'] * p['quantity']).toStringAsFixed(2).replaceAll(".", ",")}",
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        try {
                                          final share =
                                              await SharedPreferences.getInstance();
                                          final t =
                                              share.getString('token') ?? '';
                                          final res = await http.put(
                                            Uri.parse(
                                              'http://10.109.66.126:3000/cart/${p['id']}',
                                            ),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization': 'Bearer $t',
                                            },
                                            body: jsonEncode({
                                              "quantity": p['quantity'] + 1,
                                            }),
                                          );
                                          if (res.statusCode == 200) {
                                            Fluttertoast.showToast(
                                              msg: 'Adicionado',
                                              backgroundColor: Colors.green,
                                            );
                                            startApp();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: 'Erro: ${res.body} ',
                                              backgroundColor: Colors.red,
                                            );
                                          }
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
                                      },
                                      child: Icon(Icons.add),
                                    ),
                                    Text(p['quantity'].toString()),
                                    GestureDetector(
                                      onTap: () async {
                                        try {
                                          final share =
                                              await SharedPreferences.getInstance();
                                          final t =
                                              share.getString('token') ?? '';
                                          final res = await http.put(
                                            Uri.parse(
                                              'http://10.109.66.126:3000/cart/${p['id']}',
                                            ),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization': 'Bearer $t',
                                            },
                                            body: jsonEncode({
                                              "quantity": p['quantity'] - 1,
                                            }),
                                          );
                                          if (res.statusCode == 200) {
                                            Fluttertoast.showToast(
                                              msg: 'Diminuido',
                                              backgroundColor: Colors.green,
                                            );
                                            startApp();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: 'Erro: ${res.body} ',
                                              backgroundColor: Colors.red,
                                            );
                                          }
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
                                      },
                                      child: Icon(Icons.minimize),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: recents.length,
                      shrinkWrap: true,
                    ),
                    ListTile(title: Text("Adicionar talheres descartáveis? ")),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          cut = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: cut ? Colors.white : Colors.black,
                          border: cut ? Border.all() : null,
                        ),
                        child: Center(
                          child: Text(
                            "Não, obrigado",
                            style: TextStyle(
                              color: cut ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          cut = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: !cut ? Colors.white : Colors.black,
                          border: !cut ? Border.all() : null,
                        ),
                        child: Center(
                          child: Text(
                            "Sim, por favor",
                            style: TextStyle(
                              color: !cut ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(border: Border.all()),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            loading = true;
                          });
                          await Future.delayed(Duration(seconds: 1));
                          startApp();
                        },
                        child: Column(
                          spacing: 0,
                          children: [
                            ListTile(
                              tileColor: Colors.white,
                              title: Text("Subtotal"),
                              trailing: Text(
                                "R\$ ${total.toStringAsFixed(2).replaceAll(".", ",")}",
                              ),
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              title: Text("Desconto (50% OFF)"),
                              trailing: Text(
                                "- R\$ ${(total / 2).toStringAsFixed(2).replaceAll(".", ",")}",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              title: Text("Taxa de Entrega"),
                              trailing: Text(
                                "R\$ ${7.toStringAsFixed(2).replaceAll(".", ",")}",
                              ),
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              title: Text(
                                "Total",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                "R\$ ${(total / 2).toStringAsFixed(2).replaceAll(".", ",")}",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final share = await SharedPreferences.getInstance();
                          final t = share.getString('token') ?? '';
                          final res = await http.post(
                            Uri.parse('http://10.109.66.126:3000/orders'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $t',
                            },
                            body: jsonEncode({"cutlery": cut}),
                          );
                          if (res.statusCode == 201) {
                            setState(() {
                              Fluttertoast.showToast(
                                msg: 'Pedido reefeito!',
                                backgroundColor: Colors.green,
                              );
                            });
                            startApp();
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Erro: ${res.body}',
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
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(color: Colors.black),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Finalizar Pedido",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                "R\$ ${(total / 2).toStringAsFixed(2).replaceAll(".", ",")}",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
