import 'dart:io';

import 'package:c1_01/pages/main_page.dart';
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
        child: ReorderableListView.builder(
          itemBuilder: (context, index) {
            final e = orders[index];

            return Opacity(
              opacity: e['status'] == "Finalizado" ? 0.5 : 1.0,
              key: Key(e['id_pedido'].toString()),
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(border: Border.all()),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    Column(
                      children: [
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("[ ${e['status'].toString()} ]"),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(border: Border.all()),
                                child: Text(e['id_pedido'].toString()),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e['restaurante'].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                          title: Container(
                            decoration: BoxDecoration(
                              color:
                                  e['itens']
                                      .toString()
                                      .split(',')
                                      .any(
                                        (element) =>
                                            int.parse(
                                              element
                                                  .toString()
                                                  .split('x')
                                                  .first,
                                            ) >
                                            1,
                                      )
                                  ? Colors.grey.shade300
                                  : null,
                            ),
                            child: Text(e['itens'].toString()),
                          ),
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
            );
          },
          shrinkWrap: true,
          itemCount: orders.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;

            final item = orders.removeAt(oldIndex);

            setState(() {
              orders.insert(newIndex, item);
            });
          },
        ),
      ),
    );
  }
}
