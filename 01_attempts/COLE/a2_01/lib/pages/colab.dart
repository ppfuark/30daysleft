import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/login.dart';
import 'package:flutter/material.dart';
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
      Uri.parse('http://192.168.56.1:8080/api/v1/colaboradores'),
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

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Colaboradores"),
        actions: [
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

            return ListTile(
              key: Key(c['id'].toString()),
              title: Text(c['nome'].toString()),
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
            );
          },
          onReorderItem: (oldIndex, newIndex) {
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
