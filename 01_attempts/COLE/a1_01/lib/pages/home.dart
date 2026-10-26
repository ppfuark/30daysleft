import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset('assets/video_inicial.mp4')
        ..initialize()
        ..setLooping(true)
        ..setVolume(0.0)
        ..play()
            .then((value) => setState(() {}))
            .then((value) => setState(() {}));

  Future<void> startApp() async {
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
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          spacing: 20,
          children: [
            ListTile(
              title: Text(
                "Pontos de Coleta",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Encontre os pontos de coleta mais próximos"),
            ),
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: videoPlayerController.value.isInitialized
                    ? VideoPlayer(videoPlayerController)
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final c = data[index];

                  return ListTile(
                    title: Text(
                      c['nome'].toString(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_pin),
                          Text(
                            c['endereco'].toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_pin),
                          Text(
                            c['distancia'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Column(
                        children: [
                          Text(c['avaliacao'].toString()),
                          Icon(Icons.star, color: Colors.amber),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: data.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final data = [
  {
    "nome": "Ecoponto Centro",
    "endereco": "Rua da Liberdade, 123",
    "distancia": "0.5 km",
    "horario": "Seg-Sex: 8h-18h",
    "avaliacao": "4.8",
  },
  {
    "nome": "Ponto Verde Norte",
    "endereco": "Av. Principal, 456",
    "distancia": "1.2 km",
    "horario": "Seg-Sáb: 7h-19h",
    "avaliacao": "4.5",
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
    "endereco": "Av. das Palmeiras, 1500",
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
