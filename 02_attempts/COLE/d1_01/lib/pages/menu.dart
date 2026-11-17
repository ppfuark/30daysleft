import 'package:d1_01/pages/comum.dart';
import 'package:d1_01/pages/seletiva.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class Menu extends StatefulWidget {
  final Map<String, dynamic> me;

  const Menu({super.key, required this.me});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _controller1;
  bool loading = true;

  List coletas = [];

  Future<void> startApp() async {
    try {
      //     <coleta id="COL-0001" usuario_id="1">
      //   <data_hora>2026-10-01T08:00:00-03:00</data_hora>
      //   <ponto_coleta_id>34</ponto_coleta_id>
      //   <material>Plástico</material>
      //   <estado_item>Limpo/Seco</estado_item>
      //   <peso_kg>0.100</peso_kg>
      //   <pontos_gerados>10</pontos_gerados>
      // </coleta>
      final raw = await rootBundle.loadString('assets/coletas.xml');
      final xml = XmlDocument.parse(raw);
      List data = [];
      for (var element in xml.findAllElements('coleta')) {
        setState(() {
          data.add({
            'id': element.getAttribute('id'),
            'usuario_id': element.getAttribute('usuario_id'),
            'data_hora': element.findAllElements('data_hora').first.innerText,
            'ponto_coleta_id': element
                .findAllElements('ponto_coleta_id')
                .first
                .innerText,
            'material': element.findAllElements('material').first.innerText,
            'estado_item': element
                .findAllElements('estado_item')
                .first
                .innerText,
            'peso_kg': element.findAllElements('peso_kg').first.innerText,
            'pontos_gerados': element
                .findAllElements('pontos_gerados')
                .first
                .innerText,
          });
        });
      }

      setState(() {
        coletas = data;
        coletas.sort(
          (a, b) =>
              a['data_hora'].toString().compareTo(b['data_hora'].toString()),
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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
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
    return loading || coletas.isEmpty
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
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Image.asset('assets/ic_launcher.png'),
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.3).animate(_controller),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: () async {
                        await _controller.forward();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Comum()),
                        );
                      },
                      icon: Icon(Icons.local_shipping, color: Colors.white),
                      label: Text(
                        "Coleta Comum",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.3).animate(_controller1),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        await _controller1.forward();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Seletiva(me: widget.me),
                          ),
                        );
                      },
                      icon: Icon(Icons.recycling, color: Colors.white),
                      label: Text(
                        "Coleta Seletiva",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Última atualização: ${coletas.last['data_hora'].toString().split('T').first.replaceAll('-', '/')}",
                  ),
                ],
              ),
            ),
          );
  }
}
