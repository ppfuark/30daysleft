import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Explore extends StatefulWidget {
  final Map<String, dynamic> modal;

  const Explore({super.key, required this.modal});
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final modals = {
    "08": ["videos/08-01.mp4", "videos/08-02.mp4"],
    "17": ["videos/17-01.mp4", "videos/17-02.mp4"],
    "50": ["videos/50-01.mp4", "videos/50-02.mp4"],
    "53": ["videos/53-01.mp4", "videos/53-02.mp4"],
    "54": ["videos/54-01.mp4", "videos/54-02.mp4"],
  };

  final modalsId = {"1": "08", "2": "17", "3": "53", "4": "54"};

  Future<void> startApp() async {
    print(widget.modal);
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
      appBar: AppBar(
        title: Text(
          maxLines: 2,
          "#${widget.modal['id'].toString().padLeft(2, '0')} - ${widget.modal['titulo']}",
        ),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Video(
              path: modals[modalsId[widget.modal['id'].toString()]]![index],
            );
          },
          itemCount: modals[modalsId[widget.modal['id'].toString()]]!.length,
        ),
      ),
    );
  }
}

class Video extends StatefulWidget {
  final String path;

  const Video({super.key, required this.path});
  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  late final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset("assets/${widget.path}")
        ..initialize()
        ..setVolume(0.0).then((value) {
          setState(() {});
        });

  Future<void> startApp() async {
    await Future.delayed(Duration(seconds: 5));
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
    await Future.delayed(Duration(seconds: 2));
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
      body: GestureDetector(
        onLongPressStart: (details) {
          setState(() {
            videoPlayerController.play();
          });
        },
        onLongPressEnd: (details) {
          videoPlayerController.pause();
          videoPlayerController.seekTo(Duration.zero);
          setState(() {});
        },
        child: Container(
          width: w,
          height: h,
          padding: EdgeInsets.all(30),
          child: videoPlayerController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(videoPlayerController),
                )
              : SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
