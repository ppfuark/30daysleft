import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with TickerProviderStateMixin {
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
                      'Acompanhamento de Pedidos',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Segure e arrastre os itens para move-los entre as colunas.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...[
                          "Pronto para retirada",
                          "Em preparo",
                          "Novo",
                        ].reversed.map(
                          (e) => Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e == "Novo"
                                          ? "Novos Pedidos"
                                          : e == "Pronto para retirada"
                                          ? "Prontos para a Retirada"
                                          : e,
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final o = orders
                                              .where(
                                                (element) =>
                                                    element['status'] == e,
                                              )
                                              .toList()[index];

                                          return SizedBox(
                                            height: 200,
                                            child: Card(
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: ListTile(
                                                      title: Text(
                                                        "#${o['id']}",
                                                      ),
                                                      subtitle: Text(
                                                        o['cliente'].toString(),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10.0,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          "R\$ ${o['valor'].toString().replaceAll('.', ',')}",
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        itemCount: orders
                                            .where(
                                              (element) =>
                                                  element['status'] == e,
                                            )
                                            .length,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
  {"id": 87234, "cliente": "Mariana Costa", "valor": 65.89, "status": "Novo"},
  {"id": 87233, "cliente": "Rafael Mendes", "valor": 43.49, "status": "Novo"},
  {"id": 87232, "cliente": "Juliana Alves", "valor": 76.98, "status": "Novo"},
  {
    "id": 87231,
    "cliente": "Carlos Eduardo",
    "valor": 53.48,
    "status": "Em preparo",
  },
  {
    "id": 87230,
    "cliente": "Fernanda Lima",
    "valor": 176.53,
    "status": "Em preparo",
  },
  {
    "id": 87229,
    "cliente": "Gustavo Barbosa",
    "valor": 83.86,
    "status": "Em preparo",
  },
  {
    "id": 87228,
    "cliente": "Giovanna Silva",
    "valor": 123.36,
    "status": "Pronto para retirada",
  },
  {
    "id": 87227,
    "cliente": "Bruno Oliveira",
    "valor": 98.54,
    "status": "Pronto para retirada",
  },
];
