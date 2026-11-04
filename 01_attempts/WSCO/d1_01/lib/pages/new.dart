import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class New extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> data;
  final int me;

  const New({super.key, required this.data, required this.me});
  @override
  State<New> createState() => _NewState();
}

class _NewState extends State<New> {
  File? file;
  final text = TextEditingController();
  final tag = TextEditingController();
  List<String> tags = [];

  void showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void addTag() {
    final value = tag.text.trim();
    if (value.length > 50) {
      showError("Tag superior à 50 caracteres, insira outra tag!");
      return;
    }
    if (value.isEmpty) return;

    setState(() {
      tags.add(value.startsWith('#') ? value : '#$value');
      tag.clear();
    });
  }

  void publish() {
    if (text.text.length > 300) {
      showError("Limite de caracteres excedido (300)");
      return;
    }
    if (tag.text.trim().length > 50) {
      showError("Tag superior à 50 caracteres, insira outra tag!");
      return;
    }
    if (text.text.trim().isEmpty && file == null) {
      showError("Sua publicação não pode estar vazia. Adicione texto ou imagem.");
      return;
    }

    if (tag.text.trim().isNotEmpty) {
      tags.add(tag.text.trim().startsWith('#') ? tag.text.trim() : '#${tag.text.trim()}');
    }
    final posts = widget.data['posts']!;
    posts.add({
      'id': posts.isEmpty
          ? 1
          : posts
                  .map((post) => post['id'] as int)
                  .reduce((a, b) => a > b ? a : b) +
              1,
      'usuario_id': widget.me,
      'texto': text.text.trim(),
      'tags': List<String>.from(tags),
      'imagem': '',
      'likes': 0,
      'data_publicacao': DateTime.now().toUtc().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Publicação enviada com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo Post"),
        actions: [
          TextButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
              title: Text("Deseja descartar este post?"),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Não"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text("Sim"),
                    ),
                  ],
                ),
              );
            },
            child: Text("Descartar"),
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
              height: w - 160,
              child: file != null
                  ? Image.file(
                      file!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Card(
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => CupertinoActionSheet(
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final image = await ImagePicker()
                                          .pickImage(
                                            source: ImageSource.gallery,
                                          );

                                      if (image != null) {
                                        setState(() {
                                          file = File(image.path);
                                        });
                                      }
                                    },
                                    child: Text("Escolher da Galeria"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final image = await ImagePicker()
                                          .pickImage(
                                            source: ImageSource.camera,
                                          );

                                      if (image != null) {
                                        setState(() {
                                          file = File(image.path);
                                        });
                                      }
                                    },
                                    child: Text("Tirar foto"),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Texto"),
              subtitle: TextField(
                key: const Key('new_text'),
                controller: text,
                minLines: 4,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Escreva sua legenda aqui",
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Tags"),
              subtitle: Wrap(
                children: [
                  TextField(
                    key: const Key('new_tag'),
                    controller: tag,
                    decoration: InputDecoration(hintText: "+ Adicionar tag"),
                  ),
                  IconButton(
                    key: const Key('new_tag_add'),
                    onPressed: addTag,
                    icon: const Icon(Icons.add),
                  ),
                  ...tags.map(
                    (e) => Chip(
                      label: Text(e),
                      onDeleted: () {
                        tags.remove(e);
                        setState(() {});
                      },

                      deleteIcon: Icon(
                        key: Key('tag_${tags.indexOf(e)}'),
                        Icons.close,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              key: const Key('new_publish'),
              onPressed: publish,
              child: Text("Publicar"),
            ),
          ],
        ),
      ),
    );
  }
}
