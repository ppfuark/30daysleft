import 'package:c1_01/pages/checkin.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapa extends StatefulWidget {
  final Map<String, dynamic> me;

  const Mapa({super.key, required this.me});
  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  Future<void> startApp() async {
    try {
      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      await Geolocator.requestPermission();

      userP = await Geolocator.getCurrentPosition();

      (data['pontos_coleta'] as List).sort(
        (a, b) =>
            Geolocator.distanceBetween(
              userP!.latitude,
              userP!.longitude,
              a['latitude'],
              a['longitude'],
            ).compareTo(
              Geolocator.distanceBetween(
                userP!.latitude,
                userP!.longitude,
                b['latitude'],
                b['longitude'],
              ),
            ),
      );

      icon = await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(50, 50)),
        "assets/icons/Caminhao_Mapa.jpg",
      );

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

  final search = TextEditingController();

  Position? userP;
  Map<String, dynamic>? selected;

  BitmapDescriptor? icon;

  late final List<LatLng> points = [LatLng(userP!.latitude, userP!.longitude)];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
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
        : Scaffold(
            appBar: AppBar(
              leading: Icon(Icons.menu),
              title: Text("Rastreamento"),
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
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                spacing: 10,
                children: [
                  TextField(
                    controller: search,
                    decoration: InputDecoration(
                      hintText: "Buscar pontos de coleta",

                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  Expanded(
                    child: userP == null
                        ? Center(
                            child: Text("Aguardando posição de usuário..."),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 140,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      ...(data['pontos_coleta'] as List)
                                          .where(
                                            (element) => element['nome']
                                                .toString()
                                                .contains(search.text),
                                          )
                                          .map((e) {
                                            double distance =
                                                Geolocator.distanceBetween(
                                                  userP!.latitude,
                                                  userP!.longitude,
                                                  e['latitude'],
                                                  e['longitude'],
                                                ) /
                                                1000;

                                            return SizedBox(
                                              width: w * .5,
                                              child: Card(
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      title: Text(
                                                        e['nome'].toString(),
                                                      ),
                                                      trailing: Icon(
                                                        e['aceita_novas_coletas']
                                                            ? Icons.check
                                                            : Icons.close,
                                                      ),
                                                      subtitle: Text(
                                                        "${distance.toStringAsFixed(1)}km\n${e['nivel_lixo_porcentagem'].toString()}%",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                              if (selected != null)
                                ListTile(
                                  title: Text(selected!['nome'].toString()),
                                  subtitle: Row(
                                    spacing: 20,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            points.add(
                                              LatLng(
                                                selected!['latitude'],
                                                selected!['longitude'],
                                              ),
                                            );
                                          });
                                        },
                                        child: Text("Traça Rota"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Checkin(),
                                            ),
                                          );
                                        },
                                        child: Text("Ir para Check-In"),
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                child: GoogleMap(
                                  myLocationButtonEnabled: true,
                                  myLocationEnabled: true,
                                  polylines: {
                                    Polyline(
                                      polylineId: PolylineId('rotas'),
                                      points: points,
                                    ),
                                  },
                                  markers: {
                                    Marker(
                                      markerId: MarkerId('caminhao'),
                                      position: LatLng(
                                        data['caminhao']['latitude'] ?? 0.0,
                                        data['caminhao']['longitude'] ?? 0.0,
                                      ),
                                      icon:
                                          icon ??
                                          BitmapDescriptor.defaultMarkerWithHue(
                                            BitmapDescriptor.hueViolet,
                                          ),
                                    ),
                                    ...(data['pontos_coleta'] as List)
                                        .where(
                                          (element) => element['nome']
                                              .toString()
                                              .contains(search.text),
                                        )
                                        .map((e) {
                                          return Marker(
                                            alpha: e['aceita_novas_coletas']
                                                ? 1.0
                                                : 0.4,
                                            onTap: () {
                                              if (e['aceita_novas_coletas']) {
                                                setState(() {
                                                  selected = e;
                                                });
                                              }
                                            },
                                            icon:
                                                BitmapDescriptor.defaultMarkerWithHue(
                                                  BitmapDescriptor.hueGreen,
                                                ),
                                            markerId: MarkerId(
                                              e['id'].toString(),
                                            ),
                                            position: LatLng(
                                              e['latitude'],
                                              e['longitude'],
                                            ),
                                          );
                                        }),
                                  },
                                  initialCameraPosition: CameraPosition(
                                    zoom: 10,
                                    target: LatLng(
                                      userP!.latitude,
                                      userP!.longitude,
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                child: ListTile(
                                  title: Text("Motorista: Ana Silva"),
                                  subtitle: Text("Tempo Restante: 15min"),
                                ),
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

final dynamic data = {
  "caminhao": {
    "id_frota": "CAM-01",
    "latitude": -22.9250,
    "longitude": -45.4610,
    "status": "em_rota",
    "ultima_atualizacao": "2026-08-27T11:40:00",
  },
  "pontos_coleta": [
    {
      "id": 1,
      "nome": "Ecoponto Centro",
      "latitude": -22.9225,
      "longitude": -45.4580,
      "nivel_lixo_porcentagem": 45,
      "aceita_novas_coletas": true,
      "avaliacao_cliente": 4.8,
      "capacidade_entulho_restante": "2.5 toneladas",
    },
    {
      "id": 2,
      "nome": "Ponto de Descarte Norte",
      "latitude": -22.9100,
      "longitude": -45.4500,
      "nivel_lixo_porcentagem": 100,
      "aceita_novas_coletas": false,
      "avaliacao_cliente": 4.2,
      "capacidade_entulho_restante": "0 toneladas",
    },
    {
      "id": 3,
      "nome": "Galpão de Reciclagem Sul",
      "latitude": -22.9350,
      "longitude": -45.4700,
      "nivel_lixo_porcentagem": 80,
      "aceita_novas_coletas": true,
      "avaliacao_cliente": 4.5,
      "capacidade_entulho_restante": "1.0 tonelada",
    },
    {
      "id": 4,
      "nome": "Caçamba Comunitária Leste",
      "latitude": -22.9200,
      "longitude": -45.4400,
      "nivel_lixo_porcentagem": 15,
      "aceita_novas_coletas": true,
      "avaliacao_cliente": 3.9,
      "capacidade_entulho_restante": "5.0 toneladas",
    },
    {
      "id": 5,
      "nome": "Ecoponto Distrito Industrial",
      "latitude": -22.9450,
      "longitude": -45.4850,
      "nivel_lixo_porcentagem": 100,
      "aceita_novas_coletas": false,
      "avaliacao_cliente": 4.9,
      "capacidade_entulho_restante": "0 toneladas",
    },
  ],
};
