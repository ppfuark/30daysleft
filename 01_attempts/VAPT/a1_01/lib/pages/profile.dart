import 'dart:convert';

import 'package:a1_01/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  final Function onTap;

  const Profile({super.key, required this.onTap});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  dynamic me;
  List products = [];
  List restaurants = [];
  List categories = [];
  List recents = [];

  bool loading = true;

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token') ?? "";

    final response0 = await http.get(
      Uri.parse('http://192.168.233.50:3000/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    print(t);

    print(response0.body);
    if (response0.statusCode == 200) {
      setState(() {
        me = jsonDecode(response0.body);
      });
    }

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

    final response3 = await http.get(
      Uri.parse('http://192.168.233.50:3000/recentOrders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        products = jsonDecode(response.body);
      });
    }
    if (response1.statusCode == 200) {
      setState(() {
        restaurants = jsonDecode(response1.body);
      });
    }
    if (response2.statusCode == 200) {
      setState(() {
        categories = jsonDecode(response2.body);
      });
    }
    print(response3.body);
    if (response3.statusCode == 200) {
      setState(() {
        recents = jsonDecode(response3.body);
      });
    }

    setState(() {
      loading = false;
    });
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
        leading: Icon(Icons.person),
        title: Text("VaptFood"),
        actions: [
          Image.asset(
            height: 30,
            'assets/icones/${me['notifications'] ? "Bell.png" : "Bell off.png"}',
          ),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: loading
            ? CircularProgressIndicator()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Text(
                    "Perfil",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/${me['avatar']}'),
                    ),
                    title: Text(me['name']),
                    subtitle: Text(me['email']),
                  ),

                  Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text("Informações Pessoais"),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.location_pin),
                          title: Text("Endereços Salvos"),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.credit_card),
                          title: Text("Métodos de Pagamento"),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            "Sair",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            final SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            await sharedPreferences.setString('token', "");

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.watch_later),
                            title: Text("Pedidos Recentes".toUpperCase()),
                          ),
                          Divider(),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                spacing: 10,
                                children: [
                                  ...recents.map(
                                    (e) => ListTile(
                                      title: ListTile(
                                        title: Text(e['restaurant'].toString()),
                                        subtitle: Text(
                                          "Pedido#${e['id']} ▪ ${e['date']}",
                                        ),
                                        contentPadding: EdgeInsets.all(0),
                                        trailing: Chip(
                                          label: Text(e['status']),
                                        ),
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("R\$${e['total']}"),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final SharedPreferences
                                              sharedPreferences =
                                                  await SharedPreferences.getInstance();
                                              final t =
                                                  sharedPreferences.getString(
                                                    'token',
                                                  ) ??
                                                  "";

                                              for (var element in e['items']) {
                                                final response = await http.post(
                                                  Uri.parse(
                                                    'http://192.168.233.50:3000/cart',
                                                  ),
                                                  headers: {
                                                    'Content-Type':
                                                        'application/json',
                                                    'Authorization':
                                                        "Bearer $t",
                                                  },
                                                  body: jsonEncode({
                                                    'productId':
                                                        element['productId'],
                                                    'quantity':
                                                        element['quantity'],
                                                  }),
                                                );
                                                if (response.statusCode ==
                                                        200 ||
                                                    response.statusCode ==
                                                        201) {
                                                  Fluttertoast.showToast(
                                                    msg: 'Enviado para o carrinho.',
                                                    backgroundColor:
                                                        Colors.green,
                                                  );
                                                  widget.onTap();
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Erro ${response.body}.',
                                                    backgroundColor: Colors.red,
                                                  );
                                                }
                                              }
                                            },
                                            child: Text("Refazer Pedido"),
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
                  ),
                ],
              ),
      ),
    );
  }
}
