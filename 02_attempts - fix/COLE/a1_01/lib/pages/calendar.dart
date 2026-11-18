import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});
  @override
  State<Calendar> createState() => _CalendarState();
}

class Day {
  final DateTime date;
  final bool haveSome;

  Day({required this.date, required this.haveSome});
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
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

  DateTime currentDate = DateTime.now();

  List<Day?> get month {
    final first = DateTime(currentDate.year, currentDate.month, 1);
    final last = DateTime(currentDate.year, currentDate.month + 1, 0);

    final nulls = first.weekday % 7;

    List<Day?> temp = List.filled(nulls, null, growable: true);

    for (var i = 0; i < last.day; i++) {
      temp.add(
        Day(
          date: DateTime(currentDate.year, currentDate.month, i),
          haveSome: coles
              .where(
                (element) =>
                    element['data'].toString() == i.toString() &&
                    monthsb.elementAt(currentDate.month - 1) ==
                        element['mes'].toString(),
              )
              .isNotEmpty,
        ),
      );
    }

    return temp;
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
    final m = month;

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
              padding: EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    ListTile(
                      title: Text("Calendário de Coleta"),
                      subtitle: Text("Planeje sua Reciclagem"),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      height: w + 20,
                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentDate = currentDate.subtract(
                                      Duration(days: 30),
                                    );
                                  });
                                },
                                icon: Icon(Icons.arrow_back_ios),
                              ),
                              Text(months[currentDate.month - 1].toString()),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    currentDate = currentDate.add(
                                      Duration(days: 30),
                                    );
                                  });
                                },
                                icon: Icon(Icons.arrow_forward_ios),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [...week.map((e) => Text(e))],
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 0.9,
                                ),
                            itemBuilder: (context, index) {
                              final m = month[index];

                              return m == null
                                  ? SizedBox.shrink()
                                  : Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            border:
                                                m.date.day == currentDate.day
                                                ? Border.all()
                                                : null,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              spacing: 2,
                                              children: [
                                                Text(m.date.day.toString()),
                                                if (m.haveSome)
                                                  Icon(Icons.circle),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (m.date.day == currentDate.day)
                                          Positioned(
                                            top: -10,
                                            right: -10,
                                            child: Icon(Icons.circle),
                                          ),
                                      ],
                                    );
                            },
                            itemCount: month.length,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,

                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text("Próximas Coletas"),
                          ),
                          ListView.builder(
                            itemBuilder: (context, index) {
                              final cols = coles
                                  .where(
                                    (element) =>
                                        currentDate
                                            .difference(
                                              DateTime(
                                                2026,
                                                months.indexOf(
                                                  element['mes'].toString(),
                                                ),
                                                int.parse(
                                                  element['data'].toString(),
                                                ),
                                              ),
                                            )
                                            .inDays >
                                        0,
                                  )
                                  .toList();

                              final c = cols[index];

                              final color = switch (c['cor']) {
                                "Verde" => Colors.green,
                                "Marrom" => Colors.brown,
                                "Amarelo" => Colors.yellow,
                                "Azul" => Colors.blue,
                                _ => Colors.red,
                              };

                              return ListTile(
                                leading: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                  ),
                                  width: 50,
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 5,
                                    children: [
                                      Text(
                                        c['data'].toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        c['mes'].toString(),
                                        style: TextStyle(),
                                      ),
                                    ],
                                  ),
                                ),

                                title: Text(c['tipo'].toString()),
                                subtitle: Text("Dia de coleta"),
                                trailing: Icon(Icons.circle, color: color),
                              );
                            },
                            itemCount: 3,
                            shrinkWrap: true,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,

                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text("Legenda"),
                          ),

                          ...[
                            {"texto": "Plástico/Metal", "cor": Colors.red},
                            {"texto": "Papel", "cor": Colors.blue},
                            {"texto": "Vidro", "cor": Colors.green},
                            {"texto": "Orgânico", "cor": Colors.brown},
                          ].map(
                            (e) => ListTile(
                              title: Text(e['texto'].toString()),
                              trailing: Icon(
                                Icons.circle,
                                color: e['cor'] as Color,
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
          );
  }
}

final coles = [
  {
    "data": "19",
    "mes": "MAI",
    "titulo": "Dia de coleta",
    "tipo": "Vidro",
    "cor": "Verde",
  },
  {
    "data": "26",
    "mes": "MAI",
    "titulo": "Dia de coleta",
    "tipo": "Orgânico",
    "cor": "Marrom",
  },
  {
    "data": "04",
    "mes": "JUN",
    "titulo": "Dia de coleta",
    "tipo": "Plástico",
    "cor": "Vermelho",
  },
  {
    "data": "06",
    "mes": "JUN",
    "titulo": "Dia de coleta",
    "tipo": "Metal",
    "cor": "Amarelo",
  },
  {
    "data": "12",
    "mes": "JUN",
    "titulo": "Dia de coleta",
    "tipo": "Papel",
    "cor": "Azul",
  },
  {
    "data": "17",
    "mes": "JUN",
    "titulo": "Dia de coleta",
    "tipo": "Vidro",
    "cor": "Verde",
  },
  {
    "data": "24",
    "mes": "JUN",
    "titulo": "Dia de coleta",
    "tipo": "Orgânico",
    "cor": "Marrom",
  },
  {
    "data": "01",
    "mes": "JUL",
    "titulo": "Dia de coleta",
    "tipo": "Plástico",
    "cor": "Vermelho",
  },
  {
    "data": "08",
    "mes": "JUL",
    "titulo": "Dia de coleta",
    "tipo": "Metal",
    "cor": "Amarelo",
  },
  {
    "data": "15",
    "mes": "JUL",
    "titulo": "Dia de coleta",
    "tipo": "Papel",
    "cor": "Azul",
  },
];

final List<String> monthsb = [
  'JAN',
  'FEV',
  'MAR',
  'ABR',
  'MAI',
  'JUN',
  'JUL',
  'AGO',
  'SET',
  'OUT',
  'NOV',
  'DEZ',
];
final months = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

final week = ["SEG", "TER", "QUA", "QUI", "SEX", "SAB", "DOM"];
