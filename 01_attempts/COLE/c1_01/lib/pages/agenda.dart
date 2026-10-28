import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class Agenda extends StatefulWidget {
  final Map<String, dynamic> me;

  const Agenda({super.key, required this.me});

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  List coletas = [];

  Future<void> startApp() async {
    final raw = await rootBundle.loadString('assets/historico_coletas.xml');

    final xml = XmlDocument.parse(raw);

    for (var element in xml.findAllElements('coleta')) {
      coletas.add({
        'id': element.findAllElements('id').first.innerText,
        'data': element.findAllElements('data').first.innerText,
        'quantidade_toneladas': element
            .findAllElements('quantidade_toneladas')
            .first
            .innerText,
        'tipo_residuo': element.findAllElements('tipo_residuo').first.innerText,
        'ponto_coleta': element.findAllElements('ponto_coleta').first.innerText,
        'avaliacao': element.findAllElements('avaliacao').first.innerText,
      });
    }

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
        title: Text(
          "Relatório de Coleta",
          style: TextStyle(color: Colors.green),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            SizedBox(
              height: 90,

              child: Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () async {},
                        title: Text("Total Coletado (Mês)"),
                        subtitle: Row(
                          spacing: 5,
                          children: [
                            Text(
                              "12.4",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            Text("Ton"),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () async {},
                        title: Text("Coletas Realizadas"),
                        subtitle: Row(
                          spacing: 5,
                          children: [
                            Text(
                              "8",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),

                            Text("viagens"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Histórico de Coletas"),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final c = coletas[index];

                  return Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),

                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${c['data'].toString().split("T").first.split("-")[2]} de ${months[int.parse(c['data'].toString().split("T").first.split("-")[1])]}, ${c['data'].toString().split("T").first.split("-")[0]}",
                            ),
                            Chip(
                              label: Text(
                                double.parse(
                                          c['quantidade_toneladas'].toString(),
                                        ) >
                                        8
                                    ? "Coleta Premium"
                                    : "Concluída",
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Text(c['ponto_coleta'].toString()),
                          subtitle: Text("${c['quantidade_toneladas']} Ton"),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                coletas.remove(c);
                              });
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: coletas.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<String> months = [
  "Jan",
  "Fev",
  "Mar",
  "Abr",
  "Maio",
  "Jun",
  "Jul",
  "Ago",
  "Set",
  "Out",
  "Nov",
  "Dez",
];
