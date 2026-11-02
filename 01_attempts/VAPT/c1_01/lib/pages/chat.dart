import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:c1_01/pages/main_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:path_provider/path_provider.dart';

class Chat extends StatefulWidget {
  final List messages;

  const Chat({super.key, required this.messages});
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late final FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder()
    ..openRecorder();

  bool recording = false;
  String? path;
  int duration = 0;
  Timer? time2;

  final text = TextEditingController();

  final AudioPlayer audioPlayer = AudioPlayer();
  bool is2x = false;
  int currentPosition = 0;
  String? audio;
  Timer? timer;
  bool listening = false;

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
      appBar: AppBar(leading: Icon(Icons.person), title: Text("Chefe")),
      body: SizedBox(
        width: w,
        height: h,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final m = widget.messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Align(
                      alignment: m['chef']
                          ? AlignmentGeometry.centerLeft
                          : AlignmentGeometry.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            constraints: BoxConstraints(maxWidth: w * .75),
                            child: m['text']
                                ? ListTile(
                                    title: Text(m['content'].toString()),
                                    trailing: m['chef']
                                        ? null
                                        : IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return CupertinoActionSheet(
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            messages.remove(m);
                                                          });
                                                        },
                                                        child: Text(
                                                          "Apagar para mim",
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            messages.remove(m);
                                                          });
                                                        },
                                                        child: Text(
                                                          "Apagar para todos",
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(Icons.more_vert),
                                          ),
                                  )
                                : ListTile(
                                    leading: IconButton(
                                      onPressed: () async {
                                        try {
                                          print("op");
                                          print(m['content']);
                                          setState(() {
                                            audio = m['content'];
                                            timer?.cancel();
                                            currentPosition = 0;
                                            listening = true;
                                          });
                                          await audioPlayer.play(
                                            DeviceFileSource(audio!),
                                          );
                                          print("op");
                                          timer = Timer.periodic(
                                            Duration(seconds: 1),
                                            (timer) {
                                              () async {
                                                setState(() {
                                                  currentPosition++;
                                                  print(currentPosition);

                                                  if (currentPosition ==
                                                      m['maxDuration']) {
                                                    timer.cancel();
                                                    audio == null;
                                                    listening = false;
                                                    currentPosition = 0;
                                                  }
                                                });
                                                await audioPlayer.stop();
                                              };
                                            },
                                          );

                                          print("op");
                                        } catch (e) {
                                          Fluttertoast.showToast(
                                            msg: "Erro: $e",
                                            backgroundColor: Colors.red,
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.play_arrow),
                                    ),
                                    title: LinearProgressIndicator(
                                      value: currentPosition / m['maxDuration'],
                                      color: Colors.deepOrange,
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${(currentPosition ~/ 60).toString().padLeft(2, '0')}:${(currentPosition % 60).toString().padLeft(2, '0')}",
                                        ),
                                        Text(
                                          "${(m['maxDuration'] ~/ 60).toString().padLeft(2, '0')}:${(m['maxDuration'] % 60).toString().padLeft(2, '0')}",
                                        ),
                                      ],
                                    ),
                                    trailing: m['chef']
                                        ? null
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    is2x = !is2x;
                                                  });

                                                  audioPlayer.setPlaybackRate(
                                                    is2x ? 2 : 1,
                                                  );
                                                },
                                                icon: Text(is2x ? "2X" : "1X"),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) {
                                                      return CupertinoActionSheet(
                                                        actions: [
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                messages.remove(
                                                                  m,
                                                                );
                                                              });
                                                            },
                                                            child: Text(
                                                              "Apagar para mim",
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                messages.remove(
                                                                  m,
                                                                );
                                                              });
                                                            },
                                                            child: Text(
                                                              "Apagar para todos",
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: Icon(Icons.more_vert),
                                              ),
                                            ],
                                          ),
                                  ),
                          ),
                          Text(m['time'].toString()),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: widget.messages.length,
              ),
            ),
            Divider(),
            Container(
              width: double.infinity,
              height: 70,
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: text,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        hintText: "Digite uma mensagem",
                        suffixIcon: IconButton(
                          onPressed: () async {
                            try {
                              if (recording) {
                                path = await flutterSoundRecorder
                                    .stopRecorder();
                                time2?.cancel();
                                setState(() {
                                  recording = false;
                                  setState(() {
                                    messages.add({
                                      "time":
                                          "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                                      "content": path,
                                      "chef": false,
                                      "text": false,
                                      "maxDuration": duration,
                                    });
                                  });
                                });

                                setState(() {
                                  duration = 0;
                                });
                              } else {
                                final dir =
                                    await getApplicationDocumentsDirectory();
                                final file =
                                    "${dir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.aac";

                                await flutterSoundRecorder.startRecorder(
                                  codec: Codec.aacADTS,
                                  toFile: file,
                                );

                                time2 = Timer.periodic(Duration(seconds: 1), (
                                  timer,
                                ) {
                                  setState(() {
                                    duration++;
                                  });
                                });

                                setState(() {
                                  recording = true;
                                });
                              }
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: "Permission: $e",
                                backgroundColor: Colors.red,
                              );
                            }
                          },
                          icon: Icon(recording ? Icons.stop : Icons.mic),
                        ),
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        messages.add({
                          "time":
                              "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                          "content": text.text,
                          "chef": false,
                          "text": true,
                        });
                      });
                    },
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
