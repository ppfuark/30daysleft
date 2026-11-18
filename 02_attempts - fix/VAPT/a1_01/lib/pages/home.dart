import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
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
            products = json1;
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

  final serch = TextEditingController();

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
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              title: Text("VaptFood"),
              actions: [Image.asset('assets/icones/Bell off.png')],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  children: [
                    CupertinoSearchTextField(
                      controller: serch,
                      placeholder: "Buscar comida, restaurantes...",
                    ),
                    ListTile(
                      title: Text(
                        "Categorias",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text("Ver tudo"),
                      contentPadding: EdgeInsets.all(0),
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Image.asset('assets/hamburguer.png'),
                                Text("Hambúguer"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Image.asset('assets/pizza.png'),
                                Text("Pizza"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Image.asset('assets/sobremesa.png'),
                                Text("Sobremesas"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            child: Column(
                              children: [
                                Image.asset('assets/japonesa.png'),
                                Text("Japonesa"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      'assets/50_Off.png',
                      fit: BoxFit.fill,
                      width: double.infinity,
                    ),
                    ListTile(
                      title: Text(
                        "Restaurantes populares",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text("Ver tudo"),
                      subtitle: Text("Clique para ver o detalhe de um produto"),
                      contentPadding: EdgeInsets.all(0),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final r = restaurants[index];

                        final p = products.firstWhere(
                          (element) => element['restaurantId'] == r['id'],
                          orElse: () => {},
                        );

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Details(product: p),
                              ),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(r['name'].toString()),
                                    subtitle: Text(
                                      r['deliveryTime'].toString(),
                                    ),
                                    trailing: Column(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber),
                                        Text(r['rating'].toString()),
                                      ],
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/${r['image']}',
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  ListTile(
                                    title: Text(
                                      "Descrição: ${p['description']}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: restaurants.length,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

class Details extends StatefulWidget {
  final Map<String, dynamic> product;

  const Details({super.key, required this.product});
  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  String bebida = "cola";
  late double price = (widget.product['price']).toDouble() ?? 0.0;
  int qnt = 1;

  Future<void> startApp() async {
    try {
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
            appBar: AppBar(title: Text(widget.product['name'].toString())),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    Image.asset(
                      'assets/${widget.product['image']}',
                      height: 200,
                    ),
                    ListTile(
                      title: Text("Descrição Longa:"),
                      subtitle: Text(
                        widget.product['description'] ??
                            "KAMKANKAMNAKNAKNKANKANKANKANkNAKNKANKAN" * 10,
                      ),
                    ),
                    RadioGroup(
                      onChanged: (value) {
                        setState(() {
                          bebida = value.toString();
                        });
                      },
                      groupValue: bebida,
                      child: Column(
                        children: [
                          RadioListTile(
                            value: 'lara',
                            title: Text("Suco de Laranja"),
                          ),
                          RadioListTile(
                            value: 'cola',
                            title: Text("Coca-Cola"),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              qnt++;
                            });
                          },
                          child: Icon(Icons.add),
                        ),
                        Text((qnt * price).toStringAsFixed(2)),
                        ElevatedButton(
                          onPressed: () {
                            if (qnt == 0) {
                              return;
                            }

                            setState(() {
                              qnt--;
                            });
                          },
                          child: Icon(Icons.minimize),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final share = await SharedPreferences.getInstance();
                          final t = share.getString('token') ?? '';
                          final res = await http.post(
                            Uri.parse('http://10.109.66.126:3000/cart'),
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization': 'Bearer $t',
                            },
                            body: jsonEncode({
                              "productId": widget.product['id'],
                              "quantity": qnt,
                            }),
                          );
                          if (res.statusCode == 201) {
                            setState(() {
                              Fluttertoast.showToast(
                                msg: 'Adicionado ao carrinho!',
                                backgroundColor: Colors.green,
                              );
                              Navigator.pop(context);
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
                      child: Text("Adicionar ao Carrinho"),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
