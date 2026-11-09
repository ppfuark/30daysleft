import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Explore extends StatefulWidget {
  final Map<String, dynamic> modal;

  const Explore({super.key, required this.modal});
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  final ids = {01: "08", 02: "17", 03: "50", 04: "53"};
  final map = {
    "08": ["videos/08-01.mp4", "videos/08-02.mp4"],
    "17": ["videos/17-01.mp4", "videos/17-02.mp4"],
    "50": ["videos/50-01.mp4", "videos/50-02.mp4"],
    "53": ["videos/53-01.mp4", "videos/53-02.mp4"],
    "54": ["videos/54-01.mp4", "videos/54-02.mp4"],
  };

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

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    print(widget.modal['id'].toString());
    print(ids[widget.modal['id']]);
    print(map[ids[widget.modal['id']]]);

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
              title: Text(
                "#${ids[widget.modal['id']].toString().padLeft(2, '0')} ${widget.modal['titulo']}",
                maxLines: 2,
              ),
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  print(widget.modal['id'].toString());
                  final p = (map[ids[widget.modal['id']]] as List)[index];

                  return Video(path: "assets/$p");
                },
                itemCount: (map[ids[widget.modal['id']]] as List).length,
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

class _VideoState extends State<Video> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  late final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset(widget.path);

  Future<void> startApp() async {
    try {
      await videoPlayerController.initialize();

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
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : GestureDetector(
            onLongPressStart: (details) async {
              await videoPlayerController.seekTo(Duration(seconds: 0));
              await videoPlayerController.play();
            },
            onLongPressEnd: (details) async {
              await videoPlayerController.pause();
            },
            child: AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: VideoPlayer(videoPlayerController),
            ),
          );
  }
}
