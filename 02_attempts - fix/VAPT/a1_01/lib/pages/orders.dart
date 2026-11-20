import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  Timer? pollingTimer;
  Timer? callTimer;
  bool loading = true;
  bool offline = false;
  dynamic order = {};
  List<LatLng> trail = [];

  String money(dynamic value) =>
      "R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}";

  Future<void> fetchOrder() async {
    try {
      final share = await SharedPreferences.getInstance();
      final res = await http.get(
        Uri.parse('http://10.109.66.126:3000/orders/8821'),
        headers: {'Authorization': 'Bearer ${share.getString('token') ?? ''}'},
      );
      if (res.statusCode != 200 || !mounted) return;

      final json = jsonDecode(res.body);
      final position = LatLng(
        json['location']['latitude'].toDouble(),
        json['location']['longitude'].toDouble(),
      );
      if (trail.isEmpty || trail.last != position) trail.add(position);
      setState(() {
        order = json;
        loading = false;
      });
    } catch (e) {
      // sem rede: mantém os últimos dados válidos
    }
  }

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        offline = true;
        Fluttertoast.showToast(
          msg:
              'Sem conectividade. Aguardando reconexão para atualizar o rastreamento...',
          backgroundColor: Colors.red,
        );
      } else if (offline) {
        offline = false;
        fetchOrder();
      }
    });
    fetchOrder();
    pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!offline) fetchOrder();
    });
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Produtos - Descontos + Entrega
    final total = order['subtotal'] - order['discount'] + order['deliveryFee'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text("Acompanhamento de Pedido"),
        actions: const [Icon(Icons.help), SizedBox(width: 12)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 260,
              child: Stack(
                children: [
                  // latitude e longitude animadas: o marcador desliza até o novo ponto
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: trail.last.latitude),
                    duration: const Duration(seconds: 4),
                    builder: (context, lat, _) => TweenAnimationBuilder<double>(
                      tween: Tween(end: trail.last.longitude),
                      duration: const Duration(seconds: 4),
                      builder: (context, lng, _) => GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: trail.last,
                          zoom: 15,
                        ),
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('courier'),
                            position: LatLng(lat, lng),
                          ),
                        },
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId('trail'),
                            points: trail,
                            width: 5,
                            color: Colors.blue,
                          ),
                        },
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 10,
                    left: 10,
                    child: Chip(
                      backgroundColor: Colors.white,
                      avatar: Icon(Icons.circle, color: Colors.red, size: 12),
                      label: Text("Rastreamento ao Vivo"),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Chegada em..."),
              subtitle: Text(
                "${order['estimatedMin']} - ${order['estimatedMax']} min",
              ),
            ),
            ListTile(
              title: const Text("Entregador"),
              subtitle: Text(order['courier']['name'].toString()),
              trailing: const Icon(Icons.contact_emergency),
            ),
            for (final step in order['timeline'])
              ListTile(
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step['state'] == 'completed'
                        ? Colors.green
                        : step['state'] == 'current'
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                ),
                title: Text(
                  step['step'].toString(),
                  style: TextStyle(
                    fontWeight: step['current'] == true
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            // liga só se segurar 2 segundos; soltar antes cancela
            GestureDetector(
              onTapDown: (_) {
                if (order['courier']['contactAuthorized'] != true) return;
                callTimer = Timer(const Duration(seconds: 2), () {
                  final phone = order['courier']['phone'].toString().replaceAll(
                    RegExp(r'[^0-9+]'),
                    '',
                  );
                  launchUrl(Uri(scheme: 'tel', path: phone));
                });
              },
              onTapUp: (_) => callTimer?.cancel(),
              onTapCancel: () => callTimer?.cancel(),
              child: Container(
                width: double.infinity,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.black,
                child: const ListTile(
                  leading: Icon(Icons.phone, color: Colors.white),
                  title: Text(
                    "Pressione e segure para ligar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: const Text(
                "Resumo do Pedido #8821",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Column(
                  children: [
                    for (final item in order['items'])
                      ListTile(
                        dense: true,
                        title: Text("${item['quantity']}x ${item['name']}"),
                        trailing: Text(money(item['price'])),
                      ),
                    ListTile(
                      dense: true,
                      title: const Text("Desconto"),
                      trailing: Text(
                        "- ${money(order['discount'])}",
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    ListTile(
                      dense: true,
                      title: const Text("Entrega"),
                      trailing: Text(money(order['deliveryFee'])),
                    ),
                    ListTile(
                      title: const Text(
                        "Total",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Text(
                        money(total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
