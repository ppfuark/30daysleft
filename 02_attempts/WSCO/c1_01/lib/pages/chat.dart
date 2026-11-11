import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/public/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class Chat extends StatefulWidget {
  final Map<String, dynamic> me;

  const Chat({super.key, required this.me});
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  List users = [];
  List posts = [];
  List comments = [];
  List chats = [];
  String lang = 'pt-BR';

  Future<void> startApp() async {
    try {
      if (WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
          'en') {
        setState(() {
          lang = 'en-US';
        });
      }
      if (WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
          'es') {
        setState(() {
          lang = 'es-ES';
        });
      }

      final raw = await rootBundle.loadString('assets/lista_de_usuarios.json');
      final json = jsonDecode(raw);
      setState(() {
        users = json;
      });
      final raw3 = await rootBundle.loadString('assets/mensagens.json');
      final jso3 = jsonDecode(raw3);
      setState(() {
        chats = jso3;
      });
      final raw1 = await rootBundle.loadString(
        'assets/postagens_timeline.json',
      );
      final json1 = jsonDecode(raw1);
      setState(() {
        posts = json1['timeline']['postagens'];
        posts.sort((a, b) {
          return DateTime.parse(
            b['horarioPostagem'].toString(),
          ).compareTo(DateTime.parse(a['horarioPostagem'].toString()));
        });
      });

      final raw2 = await rootBundle.loadString('assets/comentarios.xml');
      final xml = XmlDocument.parse(raw2);
      List data = [];
      for (var element in xml.findAllElements('comentario')) {
        setState(() {
          data.add({
            'postId': element.findAllElements('postId').first.innerText,
            'conteudo': element.findAllElements('conteudo').first.innerText,
            'dataComentario': element
                .findAllElements('dataComentario')
                .first
                .innerText,
            'curtidas': element.findAllElements('curtidas').first.innerText,
            'userId': element
                .findAllElements('usuario')
                .first
                .findAllElements('id')
                .first
                .innerText,
          });
        });
      }
      setState(() {
        comments = data;
      });

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

  Map<String, dynamic>? selected;

  late final FlutterSoundRecorder soundRecorder = FlutterSoundRecorder()
    ..openRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool recording = false;
  String? recordedPath;
  bool listening = false;
  String? listeningPath;

  bool showRecord = false;

  Future<void> record() async {
    try {
      if (recording) {
        final file = await soundRecorder.stopRecorder();
        setState(() {
          recording = false;
        });
        if (file != null) {
          setState(() {
            recordedPath = file;
            print(recordedPath);
          });
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
        await soundRecorder.startRecorder(codec: Codec.aacMP4, toFile: file);
        setState(() {
          recording = true;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro ao ${recording ? 'Parar' : 'Iniciar'} a gravação'),
          content: Text("Permission?: ${e.toString()}"),
        ),
      );
    }
  }

  Future<void> audio(String path, bool device) async {
    if (listening) {
      await audioPlayer.stop();
      setState(() {
        listening = false;
        listeningPath = null;
      });
    } else {
      await audioPlayer.play(
        device ? DeviceFileSource(path) : AssetSource(path),
      );
      setState(() {
        listeningPath = path;
        listening = true;
      });
    }
  }

  final search = TextEditingController();

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
        : selected != null
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
              title: Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      'assets/users/${users.where((element) => element['id'] == selected!['participantes'].first).first['foto'].toString()}',
                    ),
                  ),
                  Text(selected!['nomes'].first.toString()),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final msg = selected!['mensagens'][index];
                      final me = msg['remetente_id'] == widget.me['id'];

                      return Align(
                        alignment: me
                            ? AlignmentGeometry.centerRight
                            : AlignmentGeometry.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: w * .65),
                          child: GestureDetector(
                            onLongPress: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return CupertinoActionSheet(
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selected!['mensagens'].remove(msg);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text("Excluir para mim"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selected!['mensagens'].remove(msg);
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text("Excluir para todos"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Sair"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                              child: ListTile(
                                title: msg['tipo'] == "texto"
                                    ? Text(msg['conteudo'])
                                    : IconButton(
                                        onPressed: () {
                                          audio(msg['conteudo'], true);
                                        },
                                        icon: Icon(
                                          recordedPath == msg['conteudo'] &&
                                                  listening
                                              ? Icons.stop
                                              : Icons.play_arrow,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: (selected!['mensagens'] as List).length,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    spacing: 10,
                    children: recordedPath != null
                        ? [
                            IconButton(
                              onPressed: () {
                                audio(recordedPath!, true);
                              },
                              icon: Icon(
                                !listening ? Icons.play_arrow : Icons.pause,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                recordedPath = null;
                                recording = false;
                                listeningPath = null;
                                audioPlayer.stop();
                                setState(() {});
                              },
                              icon: Icon(Icons.close),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selected!['mensagens'].add({
                                    "id": selected!['mensagens'].length + 1,
                                    "remetente_id": widget.me['id'],
                                    "remetente_nome": widget.me['nome'],
                                    "tipo": "audio",
                                    "conteudo": recordedPath,
                                    "data_hora": "2026-10-01T08:14:22",
                                    "lida": true,
                                  });

                                  search.clear();

                                  showRecord = false;
                                  recordedPath = null;
                                  recording = false;
                                  listeningPath = null;
                                  audioPlayer.stop();
                                  soundRecorder.stopRecorder();
                                });
                              },
                              icon: Icon(Icons.send),
                            ),
                          ]
                        : showRecord
                        ? [
                            IconButton(
                              onPressed: () async {
                                record();
                                setState(() {});
                              },
                              icon: Icon(recording ? Icons.stop : Icons.mic),
                            ),
                            IconButton(
                              onPressed: () {
                                recordedPath = null;
                                listeningPath = null;
                                recording = false;
                                showRecord = false;
                                soundRecorder.stopRecorder();
                                audioPlayer.stop();
                              },
                              icon: Icon(Icons.close),
                            ),
                            IconButton(
                              onPressed: () {
                                Fluttertoast.showToast(
                                  msg: 'Erro: Termine de gravar para enviar',
                                  backgroundColor: Colors.red,
                                );
                              },
                              icon: Icon(Icons.send),
                            ),
                          ]
                        : [
                            Expanded(
                              child: TextField(
                                controller: search,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  hintText: "Escreva sua mensagem...",
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showRecord = true;
                                });
                              },
                              icon: Icon(Icons.mic),
                            ),
                            IconButton(
                              onPressed: () {
                                if (search.text.isNotEmpty && !showRecord) {
                                  setState(() {
                                    selected!['mensagens'].add({
                                      "id": selected!['mensagens'].length + 1,
                                      "remetente_id": widget.me['id'],
                                      "remetente_nome": widget.me['nome'],
                                      "tipo": "texto",
                                      "conteudo": search.text,
                                      "data_hora": "2026-10-01T08:14:22",
                                      "lida": true,
                                    });

                                    search.clear();
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
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Chat"),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SingleChildScrollView(
                        child: Column(
                          children: [
                            ...users.map(
                              (e) => ListTile(
                                onTap: () {
                                  setState(() {
                                    selected = chats.firstWhere(
                                      (element) =>
                                          element['participantes'].contains(
                                            int.parse(e['id'].toString()),
                                          ),
                                      orElse: () => chats.first,
                                    );
                                    Navigator.pop(context);
                                  });
                                },
                                leading: CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/users/${e['foto'].toString()}',
                                  ),
                                ),
                                title: Text(e['nome'].toString()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...chats.map((e) {
                      final u = users
                          .where(
                            (element) =>
                                element['id'] == e['participantes'].first,
                          )
                          .first;

                      final read = (e['mensagens'] ?? []).any(
                        (e) => e['lida'] == false,
                      );

                      return ListTile(
                        onTap: () {
                          setState(() {
                            selected = e;
                          });
                        },
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/users/${u['foto'].toString()}',
                          ),
                        ),
                        title: Text(e['nomes'].first.toString()),
                        subtitle: Text(
                          (e['mensagens'] ?? []).last['conteudo'].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: read ? null : FontWeight.bold,
                            fontStyle: read ? FontStyle.italic : null,
                          ),
                        ),
                        trailing: Text(
                          (e['mensagens'] ?? []).last['data_hora']
                              .toString()
                              .split('T')
                              .first
                              .replaceAll('-', '/'),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
  }
}
