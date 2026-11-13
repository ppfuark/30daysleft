import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List products = [];
  List restaurants = [];
  List categories = [];

  final search = TextEditingController();

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://192.168.233.50:3000/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    final response1 = await http.get(
      Uri.parse('http://192.168.233.50:3000/restaurants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    final response2 = await http.get(
      Uri.parse('http://192.168.233.50:3000/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    }
    // print(response1.body);
    if (response1.statusCode == 200) {
      setState(() {
        restaurants = jsonDecode(response1.body);
      });
    }
    // print(response2.body);
    if (response2.statusCode == 200) {
      setState(() {
        categories = jsonDecode(response2.body);
      });
    }
  }

  String selected = "1";

  @override
  void initState() {
    startApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.person),
        title: Text("VaptFood"),
        actions: [Icon(Icons.notifications)],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          spacing: 10,
          children: [
            CupertinoSearchTextField(
              controller: search,
              placeholder: "Buscar pratos...",
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 5,
                children: [
                  ...categories.map(
                    (e) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selected = e['id'].toString();
                        });
                      },
                      child: Chip(
                        label: Text(
                          e['name'],
                          style: TextStyle(
                            color: selected == e['id'].toString()
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        backgroundColor: selected != e['id'].toString()
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final p = products[index];

                  return p['featured'] ?? true
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  height: 100,
                                  'assets/${p['image'].toString()}',
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 90),
                                ),
                                ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        p['name'].toString(),
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        "R\$ ${p['price']}",
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(p['description'].toString()),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                    ),
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
                                          'http://192.168.233.50:3000/cart',
                                        ),
                                        headers: {
                                          'Content-Type': 'application/json',
                                          'Authorization': "Bearer $t",
                                        },
                                        body: jsonEncode({
                                          'productId': p['id'],
                                          'quantity': p['quantity'],
                                        }),
                                      );
                                      if (response.statusCode == 200 ||
                                          response.statusCode == 201) {
                                        Fluttertoast.showToast(
                                          msg: 'Enviado para o carrinho.',
                                          backgroundColor: Colors.green,
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Erro ${response.body}.',
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                                    child: Text(
                                      "Adicionar ao Carrinho",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  height: 100,
                                  'assets/${p['image'].toString()}',
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 90),
                                ),
                                ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        p['name'].toString(),
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        "R\$ ${p['price']}",
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(p['description'].toString()),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                    ),
                                    onPressed: () async {},
                                    child: Text(
                                      "Adicionar ao Carrinho",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                },
                itemCount: products.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
