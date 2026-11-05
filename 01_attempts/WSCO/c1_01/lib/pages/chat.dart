import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class Chat extends StatefulWidget {
  final Map<String, dynamic> me;

  const Chat({super.key, required this.me});
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List users = [];
  List mensagens = [];
  List schools = [];
  List posts = [];

  Future<void> startApp() async {
    final raw = await rootBundle.loadString('assets/lista_de_usuarios.json');
    final raw1 = await rootBundle.loadString('assets/mensagens.json');
    final raw2 = await rootBundle.loadString('assets/senai_sp_unidades.json');
    final raw3 = await rootBundle.loadString('assets/postagens_timeline.json');
    final json = jsonDecode(raw);
    final json1 = jsonDecode(raw1);
    final json2 = jsonDecode(raw2);
    final json3 = jsonDecode(raw3);
    setState(() {
      users = json;
      mensagens = json1;
      schools = json2;
      posts = json3['timeline']['postagens'];
    });
  }

  bool recording = false;
  bool showRecorder = false;
  String? recordedPath;

  late final recorder = FlutterSoundRecorder()..openRecorder();
  final player = AudioPlayer();

  final text = TextEditingController();

  Map<String, dynamic>? selected;

  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return selected != null
        ? Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    selected = null;
                  });
                },
                icon: Icon(Icons.arrow_back),
              ),
              title: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/users/${users.firstWhere((element) => element['id'] == selected!['participantes'][0], orElse: () => {})['foto'].toString()}',
                  ),
                ),
                title: Text(
                  users
                      .firstWhere(
                        (element) =>
                            element['id'] == selected!['participantes'][0],
                        orElse: () => {},
                      )['nome']
                      .toString(),
                ),
              ),
            ),
            body: Container(
              width: w,
              height: h,
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final m = selected!['mensagens'][index];
                        return GestureDetector(
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return CupertinoActionSheet(
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selected!['mensagens'].remove(m);
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Text("Excluir para mim"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selected!['mensagens'].remove(m);
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Text("Excluir para todos"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Text("Sair"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            constraints: BoxConstraints(maxWidth: w * .65),
                            child: Card(
                              child: Align(
                                alignment: m['remetente_id'] == widget.me['id']
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: ListTile(
                                  title: Text(m['conteudo'].toString()),
                                  subtitle: Text(
                                    "${DateTime.parse(m['data_hora'].toString()).hour}:${DateTime.parse(m['data_hora'].toString()).minute}",
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: selected!['mensagens'].length,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    height: 80,
                    color: Colors.white,
                    child: showRecorder
                        ? Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    showRecorder = false;
                                    recordedPath = null;
                                    recording = false;
                                    recorder.stopRecorder();
                                  });
                                },
                                icon: Icon(Icons.close),
                              ),
                              if (recordedPath == null) ...[
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      if (recording) {
                                        final file = await recorder
                                            .stopRecorder();
                                        setState(() {
                                          recording = false;
                                          recordedPath = file;
                                        });
                                      } else {
                                        final dir =
                                            await getApplicationDocumentsDirectory();
                                        final file =
                                            "${dir.path}/${DateTime.now().toIso8601String()}.aac";

                                        await recorder.startRecorder(
                                          toFile: file,
                                        );
                                        setState(() {
                                          recording = true;
                                        });
                                      }
                                    } catch (e) {
                                      Fluttertoast.showToast(
                                        msg: 'Permssion: $e',
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    recording
                                        ? Icons.stop
                                        : Icons.fiber_manual_record,
                                  ),
                                ),
                              ] else ...[
                                IconButton(
                                  onPressed: () {
                                    player.play(
                                      DeviceFileSource(recordedPath!),
                                    );
                                  },
                                  icon: Icon(Icons.play_arrow),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      recordedPath = null;
                                      recording = false;
                                    });
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                              IconButton(
                                onPressed: () {
                                  if (recordedPath != null) {}
                                },
                                icon: Icon(Icons.send),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: text,
                                  decoration: InputDecoration(
                                    hintText: "Escreva sua mensagem...",
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    showRecorder = true;
                                  });
                                },
                                icon: Icon(Icons.mic),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (text.text.isNotEmpty) {
                                    setState(() {
                                      selected!['mensagens'].add({
                                        "id": selected!['mensagens'].length + 1,
                                        "remetente_id": widget.me['id'],
                                        "remetente_nome": widget.me['nome'],
                                        "tipo": "texto",
                                        "conteudo": text.text,
                                        "data_hora": DateTime.now()
                                            .toIso8601String(),
                                        "lida": true,
                                      });
                                      text.clear();
                                    });
                                  }
                                },
                                icon: Icon(Icons.send),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Chat"),
              actions: [
                IconButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => ListView.builder(
                      itemBuilder: (context, index) {
                        final u = users[index];

                        return ListTile(
                          onTap: () {
                            setState(() {
                              mensagens.add({
                                "id_conversa": mensagens.length + 1,
                                "participantes": [u['id'], widget.me['id']],
                                "nomes": [u['nome'], widget.me['nome']],
                                "mensagens": [],
                              });
                              selected = mensagens[mensagens.length - 1];
                            });
                            Navigator.pop(context);
                          },
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/users/${u['foto'].toString()}',
                            ),
                          ),
                          title: Text(u['nome'].toString()),
                          subtitle: Text(u['modalidade'].toString()),
                        );
                      },
                      itemCount: users.length,
                    ),
                  ),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final m = mensagens[index];
                        final u = users.firstWhere(
                          (element) => element['id'] == m['participantes'][0],
                        );
                        final notRead = m['mensagens'].any(
                          (e) => e['lida'] == false,
                        );

                        return ListTile(
                          onTap: () {
                            setState(() {
                              selected = m;
                            });
                          },
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                              'assets/users/${u['foto'].toString()}',
                            ),
                          ),
                          title: Text(u['nome'].toString()),
                          trailing: Text(
                            m['mensagens'].isEmpty
                                ? ""
                                : "há ${DateTime.now().difference(DateTime.parse(m['mensagens'].last['data_hora'].toString())).inDays.abs()} dias",
                          ),
                          subtitle: Text(
                            style: TextStyle(
                              fontWeight: notRead ? FontWeight.bold : null,
                              fontStyle: notRead ? null : FontStyle.italic,
                            ),
                            m['mensagens'].isEmpty
                                ? ""
                                : m['mensagens'].last['conteudo'].toString(),
                          ),
                        );
                      },
                      itemCount: mensagens.length,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
