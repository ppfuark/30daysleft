import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Order extends StatefulWidget {
  const Order({super.key});
  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  List orders = [];

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token') ?? "";

    final response0 = await http.get(
      Uri.parse('http://192.168.56.1:3000/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );

    print(t);

    print(response0.body);
    if (response0.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response0.body);
      });
    }

    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();

    userP = await Geolocator.getCurrentPosition();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    startApp();
  }

  Position? userP;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text("Acompanhamento de Pedido", maxLines: 2),
        actions: [
          CircleAvatar(backgroundImage: AssetImage('assets/avatar.png')),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            children: [
              SizedBox(
                height: 300,
                child: userP == null
                    ? Center(child: Text("Aguardando posição do usuário..."))
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(userP!.latitude, userP!.longitude),
                        ),
                      ),
              ),
              ListTile(
                title: Text("Chegando em..."),
                subtitle: Text(
                  "${orders.firstWhere((element) => element['id'] == 8821)['estimatedMin']} - ${orders.firstWhere((element) => element['id'] == 8821)['estimatedMax']}min",
                ),
              ),
              ListTile(
                title: Text("Entregador"),
                subtitle: Text(
                  "${orders.firstWhere((element) => element['id'] == 8821)['courier']['name']} ",
                ),
                trailing: Icon(Icons.contact_emergency),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.phone, color: Colors.white),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {},
                label: Text(
                  "Pressione e segure para ligar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(title: Text("Resumo do Pedido #8821")),
              ...(orders.firstWhere(
                        (element) => element['id'] == 8821,
                      )['items'] ??
                      [])
                  .map(
                    (e) => ListTile(
                      title: Text(e['name']),
                      subtitle: Text("R\$${e['price']}"),
                    ),
                  ),

              ListTile(
                title: Text("Total"),
                trailing: Text(
                  "R\$ ${(orders.firstWhere((element) => element['id'] == 8821)['subtotal'] ?? 0) - (orders.firstWhere((element) => element['id'] == 8821)['coupon'] ?? 0)}",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
