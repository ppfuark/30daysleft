import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final AnimationController animationController1 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  );
  late final AnimationController animationController2 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 3),
  );
  late final AnimationController animationController3 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  );
  late final AnimationController animationController4 = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  );

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://192.168.56.1:8080/api/v1/coletas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    await animationController1.forward();
    await animationController2.forward();
    await animationController3.forward();
    await animationController4.forward();
    await Future.delayed(Duration(seconds: 2));

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Coletas()),
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
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
      body: AnimatedBuilder(
        animation: animationController3,
        builder: (context, child) {
          return Container(
            color: ColorTween(
              begin: Colors.white,
              end: Color(0xFF0d3321),
            ).animate(animationController3).value,
            width: w,
            height: h,
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                AnimatedBuilder(
                  animation: animationController2,
                  builder: (context, c) {
                    final p = TweenSequence<Offset>([
                      TweenSequenceItem(
                        tween: Tween(begin: Offset(0, 0), end: Offset(0, -.2)),
                        weight: 1,
                      ),
                      TweenSequenceItem(
                        tween: Tween(
                          begin: Offset(0, -.2),
                          end: Offset(-.2, -.2),
                        ),
                        weight: 1,
                      ),
                      TweenSequenceItem(
                        tween: Tween(
                          begin: Offset(-.2, -.2),
                          end: Offset(0.2, -.2),
                        ),
                        weight: 1,
                      ),

                      TweenSequenceItem(
                        tween: Tween(
                          begin: Offset(0.2, -.2),
                          end: Offset(0.2, 0),
                        ),
                        weight: 1,
                      ),
                      TweenSequenceItem(
                        tween: Tween(begin: Offset(0.2, 0), end: Offset(0, 0)),
                        weight: 1,
                      ),
                    ]).animate(animationController2).value;

                    return Transform.translate(
                      offset: Offset(p.dx * w, p.dy * h),
                      child: Image.asset('assets/ic_launcher.png'),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: animationController4,
                  builder: (context, child) {
                    return Opacity(
                      opacity: Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).animate(animationController4).value,
                      child: Column(
                        children: [
                          Text(
                            "Coleta Já",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                          CircularProgressIndicator(),
                        ],
                      ),
                    );
                  },
                ),

                AnimatedBuilder(
                  animation: animationController1,
                  builder: (context, c) {
                    return Opacity(
                      opacity: Tween<double>(
                        begin: 1.0,
                        end: 0.0,
                      ).animate(animationController1).value,
                      child: Text("Preparando"),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Coletas extends StatefulWidget {
  const Coletas({super.key});
  @override
  State<Coletas> createState() => _ColetasState();
}

class _ColetasState extends State<Coletas> with TickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: Duration(seconds: 1),
  )..repeat(reverse: true);

  dynamic data = {};

  String period = "semana";
  bool loading = true;
  bool error = false;
  int touchedPie = -1;
  int touchedBar = -1;

  final pieColors = [
    Colors.amber,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.orange,
  ];

  Future<void> startApp() async {
    setState(() {
      loading = true;
      error = false;
    });
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token') ?? "";

      final response = await http.get(
        Uri.parse('http://192.168.56.1:8080/api/v1/dashboard?periodo=$period'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await Future.delayed(Duration(seconds: 2));

      if (response.statusCode == 200) {
        setState(() {
          data = jsonDecode(response.body);
          print(data);
        });
      }
    } catch (e) {
      setState(() {
        error = true;
      });
    }

    setState(() {
      loading = false;
    });
  }

  Widget skeleton(double height) => FadeTransition(
    opacity: pulse,
    child: Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final List pie = data['graficos']?['rosca'] ?? [];
    final List lines = data['graficos']?['linha'] ?? [];
    final List bars = data['graficos']?['barras'] ?? [];
    final int totalBars = bars.fold(0, (p, e) => p + (e['total'] as int));

    return Scaffold(
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: error
            ? Center(
                child: Column(
                  children: [
                    Text("Não foi possível carregar os dados do dashboard"),
                    ElevatedButton.icon(
                      onPressed: () {
                        startApp();
                      },
                      label: Text("Tentar Novamente"),
                      icon: Icon(Icons.replay),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    DropdownButton(
                      items: [
                        DropdownMenuItem(
                          value: "semana",
                          child: Text("Semana"),
                        ),
                        DropdownMenuItem(value: "mes", child: Text("Mês")),
                        DropdownMenuItem(
                          value: "trimestre",
                          child: Text("Trimestre"),
                        ),
                      ],
                      value: period,
                      onChanged: (value) {
                        setState(() {
                          period = value!;
                          startApp();
                        });
                      },
                    ),
                    Wrap(
                      spacing: 10,
                      children: [
                        for (final kpi in [
                          ["Coletas", "totalColetas", ""],
                          ["Resíduos (kg)", "totalKg", ""],
                          ["Colaboradores ativos", "colaboradoresAtivos", ""],
                          ["Rotas cumpridas", "cumprimentoRotas", "%"],
                        ])
                          SizedBox(
                            width: w * .15,
                            child: loading
                                ? skeleton(80)
                                : Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(kpi[0]),
                                          Text(
                                            "${data['kpis'][kpi[1]]}${kpi[2]}",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                    SizedBox(
                      width: 800,
                      height: 200,
                      child: loading
                          ? skeleton(200)
                          : PieChart(
                              PieChartData(
                                centerSpaceRadius: 40,
                                sections: [
                                  for (int i = 0; i < pie.length; i++)
                                    PieChartSectionData(
                                      color: pieColors[i % 5],
                                      value: double.parse(
                                        pie[i]['percentual'].toString(),
                                      ),
                                      radius: touchedPie == i ? 70 : 60,
                                      title: touchedPie == i
                                          ? "${pie[i]['tipo']}\n${pie[i]['total']} (${pie[i]['percentual']}%)"
                                          : null,
                                    ),
                                ],
                                pieTouchData: PieTouchData(
                                  touchCallback: (p0, p1) {
                                    setState(() {
                                      touchedPie =
                                          p1
                                              ?.touchedSection
                                              ?.touchedSectionIndex ??
                                          -1;
                                    });
                                  },
                                ),
                              ),
                            ),
                    ),
                    if (!loading)
                      Wrap(
                        spacing: 12,
                        children: [
                          for (var i = 0; i < pie.length; i++)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: pieColors[i % 5],
                                ),
                                const SizedBox(width: 4),
                                Text(pie[i]['tipo'].toString()),
                              ],
                            ),
                        ],
                      ),
                    SizedBox(
                      height: 200,
                      width: 800,
                      child: loading
                          ? skeleton(200)
                          : BarChart(
                              BarChartData(
                                barGroups: [
                                  for (int i = 0; i < bars.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      showingTooltipIndicators: touchedBar == i
                                          ? [0]
                                          : [],
                                      barRods: [
                                        BarChartRodData(
                                          toY: double.parse(
                                            bars[i]['total'].toString(),
                                          ),
                                          color: Colors.green,
                                          width: 50,
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                                barTouchData: BarTouchData(
                                  touchCallback: (p0, p1) {
                                    setState(() {
                                      touchedBar =
                                          p1?.spot?.touchedBarGroupIndex ?? -1;
                                    });
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      interval: period == "semana"
                                          ? 3
                                          : period == "mes"
                                          ? 10
                                          : 20,
                                      showTitles: true,
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) => Text(
                                        bars[value.toInt()]['nome'].toString(),
                                      ),
                                    ),
                                  ),
                                  topTitles: AxisTitles(),
                                  rightTitles: AxisTitles(),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 200,
                      width: 800,
                      child: loading
                          ? skeleton(200)
                          : LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    isCurved: true,
                                    color: Colors.green,
                                    barWidth: 3,
                                    spots: [
                                      for (int i = 0; i < lines.length; i++)
                                        FlSpot(
                                          i.toDouble(),
                                          double.parse(
                                            lines[i]['kg'].toString(),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(),
                                  rightTitles: AxisTitles(),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 60,
                                      interval: period == "semana"
                                          ? 10
                                          : period == "mes"
                                          ? 30
                                          : 100,
                                    ),
                                  ),
                                ),
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

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final pass = TextEditingController();

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
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            TextField(controller: email),
            TextField(controller: pass),
            ElevatedButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://192.168.56.1:8080/api/v1/auth/login'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'email': email.text,
                    'password': pass.text,
                  }),
                );

                if (response.statusCode == 200) {
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  await sharedPreferences.setString(
                    'token',
                    jsonDecode(response.body)['token'],
                  );
                  print('boa');
                } else {
                  print(response.body);
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
