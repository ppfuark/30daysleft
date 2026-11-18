import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewP extends StatefulWidget {
  const NewP({super.key});
  @override
  State<NewP> createState() => _NewPState();
}

class _NewPState extends State<NewP> with TickerProviderStateMixin {
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

  File? file;
  final text = TextEditingController();
  final tag = TextEditingController();
  List<String> tags = [];

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
              actions: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Deseja descartar esse post?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('Sim'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Não'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Descartar"),
                ),
              ],
              title: Text("Novo Post"),
              centerTitle: true,
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: w,
                    height: w / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey,
                      image: file == null
                          ? null
                          : DecorationImage(image: FileImage(file!)),
                    ),
                    child: file == null
                        ? Center(
                            child: IconButton(
                              onPressed: () async {
                                final image = await ImagePicker().pickImage(
                                  source: ImageSource.camera,
                                );

                                if (image != null) {
                                  setState(() {
                                    file = File(image.path);
                                    Navigator.pop(context);
                                  });
                                }
                              },
                              icon: Icon(Icons.camera_alt),
                            ),
                          )
                        : null,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text("Texto"),
                    subtitle: TextField(
                      controller: text,
                      key: Key('new_text'),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        hintText: "Escreva sua legenda aqui",
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text("Texto"),
                    subtitle: Wrap(
                      children: [
                        ...tags.map(
                          (e) => Chip(
                            label: Text(e),
                            deleteIcon: Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                tags.remove(e);
                              });
                            },
                          ),
                        ),
                        TextField(
                          key: Key('new_tag'),
                          controller: tag,
                          onChanged: (value) {
                            if (tag.text.length > 50) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tag superior à 50 caracteres, insira outra tag!',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              setState(() {
                                tag.clear();
                              });
                              return;
                            }
                          },
                          onTap: () {
                            if (tag.text.isNotEmpty) {
                              setState(() {
                                tags.add(tag.text);
                                tag.clear();
                              });
                            }
                          },
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            hintText: "+ Aicionar tag",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (text.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sua publicação não pode estar vazia. Adicione texto ou imagem',
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (text.text.length > 300) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Limite de caracteres excedito (300)',
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        setState(() {
                          text.clear();
                        });
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Publicação enviado com sucesso!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text("Publicar"),
                  ),
                ],
              ),
            ),
          );
  }
}
