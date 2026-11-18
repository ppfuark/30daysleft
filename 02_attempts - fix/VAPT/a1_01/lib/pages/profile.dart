import 'dart:convert';

import 'package:flutter/material.dart';
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
          Uri.parse('http://10.109.66.126:3000/recentOrders'),
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
              leading: GestureDetector(
                onTap: () {},
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
              ),
              title: Text("VaptFood"),
              actions: [
                me['notifications'] ?? false
                    ? Image.asset('assets/icones/Bell.png')
                    : Image.asset('assets/icones/Bell off.png'),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(10),
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
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        "Perfil",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('assets/avatar.png'),
                          ),
                          title: Text(me['name']),
                          subtitle: Text(me['email']),
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
                              leading: Icon(Icons.person),
                              title: Text("Informações Pessoais"),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(Icons.location_pin),
                              title: Text("Endereços Salvos"),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              leading: Icon(Icons.credit_card),
                              title: Text("Métodos de Pagamento"),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                            ListTile(
                              tileColor: Colors.white,
                              onTap: () async {
                                final share =
                                    await SharedPreferences.getInstance();
                                share.setString('token', "");

                                Navigator.pop(context);
                              },
                              leading: Icon(Icons.logout, color: Colors.red),
                              title: Text(
                                "Sair",
                                style: TextStyle(color: Colors.red),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        "Pedidos recentes".toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Colors.white,
                        ),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final r = recents[index];

                            return ListTile(
                              title: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Text(r['restaurant'].toString()),
                                trailing: Chip(label: Text(r['status'])),
                                subtitle: Text("#${r['id']}"),
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                spacing: 10,
                                children: [
                                  Text(
                                    "R\$ ${r['total'].toStringAsFixed(2).replaceAll(".", ",")}",
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        final share =
                                            await SharedPreferences.getInstance();
                                        final t =
                                            share.getString('token') ?? '';
                                        final res = await http.post(
                                          Uri.parse(
                                            'http://10.109.66.126:3000/orders/${r['id']}/reorder',
                                          ),
                                          headers: {
                                            'Content-Type': 'application/json',
                                            'Authorization': 'Bearer $t',
                                          },
                                        );
                                        if (res.statusCode == 201) {
                                          setState(() {
                                            Fluttertoast.showToast(
                                              msg: 'Pedido reefeito!',
                                              backgroundColor: Colors.green,
                                            );
                                          });
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
                                              title: Text(
                                                'Erro ao realizar post: $e',
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
                                    child: Container(
                                      width: 100,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Refazer Pedido",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: recents.length,
                          shrinkWrap: true,
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
