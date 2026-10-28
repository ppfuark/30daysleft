import 'package:c1_01/pages/check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapa extends StatefulWidget {
  final Map<String, dynamic> me;

  const Mapa({super.key, required this.me});
  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final search = TextEditingController();

  Future<void> startApp() async {
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();

    position = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    startApp();
  }

  Set<Polyline> polyline = {};
  Position? position;
  Map<String, dynamic>? selected;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text("Restreamento", style: TextStyle(color: Colors.green)),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/icons/FotoUsuario.jpg'),
          ),
          Icon(Icons.notifications),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          spacing: 20,
          children: [
            CupertinoSearchTextField(
              controller: search,
              placeholder: "Buscar pontos de coleta",
            ),
            if (selected != null)
              ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(selected!['nome'].toString()),
                subtitle: Row(
                  spacing: 20,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          polyline = {
                            Polyline(
                              polylineId: PolylineId('rota'),
                              points: [
                                LatLng(position!.latitude, position!.longitude),
                                LatLng(
                                  double.parse(
                                    selected!['latitude'].toString(),
                                  ),
                                  double.parse(
                                    selected!['longitude'].toString(),
                                  ),
                                ),
                              ],
                            ),
                          };
                        });
                      },
                      child: Text("Traçar Rota"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Check()),
                        );
                      },
                      child: Text("Ir para Check-in"),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: position == null
                  ? Center(child: Text("Aguardando a posição do usuário."))
                  : GoogleMap(
                      polylines: polyline,
                      initialCameraPosition: CameraPosition(
                        zoom: 9.5,
                        target: LatLng(position!.latitude, position!.longitude),
                      ),
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      markers: {
                        Marker(
                          markerId: MarkerId(data['caminhao']['id'].toString()),
                          position: LatLng(
                            double.parse(
                              data['caminhao']['latitude'].toString(),
                            ),
                            double.parse(
                              data['caminhao']['longitude'].toString(),
                            ),
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueGreen,
                          ),
                        ),

                        ...data['pontos_coleta']
                            .map(
                              (e) => Marker(
                                alpha: e['aceita_novas_coletas'] ? 1.0 : 0.4,
                                onTap: () {
                                  setState(() {
                                    if (e['aceita_novas_coletas']) {
                                      selected = e;
                                    }
                                  });
                                },
                                markerId: MarkerId(e['id'].toString()),
                                position: LatLng(
                                  double.parse(e['latitude'].toString()),
                                  double.parse(e['longitude'].toString()),
                                ),
                              ),
                            )
                            .toSet(),
                      },
                    ),
              //               "id": 1,
              // "nome": "Ecoponto Centro",
              // "latitude": -22.9225,
              // "longitude": -45.4580,
              // "nivel_lixo_porcentagem": 45,
              // "aceita_novas_coletas": true,
              // "avaliacao_cliente": 4.8,
              // "capacidade_entulho_restante": "2.5 toneladas",
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Acesso Rápido"),
              subtitle: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...data['pontos_coleta'].map(
                      (e) => SizedBox(
                        height: 80,
                        width: 250,
                        child: ListTile(
                          tileColor: Colors.green,
                          onTap: () {},
                          title: Text(
                            e['nome'].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Nível do lixo: ${e['nivel_lixo_porcentagem']}%",
                            style: TextStyle(color: Colors.white),
                          ),
                          leading: Icon(Icons.check, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Nome da frota: ${data['caminhao']['id_frota']}"),
              subtitle: Text(
                "Ultima atualização: ${data['caminhao']['ultima_atualizacao'].toString().replaceAll("-", "/").replaceAll("T", " ")}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final Map<String, dynamic> data = {
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
