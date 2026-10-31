import 'dart:convert';

import 'package:a1_01/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});
  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List cart = [];
  dynamic prefs;

  bool talh = false;

  bool loading = true;

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token') ?? "";

    final response0 = await http.get(
      Uri.parse('http://192.168.56.1:3000/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    if (response0.statusCode == 200) {
      setState(() {
        cart = jsonDecode(response0.body);
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }

    double temp = 0.0;
    for (var element in cart) {
      temp += element['price'] * element['quantity'];
    }
    setState(() {
      sub = temp;
    });
    setState(() {
      loading = false;
    });
  }

  double sub = 0.0;

  void soma(bool som, double value) {
    try {
      setState(() {
        if (som) {
          sub += value;
        } else {
          sub -= value;
        }
      });
      startApp();
    } catch (e) {
      print(e);
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
        leading: Icon(Icons.arrow_back),
        title: Text("Carrinho"),
        actions: [
          CircleAvatar(backgroundImage: AssetImage('assets/avatar.png')),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: loading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_left),
                        Text("Deslize para remover"),
                      ],
                    ),
                    ...cart.map(
                      (e) => Dismissible(
                        key: Key(e['id'].toString()),
                        background: Container(
                          color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Icon(Icons.delete, color: Colors.white)],
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          final t = sharedPreferences.getString('token') ?? "";

                          final response = await http.delete(
                            Uri.parse(
                              'http://192.168.56.1:3000/cart/${e['id']}',
                            ),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': "Bearer $t",
                            },
                          );
                          if (response.statusCode == 200 ||
                              response.statusCode == 201) {
                            Fluttertoast.showToast(
                              msg: 'Removido.',
                              backgroundColor: Colors.green,
                            );

                            cart.remove(e);
                            startApp();
                          } else {
                            Fluttertoast.showToast(
                              msg:
                                  'Erro ${jsonDecode(response.body)['message']}.',
                              backgroundColor: Colors.red,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(border: Border.all()),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: Image.asset(
                                'assets/${e['image']}',
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.broken_image, size: 40),
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(e['name'].toString()),
                            subtitle: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text(e['description'].toString()),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("R\$ ${e['price'].toStringAsFixed(2)}"),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          final SharedPreferences
                                          sharedPreferences =
                                              await SharedPreferences.getInstance();
                                          final t =
                                              sharedPreferences.getString(
                                                'token',
                                              ) ??
                                              "";

                                          final response = await http.post(
                                            Uri.parse(
                                              'http://192.168.56.1:3000/cart/${e['id']}',
                                            ),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization': "Bearer $t",
                                            },
                                            body: jsonEncode({
                                              'quantity': e['quantity'] - 1,
                                            }),
                                          );
                                          if (response.statusCode == 200 ||
                                              response.statusCode == 201) {
                                            Fluttertoast.showToast(
                                              msg: 'Removido.',
                                              backgroundColor: Colors.green,
                                            );
                                          } else {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Erro ${jsonDecode(response.body)['message']}.',
                                              backgroundColor: Colors.red,
                                            );
                                          }
                                          soma(false, e['price'].toDouble());
                                        },
                                        icon: Icon(Icons.minimize),
                                      ),
                                      Text(e['quantity'].toString()),
                                      IconButton(
                                        onPressed: () async {
                                          final SharedPreferences
                                          sharedPreferences =
                                              await SharedPreferences.getInstance();
                                          final t =
                                              sharedPreferences.getString(
                                                'token',
                                              ) ??
                                              "";

                                          final response = await http.post(
                                            Uri.parse(
                                              'http://192.168.56.1:3000/cart/${e['id']}',
                                            ),
                                            headers: {
                                              'Content-Type':
                                                  'application/json',
                                              'Authorization': "Bearer $t",
                                            },
                                            body: jsonEncode({
                                              'quantity': e['quantity'] + 1,
                                            }),
                                          );
                                          if (response.statusCode == 200 ||
                                              response.statusCode == 201) {
                                            Fluttertoast.showToast(
                                              msg: 'Adicionado.',
                                              backgroundColor: Colors.green,
                                            );
                                          } else {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Erro ${jsonDecode(response.body)['message']}.',
                                              backgroundColor: Colors.red,
                                            );
                                          }
                                          startApp();
                                        },
                                        icon: Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          talh = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: talh ? Colors.white : Colors.black,
                        ),
                        child: Center(
                          child: Text(
                            "Não, obrigado",
                            style: TextStyle(
                              color: !talh ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          talh = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: !talh ? Colors.white : Colors.black,
                        ),
                        child: Center(
                          child: Text(
                            "Sim, por favor",
                            style: TextStyle(
                              color: talh ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text("Subtotal"),
                      trailing: Text("R\$ $sub"),
                    ),
                    ListTile(
                      title: Text("Desconto (50% OFF)"),
                      trailing: Text(
                        "-R\$ ${sub / 2}",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    ListTile(
                      title: Text("Taxa de Entrega"),
                      trailing: Text("R\$ 7.00"),
                    ),
                    ListTile(
                      title: Text("Total"),
                      trailing: Text("R\$ ${sub / 2 + 7}"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final SharedPreferences sharedPreferences =
                            await SharedPreferences.getInstance();
                        final t = sharedPreferences.getString('token') ?? "";

                        final response = await http.post(
                          Uri.parse('http://192.168.56.1:3000/orders'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': "Bearer $t",
                          },
                        );
                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          Fluttertoast.showToast(
                            msg: 'Finalizado.',
                            backgroundColor: Colors.green,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg:
                                'Erro ${jsonDecode(response.body)['message']}.',
                            backgroundColor: Colors.red,
                          );
                        }
                        startApp();
                      },
                      child: Text("Finalizar Pedido"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
