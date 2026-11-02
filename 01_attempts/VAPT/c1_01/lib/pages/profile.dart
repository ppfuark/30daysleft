import 'dart:io';

import 'package:c1_01/app.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? file;

  bool not = false;
  bool con = false;

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
      appBar: AppBar(title: Text("Delivery_OS")),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CircleAvatar(
                      backgroundImage: file == null ? null : FileImage(file!),
                      backgroundColor: Colors.grey.shade300,
                      child: file == null ? Icon(Icons.person, size: 90) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      color: Colors.deepOrange,
                      onPressed: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );

                        if (image != null) {
                          setState(() {
                            file = File(image.path);
                          });
                        }
                      },
                      icon: Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              label: Text("Editar Perfil"),
              icon: Icon(Icons.edit),
            ),
            ListTile(
              title: Text("PEDIDOS FINALIZADOS"),
              subtitle: Text(
                "42",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              trailing: FaIcon(FontAwesomeIcons.checkDouble),
            ),
            Column(
              children: [
                ListTile(
                  title: Text("KM PERCORRIDOS"),
                  subtitle: Text(
                    "128,5",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.route),
                ),
                ListTile(
                  leading: Icon(Icons.dark_mode_outlined),
                  title: Text("Tema Escuro"),
                  trailing: Switch(
                    value: App.theme.value == App.dark,
                    onChanged: (value) {
                      setState(() {
                        App.toogle();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.contrast),
                  title: Text("Alto Contraste"),
                  trailing: Switch(
                    value: con,
                    onChanged: (value) {
                      setState(() {
                        con = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Notificações"),
                  trailing: Switch(
                    value: not,
                    onChanged: (value) {
                      setState(() {
                        not = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text("Idioma: Português (automático)"),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),

            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.logout), Text("Encerrar")],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
