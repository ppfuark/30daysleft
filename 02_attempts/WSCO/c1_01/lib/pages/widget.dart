import 'package:flutter/material.dart';

class WidgetE extends StatefulWidget {
  final Function onTap;
  final Map<String, dynamic> me;

  const WidgetE({super.key, required this.me, required this.onTap});
  @override
  State<WidgetE> createState() => _WidgetEState();
}

class _WidgetEState extends State<WidgetE> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  double hours = 0.0;
  double last = 0.0;
  double average = 0.0;

  Future<void> startApp() async {
    try {
      final List avalsL = widget.me['ultimas_avaliacoes'] ?? [];
      final List works = widget.me['treinamento'] ?? [];

      last = (avalsL.isNotEmpty ? avalsL.last['nota'] : 0).toDouble();

      hours = works.fold(0, (previousValue, element) {
        final hours =
            int.parse(element['saida'].toString().split(':').first) -
            int.parse(element['entrada'].toString().split(':').first);
        final mins =
            int.parse(element['saida'].toString().split(':').last) -
            int.parse(element['entrada'].toString().split(':').last);

        return previousValue + (hours * 60) + (mins ~/ 60);
      });

      average = avalsL.isEmpty
          ? 0.0
          : (avalsL.fold(
                  0,
                  (previousValue, element) =>
                      previousValue + element['nota'] as int,
                )) /
                avalsL.length;

      print((
        avalsL.fold(
          0,
          (previousValue, element) => previousValue + (element['nota'] as int),
        ),
      ));

      print(avalsL.length);

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => startApp());
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
                "Home Widget - ${DateTime.now().month}/${DateTime.now().day}",
              ),
              automaticallyImplyLeading: false,
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.onTap();
                      });
                    },
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(title: Text("WSConecta - Widget")),
                          ListTile(
                            title: Text(widget.me['nome'].toString()),
                            subtitle: Text(widget.me['escola'].toString()),
                          ),
                          Divider(),
                          Card(
                            child: ListTile(
                              tileColor: hours < 8 ? Colors.red : null,
                              leading: Icon(Icons.watch_later),
                              title: Text("Horas/Mês"),
                              subtitle: Text(hours.toStringAsFixed(0)),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(Icons.book),
                              title: Text("Última nota"),
                              subtitle: Text(last.toString()),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              tileColor: average >= 60 ? Colors.green : null,
                              leading: Icon(Icons.book),
                              title: Text("Média geral"),
                              subtitle: Text(average.toStringAsFixed(0)),
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
