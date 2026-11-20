import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with TickerProviderStateMixin {
  late AnimationController _controller;
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
    _controller = AnimationController(vsync: this);
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String selected = "Todos";

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
                      'Acompanhamento de Pedidos',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Segure e arrastre os itens para movê-los entre as colunas.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  Row(
                    spacing: 50,
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Buscar por número ou cliente",
                            suffixIcon: IconButton(
                              key: Key('ord_clear'),
                              onPressed: () => setState(() {
                                search.clear();
                              }),
                              icon: Icon(Icons.clear),
                            ),
                          ),
                          controller: search,
                          key: Key('ord_search'),
              
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      Row(
                        spacing: 30,
                        children: [
                          ...types.map(
                            (e) => GestureDetector(
                              key: Key('chip_$e'),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Mudar status?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Não'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {
                                              selected = e;
                                            });
                                          },
                                          child: Text('Sim'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Chip(
                                backgroundColor: selected != e
                                    ? Colors.white
                                    : Colors.black,
                                label: Text(
                                  style: TextStyle(
                                    color: selected == e
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  e == "Novo"
                                      ? "Novo"
                                      : e == "Pronto para retirada"
                                      ? "Pronto para Retirada"
                                      : e == "Em preparo"
                                      ? "Em Preparo"
                                      : e,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...["Pronto para retirada", "Em preparo", "Novo"]
                            .where(
                              (element) =>
                                  selected == "Todos" || selected == element,
                            )
                            .toList()
                            .reversed
                            .map(
                              (e) => Expanded(
                                child: DragTarget<Map>(
                                  onWillAcceptWithDetails: (details) {
                                    return details.data['status'] != e;
                                  },
                                  onAcceptWithDetails: (details) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Mudar status?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Não'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  details.data['status'] = e;
                                                });
                                              },
                                              child: Text('Sim'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  builder: (context, candidateData, rejectedData) => Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                          element['status'] ==
                                                          e,
                                                    )
                                                    .where(
                                                      (element) =>
                                                          element['id']
                                                              .toString()
                                                              .contains(
                                                                search.text,
                                                              ) ||
                                                          element['cliente']
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(
                                                                search.text
                                                                    .toLowerCase(),
                                                              ),
                                                    )
                                                    .toList()[index];
              
                                                return LongPressDraggable(
                                                  key: Key(
                                                    o['id'].toString(),
                                                  ),
                                                  data: o,
                                                  childWhenDragging:
                                                      Container(height: 200),
                                                  feedback: Material(
                                                    child: SizedBox(
                                                      width: 350,
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
                                                                  o['cliente']
                                                                      .toString(),
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
                                                                    MainAxisAlignment
                                                                        .end,
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
                                                    ),
                                                  ),
                                                  child: SizedBox(
                                                    height: 200,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              content: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius:
                                                                        40,
                                                                    backgroundImage:
                                                                        AssetImage(
                                                                          'assets/images/${o['cliente'].toString().split(' ').first.toLowerCase().replaceAll('í', "i")}.jpg',
                                                                        ),
                                                                  ),
                                                                  ListTile(
                                                                    contentPadding:
                                                                        EdgeInsets.all(
                                                                          0,
                                                                        ),
                                                                    title: Text(
                                                                      "#${o['id']}",
                                                                    ),
                                                                    subtitle: Text(
                                                                      o['cliente']
                                                                          .toString(),
                                                                    ),
                                                                    trailing: Chip(
                                                                      label: Text(
                                                                        "${o['status']}",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                    "R\$ ${o['valor']}",
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    'Ok!',
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Card(
                                                        child: Column(
                                                          children: [
                                                            Expanded(
                                                              child: ListTile(
                                                                title: Text(
                                                                  "#${o['id']}",
                                                                ),
                                                                subtitle: Text(
                                                                  o['cliente']
                                                                      .toString(),
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
                                                                    MainAxisAlignment
                                                                        .end,
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
                                                    ),
                                                  ),
                                                );
                                              },
                                              itemCount: orders
                                                  .where(
                                                    (element) =>
                                                        element['status'] ==
                                                        e,
                                                  )
                                                  .where(
                                                    (element) =>
                                                        element['id']
                                                            .toString()
                                                            .contains(
                                                              search.text,
                                                            ) ||
                                                        element['cliente']
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(
                                                              search.text
                                                                  .toLowerCase(),
                                                            ),
                                                  )
                                                  .toList()
                                                  .length,
                                            ),
                                          ),
                                        ],
                                      ),
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

List types = ["Todos", "Novo", "Pronto para retirada", "Em preparo"];

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
