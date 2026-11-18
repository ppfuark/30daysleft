import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/login.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Dash extends StatefulWidget {
  final Function onTap;

  const Dash({super.key, required this.onTap});
  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> with TickerProviderStateMixin {
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: Duration(milliseconds: 1000))
        ..forward()
        ..repeat(reverse: true);

  bool loading = true;
  bool error = false;
  String value = "mes";

  dynamic data = {};

  Future<void> startApp() async {
    try {
      setState(() {
        loading = true;
      });
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token') ?? "";

      final response = await http.get(
        Uri.parse('http://10.109.66.126:8080/api/v1/dashboard?periodo=$value'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          print(data['graficos']['rosca']);
          print(data['graficos']['barras']);
          print(data['graficos']['linha']);
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }

      await Future.delayed(Duration(seconds: 1));
      setState(() {
        loading = false;
        error = false;
      });
    } catch (e) {
      setState(() {
        error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startApp();
  }

  int touchedIndex = -1;
  int touchedIndex2 = -1;

  Widget skeleton(double h) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, c) {
        return Opacity(
          opacity: (animationController.value).clamp(0.2, 1.0),
          child: Container(
            height: h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                App.toogle();
              });
            },
            icon: Icon(
              App.valueNotifier.value == App.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          DropdownButton(
            value: value,
            items: [
              DropdownMenuItem(value: "semana", child: Text("Semana")),
              DropdownMenuItem(value: "mes", child: Text("Mês")),
              DropdownMenuItem(value: "trimestre", child: Text("Trimestre")),
            ],
            onChanged: (value) {
              setState(() {
                this.value = value!;
                startApp();
              });
            },
          ),
        ],
      ),
      body: error
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Não foi possível carregar os dados do dashboard"),
                  ElevatedButton(
                    onPressed: () {
                      startApp();
                    },
                    child: Text("Tentar novamente"),
                  ),
                ],
              ),
            )
          : Container(
              width: w,
              height: h,
              padding: EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10,
                  children: [
                    ListTile(
                      title: Text("KPIs"),
                      contentPadding: EdgeInsets.all(0),
                    ),
                    ...[0, 1, 2, 3].map(
                      (e) => loading
                          ? skeleton(100)
                          : Container(
                              decoration: BoxDecoration(border: Border.all()),
                              child: ListTile(
                                title: Text(
                                  [
                                    "Total Coletas",
                                    "Total Kg",
                                    "Colaboradores Ativos",
                                    "Cumprimento Rotas",
                                  ][e],
                                ),
                                subtitle: Text(
                                  data['kpis'].entries
                                      .elementAt(e)
                                      .value
                                      .toString(),
                                ),
                              ),
                            ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: loading
                          ? null
                          : BoxDecoration(border: Border.all()),
                      padding: EdgeInsets.all(20),
                      child: loading
                          ? skeleton(200)
                          : BarChart(
                              BarChartData(
                                barTouchData: BarTouchData(
                                  enabled: true,
                                  touchCallback: (p0, p1) {
                                    setState(() {
                                      touchedIndex2 =
                                          p1!.spot!.touchedBarGroupIndex;
                                    });
                                  },
                                ),
                                maxY: value == "trimestre"
                                    ? 120
                                    : value == "semana"
                                    ? 20
                                    : 50,
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 2,
                                      getTitlesWidget: (value, meta) => Text(
                                        data['graficos']['barras'][value
                                                .toInt()]['nome']
                                            .toString(),
                                      ),
                                    ),
                                  ),
                                  topTitles: AxisTitles(),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 10,
                                      reservedSize: 50,
                                    ),
                                  ),
                                  rightTitles: AxisTitles(),
                                ),
                                barGroups: [
                                  ...data['graficos']['barras'].map(
                                    (e) => BarChartGroupData(
                                      x: data['graficos']['barras'].indexOf(e),
                                      barRods: [
                                        BarChartRodData(
                                          width:
                                              touchedIndex2 ==
                                                  data['graficos']['barras']
                                                      .indexOf(e)
                                              ? 65
                                              : 50,
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                          toY: double.parse(
                                            (double.parse(
                                                      e['total'].toString(),
                                                    ) *
                                                    (touchedIndex2 ==
                                                            data['graficos']['barras']
                                                                .indexOf(e)
                                                        ? 1.1
                                                        : 1.0))
                                                .toStringAsFixed(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: loading
                          ? null
                          : BoxDecoration(border: Border.all()),
                      padding: EdgeInsets.all(20),
                      child: loading
                          ? skeleton(200)
                          : LineChart(
                              LineChartData(
                                maxY: value == "trimestre"
                                    ? 2500
                                    : value == "semana"
                                    ? 260
                                    : 1500,
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      reservedSize: 50,
                                      getTitlesWidget: (value, meta) => Text(
                                        data['graficos']['linha'][value
                                                .toInt()]['semana']
                                            .toString(),
                                      ),
                                    ),
                                  ),
                                  topTitles: AxisTitles(),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: value == "trimestre"
                                          ? 150
                                          : 100,
                                      reservedSize: 50,
                                    ),
                                  ),
                                  rightTitles: AxisTitles(),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      ...data['graficos']['linha'].map(
                                        (e) => FlSpot(
                                          data['graficos']['linha']
                                              .indexOf(e)
                                              .toDouble(),
                                          e['kg'].toDouble(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: loading
                          ? null
                          : BoxDecoration(border: Border.all()),
                      padding: EdgeInsets.all(20),
                      child: loading
                          ? skeleton(200)
                          : PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  enabled: true,
                                  touchCallback: (p0, p1) {
                                    print(
                                      p1!.touchedSection!.touchedSectionIndex,
                                    );
                                    setState(() {
                                      touchedIndex = p1
                                          .touchedSection!
                                          .touchedSectionIndex;
                                    });
                                  },
                                ),

                                centerSpaceRadius: 40,

                                sections: [
                                  ...data['graficos']['rosca'].map(
                                    (e) => PieChartSectionData(
                                      value: (e['total'].toDouble()),
                                      showTitle: true,
                                      title: '${e['percentual']}%',
                                      radius:
                                          touchedIndex ==
                                              data['graficos']['rosca'].indexOf(
                                                e,
                                              )
                                          ? 65
                                          : 50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

final s = {
  "periodo": "mes",
  "kpis": {
    "totalColetas": 112,
    "totalKg": 5320,
    "colaboradoresAtivos": 4,
    "cumprimentoRotas": 92,
  },
  "graficos": {
    "rosca": [
      {"tipo": "Orgânico", "percentual": 33, "total": 48},
      {"tipo": "Papel", "percentual": 24, "total": 35},
      {"tipo": "Plástico", "percentual": 19, "total": 27},
      {"tipo": "Metal", "percentual": 15, "total": 21},
      {"tipo": "Vidro", "percentual": 9, "total": 13},
    ],
    "barras": [
      {"nome": "Carlos Eduardo", "total": 36},
      {"nome": "Mariana Costa", "total": 32},
      {"nome": "Patricia Vieira", "total": 28},
      {"nome": "João Pedro", "total": 16},
    ],
    "linha": [
      {"semana": "Sem 1", "kg": 1200},
      {"semana": "Sem 2", "kg": 1380},
      {"semana": "Sem 3", "kg": 1310},
      {"semana": "Sem 4", "kg": 1430},
    ],
  },
};
