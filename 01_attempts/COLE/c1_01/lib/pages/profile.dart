import 'dart:io';

import 'package:c1_01/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> me;

  const Profile({super.key, required this.me});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> startApp() async {}
  @override
  void initState() {
    super.initState();
    startApp();
  }

  File? file;
  bool notifications = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text("Perfil do Usuário", style: TextStyle(color: Colors.green)),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/icons/FotoUsuario.jpg'),
          ),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 90,
                    backgroundImage: file != null
                        ? FileImage(file!)
                        : AssetImage('assets/icons/FotoUsuario.jpg'),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );

                        if (image != null) {
                          setState(() {
                            file = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("Nome: ${widget.me['nome']}"),
              subtitle: Text("E-mail: ${widget.me['email']}"),
            ),
            Row(
              spacing: 20,
              children: [
                Expanded(
                  child: ListTile(
                    tileColor: Colors.white,
                    title: Text("Total de Coletas"),
                    subtitle: Text("18"),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    tileColor: Colors.white,
                    title: Text("Total de Entulho"),
                    subtitle: Text("24.5 Ton"),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    tileColor: Colors.white,
                    title: Text("Pt. Mini Game"),
                    subtitle: Text("108pts"),
                  ),
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text("Dados Pessoais"),
              subtitle: Text("Nome, e-mail e gerenciamento de senhas"),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Notificações"),
              subtitle: Text("Alertas de caminhao e agendamentos"),
              trailing: Switch(
                value: notifications,
                onChanged: (value) {
                  setState(() {
                    notifications = value;
                  });
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text("Termos de Uso e Política"),
              subtitle: Text("Privacidade e diretrizes municipais"),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Sair da Conta", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
