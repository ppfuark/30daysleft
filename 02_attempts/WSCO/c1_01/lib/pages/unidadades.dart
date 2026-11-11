import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xml/xml.dart';

class Unidadades extends StatefulWidget {
  final Map<String, dynamic> me;

  const Unidadades({super.key, required this.me});
  @override
  State<Unidadades> createState() => _UnidadadesState();
}

class _UnidadadesState extends State<Unidadades> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  List users = [];
  List posts = [];
  List comments = [];
  List chats = [];
  List schools = [];
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
      final raw4 = await rootBundle.loadString('assets/senai_sp_unidades.json');
      final jso4 = jsonDecode(raw4);
      setState(() {
        schools = jso4;
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

      if (DateTime.now().hour < 8 || DateTime.now().hour > 17) {
        setState(() {
          out = true;
        });
      }

      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      await Geolocator.requestPermission();
      userP = await Geolocator.getCurrentPosition();

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

  bool out = false;

  Map<String, dynamic>? selected;
  List modalidades = ['08', '09', '17'];
  String m = '08';

  Position? userP;

  Set<Polyline> polyline = {};

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

  int index = 0;
  final search = TextEditingController();

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
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        ListTile(
                          title: Text("Unidades"),
                          trailing: ToggleButtons(
                            isSelected: [index == 0, index == 1],
                            selectedColor: Colors.blue,
                            borderRadius: BorderRadius.circular(999),
                            onPressed: (index) {
                              setState(() {
                                this.index = index;
                              });
                            },
                            children: [
                              Padding(
                                padding: EdgeInsetsGeometry.all(10),
                                child: Row(
                                  children: [Text("Lista"), Icon(Icons.list)],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsGeometry.all(10),
                                child: Row(
                                  children: [
                                    Text("Mapa"),
                                    Icon(Icons.location_pin),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text("Modalidades"),
                          subtitle: DropdownButton(
                            items: [
                              ...modalidades.map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              ),
                            ],
                            onChanged: (value) {
                              m = value.toString();
                              setState(() {});
                            },
                            value: m,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected != null)
                    Card(
                      child: ListTile(
                        title: Text(selected!['nome'].toString()),
                        subtitle: Text(
                          "${users.firstWhere((element) => selected!['nome'].toString().contains(element['escola'].toString()) && element['perfil'] == 'avaliador', orElse: () => {'nome': 'Sem avaliador'})['nome'].toString()}\n${users.firstWhere((element) => selected!['nome'].toString().contains(element['escola'].toString()) && element['perfil'] == 'competidor', orElse: () => {'nome': 'Sem competidor'})['nome'].toString()}",
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              polyline = {
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
                    ),
                  Expanded(
                    child: index == 1
                        ? userP == null
                              ? Center(
                                  child: Text(
                                    "Aguardando posição do usuário...",
                                  ),
                                )
                              : GoogleMap(
                                  polylines: polyline,
                                  myLocationButtonEnabled: true,
                                  myLocationEnabled: true,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                      userP!.latitude,
                                      userP!.longitude,
                                    ),
                                    zoom: 9.5,
                                  ),
                                  markers: {
                                    ...schools
                                        .where(
                                          (element) =>
                                              (element['modalidades'] ?? [])
                                                  .contains(m),
                                        )
                                        .map((e) {
                                          return Marker(
                                            alpha: out ? 0.4 : 1.0,
                                            onTap: () {
                                              if (out) return;

                                              if ((Geolocator.distanceBetween(
                                                        userP!.latitude,
                                                        userP!.longitude,
                                                        double.parse(
                                                          e['latitude'],
                                                        ),
                                                        double.parse(
                                                          e['longitude'],
                                                        ),
                                                      )) /
                                                      1000 >
                                                  50) {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      'Para esta unidade, você tem direito a hospedagem!',
                                                  backgroundColor: Colors.green,
                                                );
                                              }
                                              setState(() {
                                                selected = e;
                                              });
                                            },
                                            markerId: MarkerId(
                                              e['id'].toString(),
                                            ),
                                            position: LatLng(
                                              double.parse(e['latitude']),
                                              double.parse(e['longitude']),
                                            ),
                                            icon:
                                                BitmapDescriptor.defaultMarkerWithHue(
                                                  e['nome'].toString().contains(
                                                        widget.me['escola']
                                                            .toString(),
                                                      )
                                                      ? BitmapDescriptor
                                                            .hueAzure
                                                      : BitmapDescriptor.hueRed,
                                                ),
                                          );
                                        }),
                                  },
                                )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                ...schools
                                    .where(
                                      (element) =>
                                          (element['modalidades'] ?? [])
                                              .contains(m),
                                    )
                                    .map((e) {
                                      return ListTile(
                                        onTap: () {
                                          if (out) return;
                                          setState(() {
                                            selected = e;
                                          });
                                        },
                                        title: Text(e['nome'].toString()),
                                        subtitle: Text(
                                          e['endereco'].toString(),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
  }
}
