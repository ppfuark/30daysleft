import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  late final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset('assets/video_inicial.mp4')
        ..initialize()
        ..setLooping(true)
        ..setVolume(0.0).then((value) {
          setState(() {});
        });

  Future<void> startApp() async {
    try {
      setState(() {
        loading = false;
      });

      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
      await Future.delayed(Duration(seconds: 1));
      setState(() {});
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
    return loading
        ? Scaffold(
            body: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  ListTile(
                    title: Text("Pontos de coleta"),
                    subtitle: Text("Encontre os pontos de coleta mais próximo"),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: videoPlayerController.value.aspectRatio,
                      child: videoPlayerController.value.isCompleted
                          ? VideoPlayer(videoPlayerController)
                          : Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final p = points[index];
                        return ListTile(
                          title: Text(p['nome'].toString()),
                          trailing: Column(
                            children: [
                              Icon(Icons.star, color: Colors.amber),
                              Text(p['avaliacao']),
                            ],
                          ),
                          subtitle: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.location_pin),
                                Text(p['endereco'].toString()),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.location_pin),
                                Text(p['distancia'].toString()),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: points.length,
                      shrinkWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

final List<Map<String, dynamic>> points = [
  {
    "nome": "Ecoponto Centro",
    "endereco": "Rua da Liberdade, 123",
    "distancia": "0.5 km",
    "horario": "Seg-Sex: 8h-18h",
    "avaliacao": "4.8",
  },
  {
    "nome": "Ponto Verde Paulista",
    "endereco": "Avenida Paulista, 890",
    "distancia": "1.2 km",
    "horario": "Seg-Sáb: 7h-19h",
    "avaliacao": "4.7",
  },
  {
    "nome": "Ecoponto Jardim das Flores",
    "endereco": "Rua das Acácias, 456",
    "distancia": "2.0 km",
    "horario": "Seg-Dom: 8h-20h",
    "avaliacao": "4.9",
  },
  {
    "nome": "Coleta Sustentável Norte",
    "endereco": "Rua do Bosque, 78",
    "distancia": "2.8 km",
    "horario": "Seg-Sex: 9h-17h",
    "avaliacao": "4.5",
  },
  {
    "nome": "Ecoponto Vila Nova",
    "endereco": "Avenida das Palmeiras, 1500",
    "distancia": "3.1 km",
    "horario": "Ter-Dom: 8h-18h",
    "avaliacao": "4.6",
  },
  {
    "nome": "Recicla Fácil Leste",
    "endereco": "Rua Aurora, 245",
    "distancia": "3.7 km",
    "horario": "Seg-Sáb: 8h-16h",
    "avaliacao": "4.4",
  },
  {
    "nome": "Ponto Eco Esperança",
    "endereco": "Rua Esperança, 987",
    "distancia": "4.2 km",
    "horario": "Seg-Sex: 8h-18h",
    "avaliacao": "4.7",
  },
  {
    "nome": "Ecoponto Parque Verde",
    "endereco": "Avenida Central, 321",
    "distancia": "4.9 km",
    "horario": "Seg-Dom: 6h-22h",
    "avaliacao": "4.9",
  },
  {
    "nome": "Estação Reciclar",
    "endereco": "Rua dos Ipês, 654",
    "distancia": "5.3 km",
    "horario": "Seg-Sáb: 8h-17h",
    "avaliacao": "4.3",
  },
  {
    "nome": "EcoHub Sustentável",
    "endereco": "Rua São José, 112",
    "distancia": "6.0 km",
    "horario": "Seg-Sex: 7h-18h",
    "avaliacao": "4.8",
  },
];
