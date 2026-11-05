import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> me;

  const Profile({super.key, required this.me});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final key = GlobalKey();

  final bio = TextEditingController();
  bool editing = false;

  Future<void> startApp() async {
    bio.text = "No bio yet...";
    setState(() {});
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
      appBar: AppBar(title: Text("Meu Perfil")),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            RepaintBoundary(
              key: key,
              child: ListTile(
                contentPadding: EdgeInsets.all(0),
                title: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(widget.me['nome']),
                  subtitle: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.me['modalidade']),
                    ),
                  ),
                ),
                subtitle: Text(widget.me['escola']),
                trailing: CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/users/${widget.me['foto'].toString()}',
                  ),
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final object =
                          key.currentContext!.findRenderObject()
                              as RenderRepaintBoundary;

                      final image = await object.toImage();
                      final bytes = await image.toByteData(
                        format: ImageByteFormat.png,
                      );

                      final file =
                          "/storage/emulated/0/Download/${DateTime.now().millisecondsSinceEpoch.toString()}.png";

                      await File(file)
                          .writeAsBytes(bytes!.buffer.asUint8List());

                      Fluttertoast.showToast(
                        msg: 'Salvo em $file',
                        backgroundColor: Colors.green,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: 'Use um emulador $e',
                        backgroundColor: Colors.red,
                      );
                      print(e);
                    }
                  },
                  child: Text("Baixar dados"),
                ),
              ],
            ),
            Card(
              child: ListTile(
                title: Text("Sobre mim"),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      editing = !editing;
                    });
                  },
                  icon: Icon(!editing ? Icons.edit : Icons.save),
                ),
                subtitle: TextField(controller: bio, enabled: editing),
              ),
            ),
            Card(
              child: ListTile(
                title: Text("Informações"),
                subtitle: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Unidade"),

                      trailing: Text(widget.me['escola']),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Modalidade"),

                      trailing: Text(widget.me['modalidade']),
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
