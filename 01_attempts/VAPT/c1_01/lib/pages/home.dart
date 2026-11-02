import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Position? userP;

  Future<void> startApp() async {
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();
    await Geolocator.requestPermission();

    userP = await Geolocator.getCurrentPosition();
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
            : Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      polylines: {
                        Polyline(
                          polylineId: PolylineId("rota"),
                          points: [
                            LatLng(userP!.latitude, userP!.longitude),
                            LatLng(userP!.latitude - 1, userP!.longitude - 2),
                          ],
                        ),
                      },
                      markers: {
                        Marker(
                          markerId: MarkerId("a"),
                          position: LatLng(
                            userP!.latitude - 1,
                            userP!.longitude - 2,
                          ),
                        ),
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(userP!.latitude, userP!.longitude),
                        zoom: 9.5,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      width: 150,
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
                ],
              ),
      ),
    );
  }
}
