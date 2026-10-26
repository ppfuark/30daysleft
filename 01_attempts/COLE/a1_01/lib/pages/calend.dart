import 'package:flutter/material.dart';

class Calend extends StatefulWidget {
  const Calend({super.key});
  @override
  State<Calend> createState() => _CalendState();
}

class Day {
  String day;
  Color? color;

  Day({required this.color, required this.day});
}

class _CalendState extends State<Calend> {
  DateTime currentMonth = DateTime.now();

  List<Day?> getCurrent() {
    final List<Day?> list = [];

    for (var i = 0; i < currentMonth.weekday % 7; i++) {
      list.add(null);
    }

    final last = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    print(last);

    for (var i = 1; i < last; i++) {
      final exist = data.where(
        (element) =>
            element['data'].toString() == i.toString().padLeft(2, '0') &&
            monthsB[currentMonth.month - 1].toUpperCase() == element['mes'],
      );
      list.add(
        Day(
          color: exist.isEmpty
              ? null
              : switch (exist.first['tipo'].toString()) {
                  "Orgânico" => Colors.brown,
                  "Vidro" => Colors.green,
                  "Papel" => Colors.blue,
                  _ => Colors.red,
                },
          day: i.toString(),
        ),
      );
    }

    return list;
  }

  Future<void> startApp() async {}

  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final days = getCurrent();

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            spacing: 30,

            children: [
              Container(
                width: w,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currentMonth = currentMonth.subtract(
                                Duration(days: 30),
                              );
                            });
                          },
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                        Text(
                          "${months[currentMonth.month - 1]} ${currentMonth.year}",
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currentMonth = currentMonth.add(
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
                      children: [...weekDay.map((e) => Text(e))],
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final d = days[index];

                        return d == null
                            ? SizedBox.shrink()
                            : Stack(
                                alignment: AlignmentGeometry.centerStart,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border:
                                          d.day.toString() ==
                                              DateTime.now().day.toString()
                                          ? Border.all(color: Colors.black)
                                          : null,
                                    ),
                                    child: Column(
                                      spacing: 5,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(d.day.toString()),
                                        if (d.color != null)
                                          Icon(
                                            Icons.circle,
                                            size: 10,
                                            color: d.color,
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (d.day.toString() ==
                                      DateTime.now().day.toString())
                                    Positioned(
                                      top: -10,
                                      right: -10,

                                      child: Icon(Icons.circle),
                                    ),
                                ],
                              );
                      },
                      itemCount: days.length,
                    ),
                  ],
                ),
              ),
              Container(
                width: w,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(Icons.delete),
                      title: Text("Próximas coletas"),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final c = switch (data[index]['tipo'].toString()) {
                          "Orgânico" => Colors.brown,
                          "Vidro" => Colors.green,
                          "Papel" => Colors.blue,
                          _ => Colors.red,
                        };

                        return ListTile(
                          contentPadding: EdgeInsets.all(0),
                          trailing: Icon(Icons.circle, color: c),
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(data[index]['data'].toString()),
                              Text(data[index]['mes'].toString()),
                            ],
                          ),
                          title: Text(data[index]['tipo'].toString()),
                          subtitle: Text(data[index]['titulo'].toString()),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: data.length,
                    ),
                  ],
                ),
              ),
              Container(
                width: w,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: Icon(Icons.text_fields_sharp),
                      title: Text("Legenda"),
                    ),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final c = switch ([
                          "Plástico/Metal",
                          'Orgânico',
                          "Vidro",
                          "Papel",
                        ][index]) {
                          "Orgânico" => Colors.brown,
                          "Vidro" => Colors.green,
                          "Papel" => Colors.blue,
                          _ => Colors.red,
                        };

                        return ListTile(
                          contentPadding: EdgeInsets.all(0),
                          trailing: Icon(Icons.circle, color: c),

                          title: Text(
                            [
                              "Plástico/Metal",
                              'Orgânico',
                              "Vidro",
                              "Papel",
                            ][index],
                          ),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: 4,
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

List<String> months = [
  "Janeiro",
  "Fevereiro",
  "Março",
  "Abril",
  "Maio",
  "Junho",
  "Julho",
  "Agosto",
  "Setembro",
  "Outubro",
  "Novembro",
  "Dezembro",
];
List<String> monthsB = [
  "Jan",
  "Fev",
  "Mar",
  "Abr",
  "Mai",
  "Jun",
  "Jul",
  "Ago",
  "Set",
  "Out",
  "Nov",
  "Dez",
];
List<String> weekDay = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sab", "Dom"];

final data = [
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
