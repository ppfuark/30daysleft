import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List products = [];
  List restaurants = [];
  List categories = [];

  final search = TextEditingController();

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://192.168.56.1:3000/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    final response1 = await http.get(
      Uri.parse('http://192.168.56.1:3000/restaurants'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    final response2 = await http.get(
      Uri.parse('http://192.168.56.1:3000/categories'),
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
    print(response1.body);
    if (response1.statusCode == 200) {
      setState(() {
        restaurants = jsonDecode(response1.body);
      });
    }
    print(response2.body);
    if (response2.statusCode == 200) {
      setState(() {
        categories = jsonDecode(response2.body);
      });
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
        leading: Icon(Icons.person),
        title: Text("VaptFood"),
        actions: [Icon(Icons.notifications)],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              CupertinoSearchTextField(controller: search),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Categorias",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text("Ver tudo", style: TextStyle(color: Colors.grey)),
                ],
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {
                  final data = categories[index];

                  return Card(
                    child: Column(
                      spacing: 10,
                      children: [
                        Expanded(child: Image.asset("assets/${data['icon']}")),
                        Text(data['name'].toString()),
                      ],
                    ),
                  );
                },
                itemCount: categories.length,
                shrinkWrap: true,
              ),
              Image.asset(width: double.infinity, "assets/50_Off.png"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Restaurantes Populares",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text("Ver tudo", style: TextStyle(color: Colors.grey)),
                ],
              ),
              ...restaurants.map(
                (e) => Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(e['name'].toString()),
                        subtitle: ListTile(
                          title: e['name'] == "Pizza Square"
                              ? Text(products[4]['description'].toString())
                              : Text(products.first['description'].toString()),
                          subtitle: Text(
                            "${categories.firstWhere((element) => element['id'].toString() == e['categoryId'].toString())['name'].toString()} ▪ ${e['deliveryTime'].toString()} ▪ R\$${e['deliveryFee'].toString()}",
                          ),
                          contentPadding: EdgeInsets.all(0),
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star),
                            Text(e['rating'].toString()),
                          ],
                        ),
                      ),
                      Image.asset(height: 200, "assets/${e['image']}"),
                    ],
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
