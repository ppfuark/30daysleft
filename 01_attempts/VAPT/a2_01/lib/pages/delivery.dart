import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key});
  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> {
  Future<void> startApp() async {}
  @override
  void initState() {
    super.initState();
    startApp();
  }

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: ListTile(
          title: Text(
            "Central de Entregas",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          subtitle: Text("Selecione uma entrega para ver no mapa"),
        ),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final f = orders[index];

                  return Card(
                    child: ListTile(
                      tileColor: selected == index
                          ? Colors.grey.shade300
                          : null,
                      onTap: () {
                        setState(() {
                          selected = index;
                        });
                      },
                      title: Text("#${f['pedidoId']}"),
                      subtitle: Text(f['cliente'].toString()),
                      trailing: Text(
                        textAlign: TextAlign.right,
                        "${f['status']}\nR\$ ${f['valor']}",
                      ),
                    ),
                  );
                },
                itemCount: orders.length,
                shrinkWrap: true,
              ),
            ),
            Expanded(
              flex: 4,
              child: Column(
                spacing: 20,
                children: [
                  Expanded(
                    child: Image.asset(
                      width: double.infinity,
                      orders[selected]['status'] == "Em rota"
                          ? 'assets/images/pedido_em_rota.png'
                          : 'assets/images/pedido_entregue.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: ListTile(
                            title: Text("Tempo Estimado"),
                            leading: Icon(Icons.watch_later),
                            subtitle: Text(
                              orders[selected]['tempoEstimado'].toString(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: ListTile(
                            title: Text("Entregador"),
                            leading: Icon(Icons.bike_scooter),
                            subtitle: Text(
                              orders[selected]['entregador'].toString(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: ListTile(
                      title: Text("Progresso da Entrega"),
                      subtitle: LinearProgressIndicator(
                        value: 0.8,
                        color: Colors.deepOrange,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          orders[selected]['status'] = "Entregue";
                        });
                      },
                      child: Text("Confirmar Entrega"),
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

List orders = [
  {
    "pedidoId": 87234,
    "cliente": "Mariana Costa",
    "status": "Em rota",
    "valor": 65.89,
    "tempoEstimado": "12 min",
    "entregador": "João Ferreira",
  },
  {
    "pedidoId": 87235,
    "cliente": "Carlos Eduardo",
    "status": "Em rota",
    "valor": 42.50,
    "tempoEstimado": "8 min",
    "entregador": "Ana Oliveira",
  },
  {
    "pedidoId": 87236,
    "cliente": "Fernanda Lima",
    "status": "Entregue",
    "valor": 87.90,
    "tempoEstimado": "0 min",
    "entregador": "Lucas Santos",
  },
];
