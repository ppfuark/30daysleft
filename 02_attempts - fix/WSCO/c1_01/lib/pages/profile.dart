import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> me;

  const Profile({super.key, required this.me});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
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

  final key = GlobalKey();
  final bio = TextEditingController(text: 'No bio yet');
  bool editing = false;

  File? image;

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
              title: Text("Meu Perfil"),
              automaticallyImplyLeading: false,
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: key,
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Card(
                        child: Row(
                          spacing: 20,
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(widget.me['nome'].toString()),
                                subtitle: ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  title: Text(widget.me['escola'].toString()),
                                  subtitle: Text(
                                    widget.me['modalidade'].toString(),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              width: 80,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CircleAvatar(
                                      backgroundImage: image != null
                                          ? FileImage(image!)
                                          : AssetImage(
                                              'assets/users/${widget.me['foto']}',
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) =>
                                              CupertinoActionSheet(
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final image =
                                                          await ImagePicker()
                                                              .pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .camera,
                                                              );

                                                      if (image != null) {
                                                        setState(() {
                                                          this.image = File(
                                                            image.path,
                                                          );
                                                        });
                                                      }
                                                    },
                                                    child: Text("Tirar foto"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final image =
                                                          await ImagePicker()
                                                              .pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .gallery,
                                                              );

                                                      if (image != null) {
                                                        setState(() {
                                                          this.image = File(
                                                            image.path,
                                                          );
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      "Escolher da galeria",
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Sair"),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      child: Icon(Icons.camera_alt),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final obj =
                                key.currentContext!.findRenderObject()
                                    as RenderRepaintBoundary;

                            final img = await obj.toImage();

                            final bytes = await img.toByteData(
                              format: ImageByteFormat.png,
                            );

                            final file = File(
                              '/storage/emulated/0/Download/file_${DateTime.now().millisecondsSinceEpoch}.png',
                            );

                            await file.writeAsBytes(
                              bytes!.buffer.asUint8List(),
                            );

                            Fluttertoast.showToast(
                              msg: 'Baixado em: ${file.path}',
                              backgroundColor: Colors.green,
                            );
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg:
                                  'Erro: Não é possível achar um path em dispositivo físico, teste em um emulador',
                              backgroundColor: Colors.red,
                            );
                          }
                        },
                        label: Text("Baixar"),
                        icon: Icon(Icons.download),
                      ),
                    ],
                  ),
                  Card(
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(8),
                      child: ListTile(
                        title: Text("Sobre mim"),
                        trailing: IconButton(
                          onPressed: () {
                            setState(() {
                              editing = !editing;
                            });
                          },
                          icon: Icon(Icons.edit),
                        ),
                        subtitle: TextField(controller: bio, enabled: editing),
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ListTile(title: Text("informações")),
                          ListTile(
                            title: Text("Unidade"),
                            trailing: Text(widget.me['escola']),
                          ),
                          Divider(),
                          ListTile(
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
