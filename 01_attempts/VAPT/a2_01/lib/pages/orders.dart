import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
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
            "Acompanhemento de Pedidos",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          subtitle: Text(
            "Segure e arraste os itens para move-los entre as colunas.",
          ),
        ),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Row(
          spacing: 20,
          children: [
            ...["Novos Pedidos", "Em preparo", "Pronto para retirada"].map(
              (e) => Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e == "Pronto para retirada"
                              ? "Prontos para a retirada"
                              : e,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              final f = orders
                                  .where((element) => element['status'] == e)
                                  .toList()[index];

                              return Card(
                                child: ListTile(
                                  title: Text("#${f['id']}"),
                                  subtitle: Text(f['cliente'].toString()),
                                  trailing: Text("R\$ ${f['valor']}"),
                                ),
                              );
                            },
                            itemCount: orders
                                .where((element) => element['status'] == e)
                                .length,
                            shrinkWrap: true,
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
