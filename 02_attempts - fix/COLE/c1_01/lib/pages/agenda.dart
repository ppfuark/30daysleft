import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class Agenda extends StatefulWidget {
  const Agenda({super.key});
  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List coletas = [];

  Future<void> startApp() async {
    try {
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
          'tipo_residuo': element
              .findAllElements('tipo_residuo')
              .first
              .innerText,
          'ponto_coleta': element
              .findAllElements('ponto_coleta')
              .first
              .innerText,
          'avaliacao': element.findAllElements('avaliacao').first.innerText,
        });
      }

      setState(() {
        coletas.sort(
          (a, b) => DateTime.parse(
            b['data'].toString(),
          ).compareTo(DateTime.parse(a['data'].toString())),
        );
      });
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
            body: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
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
                            border: Border(
                              left: BorderSide(
                                width: 3,
                                color:
                                    double.parse(
                                          c['quantidade_toneladas'].toString(),
                                        ) >
                                        8
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                          ),

                          width: double.infinity,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${c['data'].toString().split("T").first.split("-")[2]} de ${months[int.parse(c['data'].toString().split("T").first.split("-")[1])]}, ${c['data'].toString().split("T").first.split("-")[0]}",
                                  ),
                                  Chip(
                                    backgroundColor:
                                        double.parse(
                                              c['quantidade_toneladas']
                                                  .toString(),
                                            ) >
                                            8
                                        ? Colors.orange
                                        : null,

                                    label: Row(
                                      children: [
                                        Text(
                                          double.parse(
                                                    c['quantidade_toneladas']
                                                        .toString(),
                                                  ) >
                                                  8
                                              ? "Coleta Premium"
                                              : "Concluída",
                                        ),
                                        if (double.parse(
                                              c['quantidade_toneladas']
                                                  .toString(),
                                            ) <
                                            8)
                                          Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: Text(
                                  c['ponto_coleta'].toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  spacing: 20,
                                  children: [
                                    Text("${c['quantidade_toneladas']} Ton"),
                                    Chip(
                                      label: Text(
                                        "Papelão",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed:
                                      DateTime.parse(c['data'].toString()) ==
                                          DateTime.now()
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Deseja realmente excluir?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        coletas.remove(c);
                                                      });
                                                    },
                                                    child: Text('Ok!'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      : null,
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
