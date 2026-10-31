import 'package:flutter/material.dart';

class Dash extends StatefulWidget {
  const Dash({super.key});
  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  Future<void> startApp() async {}
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
        automaticallyImplyLeading: false,
        title: ListTile(
          title: Text(
            "Dashborad",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          subtitle: Text("Hoje"),
        ),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          spacing: 30,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                spacing: 20,
                children: [
                  ...([
                    {
                      "1": "Pedidos do dia",
                      "2": "16",
                      "3": Icon(Icons.shopping_bag),
                    },
                    {
                      "1": "Faturamento",
                      "2": "R\$ 809,57",
                      "3": Icon(Icons.money),
                    },
                    {
                      "1": "Pedidos em andamento",
                      "2": "4",
                      "3": Icon(Icons.bike_scooter),
                    },
                  ] as List<Map<String, dynamic>>).map(
                    (e) => Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e['1'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  e['3'],
                                ],
                              ),
                              Text(
                                e['2'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 60,
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
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text("Faturamento dos últimos 7 dias"),
                            ),
                            Expanded(
                              child: Row(
                                spacing: 20,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ...[8, 7, 6, 5, 4, 3, 2, 1, 0].map(
                                        (e) => e == 0
                                            ? SizedBox.shrink()
                                            : Text("R\$$e K"),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Row(
                                      spacing: 40,
                                      children: [
                                        ...faturamento.map(
                                          (e) => Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              spacing: 20,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                  ),
                                                  width: double.infinity,
                                                  height:
                                                      300 *
                                                      ((e['valor'] as int) /
                                                          8000),
                                                ),
                                                Text(e['dia'].toString()),
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text("Pedidos recentes"),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemBuilder: (context, index) {
                                  final icon =
                                      switch (pedidosR[index]['status']) {
                                        == "Novo" => Icon(Icons.checklist),
                                        == "Pronto" => Icon(Icons.check),
                                        _ => Icon(Icons.lunch_dining),
                                      };

                                  return ListTile(
                                    title: Text("#${pedidosR[index]['id']}"),

                                    subtitle: Text(
                                      pedidosR[index]['cliente'].toString(),
                                    ),
                                    trailing: Chip(
                                      label: Text(
                                        pedidosR[index]['status'].toString(),
                                      ),
                                    ),
                                    leading: icon,
                                  );
                                },
                                itemCount: pedidosR.length,
                                shrinkWrap: true,
                              ),
                            ),
                          ],
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

final pedidosR = [
  {"id": 87234, "cliente": "Mariana Costa", "status": "Novo"},
  {"id": 87233, "cliente": "Rafael Mendes", "status": "Novo"},
  {"id": 87232, "cliente": "Juliana Alves", "status": "Novo"},
  {"id": 87231, "cliente": "Carlos Eduardo", "status": "Em preparo"},
  {"id": 87230, "cliente": "Fernanda Lima", "status": "Em preparo"},
  {"id": 87229, "cliente": "Gustavo Barbosa", "status": "Em preparo"},
  {"id": 87228, "cliente": "Giovanna Silva", "status": "Pronto"},
  {"id": 87227, "cliente": "Bruno Oliveira", "status": "Pronto"},
];

final faturamento = [
  {"dia": "SEG", "valor": 3200},
  {"dia": "TER", "valor": 4800},
  {"dia": "QUA", "valor": 2100},
  {"dia": "QUI", "valor": 6700},
  {"dia": "SEX", "valor": 5900},
  {"dia": "SAB", "valor": 7800},
  {"dia": "DOM", "valor": 4500},
];
