import 'package:flutter/material.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key});
  @override
  State<Delivery> createState() => _DeliveryState();
}

class _DeliveryState extends State<Delivery> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  Future<void> startApp() async {
    try {
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

  Map<String, dynamic> selected = orders.first;

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
                    title: Text(
                      'Central de Entregras',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Selecione uma entrega para ver no mapa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              final o = orders[index];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selected = o;
                                  });
                                },
                                child: SizedBox(
                                  height: 200,
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ListTile(
                                            title: Text("#${o['pedidoId']}"),
                                            subtitle: Text(
                                              o['cliente'].toString(),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                o['status'] == "Em rota"
                                                    ? "Em Rota"
                                                    : o['status'].toString(),
                                              ),
                                              Text(
                                                "R\$ ${o['valor'].toString().replaceAll('.', ',')}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: orders.length,
                            shrinkWrap: true,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    'assets/images/${selected['status'] == "Em rota" ? "pedido_em_rota.png" : "pedido_entregue.png"}',
                                  ),
                                ),
                                Row(
                                  spacing: 20,
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text("Tempo Estimado"),
                                        subtitle: Text(
                                          selected['tempoEstimado'].toString(),
                                        ),
                                        leading: Icon(Icons.watch_later),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListTile(
                                        title: Text("Entregador"),
                                        subtitle: Text(
                                          selected['entregador'].toString(),
                                        ),
                                        leading: Icon(Icons.bike_scooter),
                                      ),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  title: Text("Progresso da Entrega"),
                                  subtitle: LinearProgressIndicator(
                                    backgroundColor: Colors.grey.shade200,
                                    minHeight: 10,
                                    color: Colors.deepOrangeAccent,
                                    value: selected['status'] == "Em rota"
                                        ? 0.6
                                        : 1.0,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selected['status'] = "Entregue";
                                    });
                                  },
                                  child: Text("Confirmar Entrega"),
                                ),
                              ],
                            ),
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

final orders = [
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
