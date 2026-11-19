import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> me;

  const Profile({super.key, required this.me});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> startApp() async {
    bio.text = "No bio yet...";
  }

  final bio = TextEditingController();
  bool editing = false;

  final key = GlobalKey();

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
                  title: SizedBox(
                    width: double.infinity,
                    child: Text(
                      textAlign: TextAlign.center,
                      widget.me['nome'].toString(),
                    ),
                  ),
                  subtitle: Chip(
                    label: Text(widget.me['modalidade'].toString()),
                  ),
                  trailing: SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              widget.me['foto'].toString().contains('foto')
                              ? AssetImage(
                                  'assets/users/${widget.me['foto'].toString()}',
                                )
                              : FileImage(File(widget.me['foto'].toString())),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: 'FD',
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  return Stack(
                                    alignment: AlignmentGeometry.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 90,
                                        backgroundImage:
                                            widget.me['foto']
                                                .toString()
                                                .contains('foto')
                                            ? AssetImage(
                                                'assets/users/${widget.me['foto'].toString()}',
                                              )
                                            : FileImage(
                                                File(
                                                  widget.me['foto'].toString(),
                                                ),
                                              ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) {
                                                    return CupertinoActionSheet(
                                                      actions: [
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            final file =
                                                                await ImagePicker()
                                                                    .pickImage(
                                                                      source: ImageSource
                                                                          .camera,
                                                                    );

                                                            if (file != null) {
                                                              final framedPath = await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => Frame(
                                                                        path: file
                                                                            .path,
                                                                      ),
                                                                ),
                                                              );
                                                              if (framedPath !=
                                                                  null) {
                                                                setState(() {
                                                                  widget.me['foto'] =
                                                                      framedPath;
                                                                });
                                                              }
                                                            }
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text(
                                                            "Tirar foto",
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            final file =
                                                                await ImagePicker()
                                                                    .pickImage(
                                                                      source: ImageSource
                                                                          .gallery,
                                                                    );
                                                            if (file != null) {
                                                              final framedPath = await Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => Frame(
                                                                        path: file
                                                                            .path,
                                                                      ),
                                                                ),
                                                              );
                                                              if (framedPath !=
                                                                  null) {
                                                                setState(() {
                                                                  widget.me['foto'] =
                                                                      framedPath;
                                                                });
                                                              }
                                                            }
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text(
                                                            "Escolher da galeria",
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text("Sair"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(Icons.edit),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                subtitle: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(widget.me['escola'].toString()),
                  subtitle: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final limit =
                                key.currentContext!.findRenderObject()
                                    as RenderRepaintBoundary;

                            final image = await limit.toImage();

                            final bytes = await image.toByteData(
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
                              msg: 'Tente usar o emulador: $e',
                              backgroundColor: Colors.red,
                            );
                            print(e);
                          }
                        },
                        icon: Icon(Icons.download),
                        label: Text("Baixar Perfil"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),

                  title: Text("Sobre mim"),
                  subtitle: TextField(controller: bio, enabled: editing),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        editing = !editing;
                      });
                    },
                    icon: Icon(editing ? Icons.save : Icons.edit),
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("informações"),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Unidade"),
                      trailing: Text(widget.me['escola'].toString()),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Modalidade"),
                      trailing: Text(widget.me['modalidade'].toString()),
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

class Frame extends StatefulWidget {
  final String path;
  const Frame({super.key, required this.path});
  @override
  State<Frame> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  final key = GlobalKey();
  Offset offset = Offset.zero;
  Offset lastOffset = Offset.zero;

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
      appBar: AppBar(title: Text('Enquadramento')),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: RepaintBoundary(
                key: key,
                child: GestureDetector(
                  onLongPressMoveUpdate: (details) {
                    setState(() {
                      offset = lastOffset + details.offsetFromOrigin;
                    });
                  },
                  onLongPressEnd: (details) {
                    setState(() {
                      lastOffset = offset;
                    });
                  },
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: OverflowBox(
                      maxHeight: 400,
                      maxWidth: 400,
                      child: Transform.translate(
                        offset: offset,
                        child: Image.file(File(widget.path)),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final object =
                    key.currentContext!.findRenderObject()
                        as RenderRepaintBoundary;

                final image = await object.toImage();
                final bytes = await image.toByteData(
                  format: ImageByteFormat.png,
                );

                final dir = await getApplicationDocumentsDirectory();
                final file =
                    "${dir.path}/file_${DateTime.now().millisecondsSinceEpoch.toString()}";

                await File(file).writeAsBytes(bytes!.buffer.asInt8List());
                Navigator.pop(context, file);
              },
              child: Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
