import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class Checkin extends StatefulWidget {

  const Checkin({super.key,});
  @override
  State<Checkin> createState() => _CheckinState();
}

class _CheckinState extends State<Checkin> with TickerProviderStateMixin {
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

  List<File> files = [];

  late final FlutterSoundRecorder soundRecorder = FlutterSoundRecorder()
    ..openRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool recording = false;
  String? recordedPath;
  bool listening = false;
  String? listeningPath;
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
          });
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.acc';
        await soundRecorder.startRecorder(codec: Codec.aacADTS, toFile: file);
        setState(() {
          recording = true;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro ao ${recording ? 'Parar' : 'Iniciar'} a gravação'),
          content: Text(e.toString()),
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
              title: Text("Check-in de Coleta"),
              centerTitle: true,
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(children: []),
            ),
          );
  }
}
