import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Schools extends StatefulWidget {
  final Map<String, dynamic> me;

  const Schools({super.key, required this.me});
  @override
  State<Schools> createState() => _SchoolsState();
}

class _SchoolsState extends State<Schools> {
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

    await Geolocator.requestPermission();
    userP = await Geolocator.getCurrentPosition();
    setState(() {});
  }

  Map<String, dynamic>? selected;
  int index = 0;

  List<String> modals = ['08', '09', '17'];
  String modal = '08';

  final text = TextEditingController();

  Position? userP;

  Set<Polyline> poly = {};

  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final schoolsM = schools.where(
      (element) =>
          ((element['modalidades'] ?? []) as List).contains(modal) &&
          element['nome'].toString().contains(text.text),
    );

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Unidades"),
        actions: [
          ToggleButtons(
            isSelected: [index == 0, index == 1],
            onPressed: (index) {
              setState(() {
                this.index = index;
              });
            },
            children: [
              Row(children: [Icon(Icons.list), Text("Lista")]),
              Row(children: [Icon(Icons.location_pin), Text("Mapa")]),
            ],
          ),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          spacing: 10,
          children: [
            DropdownButton(
              items: [
                ...modals.map(
                  (e) => DropdownMenuItem(value: e, child: Text(e)),
                ),
              ],
              onChanged: (value) => setState(() {
                modal = value!;
              }),
              value: modal,
            ),
            TextField(controller: text, onChanged: (value) => setState(() {})),
            if (selected != null)
              ListTile(
                title: Text(selected!['nome'].toString()),
                subtitle: Text(
                  "${users.firstWhere((element) => element['escola'] == selected!['nome'].toString() && element['perfil'] == 'avaliador', orElse: () => {'nome': 'Não cadastrado'})['nome']}\n${users.firstWhere((element) => element['escola'] == selected!['nome'].toString() && element['perfil'] == 'competidor', orElse: () => {'nome': 'Não cadastrado'})['nome']}",
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      poly = {
                        Polyline(
                          polylineId: PolylineId('rota'),
                          points: [
                            LatLng(
                              double.parse(selected!['latitude']),
                              double.parse(selected!['longitude']),
                            ),
                            LatLng(userP!.latitude, userP!.longitude),
                          ],
                        ),
                      };
                    });
                  },
                  child: Text("Traçar Rota"),
                ),
              ),
            Expanded(
              child: userP == null
                  ? Center(
                      child: Text("Esperando a localização do usuário...."),
                    )
                  : index == 0
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        final s = schoolsM.toList()[index];
                        return ListTile(
                          title: Text(s['nome'].toString()),
                          onTap: () => setState(() {
                            selected = s;
                          }),
                        );
                      },
                      itemCount: schoolsM.length,
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(userP!.latitude, userP!.longitude),
                        zoom: 9.5,
                      ),
                      polylines: poly,
                      markers: {
                        ...schoolsM.map(
                          (e) => Marker(
                            onTap: () => setState(() {
                              selected = e;

                              if (Geolocator.distanceBetween(
                                        double.parse(e['latitude']),
                                        double.parse(e['longitude']),
                                        userP!.latitude,
                                        userP!.longitude,
                                      ) /
                                      100 >
                                  50) {
                                Fluttertoast.showToast(
                                  msg: 'Para esta unidade, você tem direito a hospedagem!',
                                  backgroundColor: Colors.green,
                                );
                              }
                            }),
                            markerId: MarkerId(e['id'].toString()),
                            position: LatLng(
                              double.parse(e['latitude']),
                              double.parse(e['longitude']),
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              e['nome'] == widget.me['escola']
                                  ? BitmapDescriptor.hueAzure
                                  : BitmapDescriptor.hueRed,
                            ),
                          ),
                        ),
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
