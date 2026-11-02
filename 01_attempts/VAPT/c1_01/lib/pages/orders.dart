import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Orders extends StatefulWidget {
  final List<Map<String, dynamic>> orders;

  const Orders({super.key, required this.orders});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  Future<void> startApp() async {}
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
        title: Text("PEDIDOS EM ANDAMENTO"),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              ...widget.orders.map(
                (e) => Opacity(
                  opacity: e['status'] == "Finalizado" ? 0.5 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("[ ${e['status'].toString()} ]"),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                    ),
                                    child: Text(e['id_pedido'].toString()),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e['restaurante'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  e['image'] == null
                                      ? IconButton(
                                          onPressed: () async {
                                            final image = await ImagePicker()
                                                .pickImage(
                                                  source: ImageSource.camera,
                                                );

                                            if (image != null) {
                                              setState(() {
                                                e['status'] = "Finalizado";
                                                e['image'] = image.path;
                                              });
                                            }
                                          },
                                          icon: Icon(Icons.camera_alt),
                                        )
                                      : CircleAvatar(
                                          backgroundImage: FileImage(
                                            File(e['image']),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.person_outline),
                              title: Text(e['cliente'].toString()),
                            ),
                            ListTile(
                              leading: Icon(Icons.lunch_dining_outlined),
                              title: Text(e['itens'].toString()),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_pin),
                              title: Text(e['endereco'].toString()),
                            ),
                          ],
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
