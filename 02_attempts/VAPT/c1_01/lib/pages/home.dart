import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng? userP;
  BitmapDescriptor? bikeIcon;
  Timer? simulatedTimer;

  List<LatLng> route = [];
  double travelM = 0;
  bool vibrated = false;

  bool simulated = false;

  Future<void> startApp() async {
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();

    bikeIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      "assets/bikeicone.png",
    );
    setState(() {});

    final first = await Geolocator.getCurrentPosition();

    setState(() {
      userP = LatLng(first.latitude, first.longitude);
    });

    route.add(userP!);
    setState(() {});

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 3,
      ),
    ).listen((event) {
      if (simulated) return;

      final last = route.last;
      travelM += Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        event.latitude,
        event.longitude,
      );
      route.add(LatLng(event.latitude, event.longitude));

      if (travelM >= 5000 && !vibrated) {
        vibrated = true;
        print('vibrou');
        HapticFeedback.vibrate();
      }

      setState(() {
        userP = LatLng(event.latitude, event.longitude);
      });
    });
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
    Color routeC = Colors.blue;
    if (travelM > 10000) {
      routeC = Colors.red;
    } else if (travelM > 5000) {
      routeC = Colors.orange;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, Driver!"),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: userP == null
            ? Center(child: Text("Aguardando posição..."))
            : Column(
                children: [
                  ListTile(
                    title: Text(
                      "Teste andando e anote resultado;\n Para simular distâncias maiores (200m/s~ ao norte)",
                    ),
                    trailing: Switch(
                      value: simulated,
                      onChanged: (value) {
                        setState(() {
                          simulated = value;
                        });

                        if (simulated) {
                          simulatedTimer?.cancel();
                          simulatedTimer = Timer.periodic(
                            Duration(seconds: 1),
                            (timer) {
                              if (!simulated) return;

                              final last = route.last;
                              travelM += Geolocator.distanceBetween(
                                last.latitude,
                                last.longitude,
                                userP!.latitude + 0.0020,
                                userP!.longitude,
                              );
                              route.add(
                                LatLng(
                                  userP!.latitude + 0.0020,
                                  userP!.longitude,
                                ),
                              );

                              if (travelM >= 5000 && !vibrated) {
                                vibrated = true;
                                print("vibrou");
                                HapticFeedback.vibrate();
                              }

                              setState(() {
                                userP = LatLng(
                                  userP!.latitude + 0.0018,
                                  userP!.longitude,
                                );
                              });
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: GoogleMap(
                              myLocationButtonEnabled: true,
                              myLocationEnabled: true,
                              polylines: {
                                Polyline(
                                  polylineId: PolylineId("rota"),
                                  points: route,
                                  color: routeC,
                                ),
                              },
                              markers: {
                                Marker(
                                  markerId: MarkerId("moto"),
                                  position: LatLng(
                                    userP!.latitude,
                                    userP!.longitude,
                                  ),
                                  icon:
                                      bikeIcon ??
                                      BitmapDescriptor.defaultMarker,
                                ),
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  userP!.latitude,
                                  userP!.longitude,
                                ),
                                zoom: 16,
                              ),
                            ),
                          ),
                          Positioned(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.all(10),
                              width: 170,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text(
                                      style: TextStyle(color: Colors.black),
                                      "DISTÂNCIA",
                                    ),
                                    subtitle: Text(
                                      style: TextStyle(color: Colors.black),
                                      "2.4 KM",
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      style: TextStyle(color: Colors.black),
                                      "LATITUDE",
                                    ),
                                    subtitle: Text(
                                      style: TextStyle(color: Colors.black),
                                      userP!.latitude.toStringAsFixed(4),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      style: TextStyle(color: Colors.black),
                                      "LONGITUDE",
                                    ),
                                    subtitle: Text(
                                      style: TextStyle(color: Colors.black),
                                      userP!.longitude.toStringAsFixed(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (travelM > 10000)
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Você percorreu mais de 10 km. Retorne à base!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
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
