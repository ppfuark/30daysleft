import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller1;
  bool loading = true;

  final search = TextEditingController();

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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..forward();
    _controller1 =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..forward()
          ..repeat(reverse: true);
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return loading
        ? Scaffold(
            resizeToAvoidBottomInset: false,

            body: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,

            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Hoje',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            width: w,
                            child: Row(
                              children: [
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _controller,
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Pedidos do dia"),
                                                Icon(Icons.shopping_bag),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              search.text.isNotEmpty
                                                  ? orders
                                                        .where(
                                                          (element) =>
                                                              element['cliente']
                                                                  .toString()
                                                                  .contains(
                                                                    search.text,
                                                                  ),
                                                        )
                                                        .length
                                                        .toString()
                                                  : "16",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 80,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _controller,
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Faturamento"),
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.attach_money,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              "R\$ 809, 57",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 80,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FadeTransition(
                                    opacity: _controller,
                                    child: Card(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Pedidos em andamento"),
                                                Icon(Icons.bike_scooter),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              "4",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 80,
                                              ),
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
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: FadeTransition(
                                    opacity: _controller,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 20,
                                          children: [
                                            Text(
                                              "Faturamento dos últimos 7 dias",
                                            ),
                                            Expanded(
                                              child: Row(
                                                spacing: 30,
                                                children: [
                                                  SizedBox(
                                                    height: double.infinity,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        ...[
                                                          0,
                                                          1,
                                                          2,
                                                          3,
                                                          4,
                                                          5,
                                                          6,
                                                          7,
                                                          8,
                                                        ].reversed.map(
                                                          (e) => Text(
                                                            "R\$ $e${e + e == 0 ? "" : "K"} ",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Builder(
                                                      builder: (context) {
                                                        return LayoutBuilder(
                                                          builder: (context, constraints) {
                                                            final wB =
                                                                constraints
                                                                    .maxWidth;
                                                            final hB =
                                                                constraints
                                                                    .maxHeight;
                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              spacing: 20,
                                                              children: [
                                                                ...fat.map((e) {
                                                                  return Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,

                                                                    children: [
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.deepOrangeAccent,
                                                                        ),
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            hB *
                                                                            (((e['valor']
                                                                                        as int) /
                                                                                    8000) *
                                                                                .85),
                                                                      ),
                                                                      Text(
                                                                        e['dia']
                                                                            .toString(),
                                                                      ),
                                                                    ],
                                                                  );
                                                                }),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
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
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Pedidos Recentes"),
                                          TextField(
                                            key: Key("home_search"),
                                            controller: search,
                                            decoration: InputDecoration(
                                              suffixIcon: IconButton(
                                                key: Key('home_clear'),
                                                onPressed: () {
                                                  setState(() {
                                                    search.clear();
                                                  });
                                                },
                                                icon: Icon(Icons.clear),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                          ),
                                          Expanded(
                                            child: ReorderableListView.builder(
                                              itemBuilder: (context, index) {
                                                final o = orders
                                                    .where(
                                                      (element) =>
                                                          element['cliente']
                                                              .toString()
                                                              .contains(
                                                                search.text,
                                                              ),
                                                    )
                                                    .toList()[index];

                                                final icon =
                                                    switch (o['status']) {
                                                      "Novo" => Icon(
                                                        Icons.assignment,
                                                      ),
                                                      "Em preparo" => Icon(
                                                        Icons.dinner_dining,
                                                      ),
                                                      _ => Icon(Icons.check),
                                                    };

                                                return ListTile(
                                                  key: Key(o['id'].toString()),
                                                  leading: icon,
                                                  title: Text("#${o['id']}"),
                                                  subtitle: Text(
                                                    "${o['cliente']}",
                                                  ),
                                                  trailing: AnimatedBuilder(
                                                    animation: _controller1,
                                                    builder: (context, c) {
                                                      return Chip(
                                                        backgroundColor:
                                                            o['status'] ==
                                                                "Novo"
                                                            ? Color.lerp(
                                                                Colors.white,
                                                                Colors
                                                                    .red
                                                                    .shade100,
                                                                _controller1
                                                                    .value,
                                                              )
                                                            : null,
                                                        label: Text(
                                                          o['status']
                                                              .toString(),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                );
                                              },
                                              itemCount: orders
                                                  .where(
                                                    (element) =>
                                                        element['cliente']
                                                            .toString()
                                                            .contains(
                                                              search.text,
                                                            ),
                                                  )
                                                  .length,
                                              onReorder: (oldIndex, newIndex) {
                                                if (newIndex > oldIndex) {
                                                  newIndex--;
                                                }
                                                final item = orders.removeAt(
                                                  oldIndex,
                                                );
                                                setState(() {
                                                  orders.insert(newIndex, item);
                                                });
                                              },
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
                  ),
                ],
              ),
            ),
          );
  }
}

final orders = [
  {"id": 87234, "cliente": "Mariana Costa", "status": "Novo"},
  {"id": 87233, "cliente": "Rafael Mendes", "status": "Novo"},
  {"id": 87232, "cliente": "Juliana Alves", "status": "Novo"},
  {"id": 87231, "cliente": "Carlos Eduardo", "status": "Em preparo"},
  {"id": 87230, "cliente": "Fernanda Lima", "status": "Em preparo"},
  {"id": 87229, "cliente": "Gustavo Barbosa", "status": "Em preparo"},
  {"id": 87228, "cliente": "Giovanna Silva", "status": "Pronto"},
  {"id": 87227, "cliente": "Bruno Oliveira", "status": "Pronto"},
];

final fat = [
  {"dia": "SEG", "valor": 3200},
  {"dia": "TER", "valor": 4800},
  {"dia": "QUA", "valor": 2100},
  {"dia": "QUI", "valor": 6700},
  {"dia": "SEX", "valor": 5900},
  {"dia": "SAB", "valor": 7800},
  {"dia": "DOM", "valor": 4500},
];
