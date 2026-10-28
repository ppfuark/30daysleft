import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Check extends StatefulWidget {
  const Check({super.key});
  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  List<File> files = [];

  bool recording = false;
  late final FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder()
    ..openRecorder();
  late final FlutterSoundPlayer flutterSoundPlayer = FlutterSoundPlayer()
    ..openPlayer();
  String? recorderPath;
  int currentSec = 0;
  Timer? timer;

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
        title: ListTile(
          title: Text(
            "Check-in de Coleta",
            style: TextStyle(color: Colors.green),
          ),
          subtitle: Text(
            "Forneça os detalhes finais para concluir o descarte consciente.",
          ),
        ),
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
          spacing: 40,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            trailing: Chip(
                              backgroundColor: Colors.red.shade400,
                              label: Text(
                                "Obrigatório",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text("Evidências visuais"),
                            subtitle: Text(
                              "Registre as imagens do material a ser coletado.",
                            ),
                          ),
                          SizedBox(
                            height: 100,

                            child: Row(
                              spacing: 20,
                              children: [
                                Expanded(
                                  child: Opacity(
                                    opacity: files.length >= 5 ? 0.4 : 1.0,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          if (files.length < 5) {
                                            final file = await ImagePicker()
                                                .pickImage(
                                                  source: ImageSource.camera,
                                                );

                                            if (file != null) {
                                              setState(() {
                                                files.add(File(file.path));
                                              });
                                            }
                                          }
                                        },
                                        leading: Icon(Icons.camera_alt),
                                        title: Text("Tirar Foto do Entulho"),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Opacity(
                                    opacity: files.length >= 5 ? 0.4 : 1.0,
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          if (files.length < 5) {
                                            final file = await ImagePicker()
                                                .pickMultiImage(
                                                  limit: 5 - files.length,
                                                );

                                            if (file.isNotEmpty) {
                                              setState(() {
                                                for (var element in file) {
                                                  files.add(File(element.path));
                                                }
                                              });
                                            }
                                          }
                                        },
                                        leading: Icon(Icons.image),
                                        title: Text("Anexar Foto do Local"),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (files.isNotEmpty)
                            SizedBox(
                              height: 100,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  spacing: 10,
                                  children: [
                                    ...files.map(
                                      (e) => SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Stack(
                                          children: [
                                            Image.file(
                                              e,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    files.remove(e);
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(5),
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        spacing: 10,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            trailing: Chip(
                              backgroundColor: Colors.red.shade400,
                              label: Text(
                                "Obrigatório",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text("Resumo em Áudio"),
                            subtitle: Text(
                              "Grave uma breve descrição sovre os itens e o acesso local.",
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                if (recording) {
                                  final file = await flutterSoundRecorder
                                      .stopRecorder();

                                  setState(() {
                                    recorderPath = file;
                                    recording = false;
                                    currentSec = 0;
                                  });
                                } else {
                                  setState(() {
                                    recording = true;
                                  });

                                  final dir =
                                      await getApplicationDocumentsDirectory();
                                  final file =
                                      "${dir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.aac";

                                  await flutterSoundRecorder.startRecorder(
                                    codec: Codec.aacADTS,
                                    toFile: file,
                                  );

                                  timer = Timer.periodic(Duration(seconds: 1), (
                                    timer,
                                  ) async {
                                    setState(() {
                                      currentSec++;
                                    });

                                    if (currentSec == 30) {
                                      final file = await flutterSoundRecorder
                                          .stopRecorder();

                                      setState(() {
                                        timer.cancel();
                                        recorderPath = file;
                                        recording = false;
                                        currentSec = 0;
                                      });
                                    }
                                  });
                                }
                              } catch (e) {
                                Fluttertoast.showToast(
                                  msg: 'Permission: $e',
                                  backgroundColor: Colors.red,
                                );
                                setState(() {
                                  recording = false;
                                  timer?.cancel();
                                  currentSec = 0;
                                  recorderPath = null;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                recording ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                          Text(
                            "Gravar resumo em áudio",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),

                          if (recording)
                            LinearProgressIndicator(value: currentSec / 30),

                          if (!recording && recorderPath != null)
                            ListTile(
                              title: Text(recorderPath!.split("/").last),
                              subtitle: ElevatedButton(
                                onPressed: () async {
                                  await flutterSoundPlayer.startPlayer(
                                    codec: Codec.aacADTS,
                                    fromURI: recorderPath,
                                  );
                                },
                                child: Text("Ouvir Gravação"),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  setState(() {
                                    recorderPath = null;
                                  });
                                },
                                icon: Icon(Icons.delete),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: recorderPath == null || files.isEmpty
                    ? null
                    : () {
                        Fluttertoast.showToast(
                          msg: "Check-in finalizado",
                          backgroundColor: Colors.green,
                        );

                        setState(() {
                          recording = false;
                          timer?.cancel();
                          currentSec = 0;
                          recorderPath = null;
                          files.clear();
                        });
                        Navigator.pop(context);
                      },
                label: Text("Finalizar Descarte"),
                icon: Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
