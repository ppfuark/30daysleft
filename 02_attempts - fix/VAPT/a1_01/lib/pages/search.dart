import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  final Function onTap;

  const Search({super.key, required this.onTap});
  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List restaurants = [];
  List products = [];

  Future<void> startApp() async {
    try {
      try {
        final share = await SharedPreferences.getInstance();
        final t = share.getString('token') ?? '';
        final res = await http.get(
          Uri.parse('http://10.109.66.126:3000/restaurants'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json = jsonDecode(res.body);
        if (res.statusCode == 200) {
          setState(() {
            restaurants = json;
          });
        } else {}

        final res1 = await http.get(
          Uri.parse('http://10.109.66.126:3000/products'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $t',
          },
        );
        final json1 = jsonDecode(res1.body);
        if (res1.statusCode == 200) {
          setState(() {
            products = [];
            products = [
              {
                "id": 0,
                "restaurantId": 0,
                "category": "string",
                "name": "Prato Principal Especial",
                "description":
                    "Descrição técnica do prato contendo os principais ingredientes e modo de preparo simplificado para visualização do catálogo.",
                "price": 59.90,
                "image": null,
                "available": true,
              },
              {
                "id": 0,
                "restaurantId": 0,
                "category": "string",
                "name": "Bruschetta de Pomodoro",
                "description": "ENTRADAS",
                "price": 24.00,
                "image": null,
                "available": false,
              },
            ];
            products += json1;
          });
        } else {
          Navigator.pop(context);
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

  final search = TextEditingController();

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
              leading: GestureDetector(
                onTap: () {
                  widget.onTap();
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
              ),
              title: Text("VaptFood"),
              actions: [Image.asset('assets/icones/Bell off.png')],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    loading = true;
                  });
                  await Future.delayed(Duration(seconds: 1));
                  startApp();
                },
                child: Column(
                  spacing: 20,
                  children: [
                    CupertinoSearchTextField(
                      controller: search,
                      placeholder: "Buscar pratos...",
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    Row(
                      spacing: 30,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(color: Colors.black),
                            child: Center(
                              child: Text(
                                "Hamburguers",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(border: Border.all()),
                            child: Center(child: Text("Bebidas")),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child:
                          products
                              .where(
                                (element) => element['name']
                                    .toString()
                                    .contains(search.text),
                              )
                              .isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Nenhum prato encontrado"),
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      await Future.delayed(
                                        Duration(seconds: 1),
                                      );
                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    child: Text("Tentar novamente"),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                final p = products
                                    .where(
                                      (element) => element['name']
                                          .toString()
                                          .contains(search.text),
                                    )
                                    .toList()[index];

                                // {
                                //   "id": 0,
                                //   "restaurantId": 0,
                                //   "category": "string",
                                //   "name": "Prato Principal Especial",
                                //   "description":
                                //       "Descrição técnica do prato contendo os principais ingredientes e modo de preparo simplificado para visualização do catálogo.",
                                //   "price": 59.90,
                                //   "image": null,
                                //   "available": true,
                                // },
                                // {
                                //   "id": 0,
                                //   "restaurantId": 0,
                                //   "category": "string",
                                //   "name": "Bruschetta de Pomodoro",
                                //   "description": "ENTRADAS",
                                //   "price": 24.00,
                                //   "image": null,
                                //   "available": false,
                                // },
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: w,
                                          height: 100,
                                          child: p['image'] == null
                                              ? Center(child: Icon(Icons.image))
                                              : Image.asset(
                                                  'assets/${p['image']}',
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Icon(
                                                        Icons.broken_image,
                                                      ),
                                                ),
                                        ),
                                        Divider(),
                                        if (p['available'] == false)
                                          Text(
                                            p['description'].toString(),
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ListTile(
                                          trailing: p['available'] == true
                                              ? Text(
                                                  "R\$ ${p['price'].toStringAsFixed(2).replaceAll('.', ',')}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                )
                                              : Text(""),
                                          title: Text(
                                            p['name'].toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: p['available'] == false
                                              ? Text(p['price'].toString())
                                              : Text(
                                                  p['description'].toString(),
                                                ),
                                        ),
                                        p['available'] == true
                                            ? GestureDetector(
                                                onTap: () async {
                                                  try {
                                                    final share =
                                                        await SharedPreferences.getInstance();
                                                    final t =
                                                        share.getString(
                                                          'token',
                                                        ) ??
                                                        '';
                                                    final res = await http.post(
                                                      Uri.parse(
                                                        'http://10.109.66.126:3000/cart',
                                                      ),
                                                      headers: {
                                                        'Content-Type':
                                                            'application/json',
                                                        'Authorization':
                                                            'Bearer $t',
                                                      },
                                                      body: jsonEncode({
                                                        "productId": p['id'],
                                                        "quantity": 1,
                                                      }),
                                                    );
                                                    if (res.statusCode == 201) {
                                                      setState(() {
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              'Adicionado ao carrinho!',
                                                          backgroundColor:
                                                              Colors.green,
                                                        );
                                                      });
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            'Erro: ${res.body}',
                                                        backgroundColor:
                                                            Colors.red,
                                                      );
                                                    }
                                                  } catch (e) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            'Erro ao realizar post: $e',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: Text(
                                                                'Ok!',
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Adicionar ao Carrinho",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                width: double.infinity,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  border: Border.all(),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Adicionar ao Carrinho",
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              shrinkWrap: true,
                              itemCount: products
                                  .where(
                                    (element) => element['name']
                                        .toString()
                                        .contains(search.text),
                                  )
                                  .length,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
