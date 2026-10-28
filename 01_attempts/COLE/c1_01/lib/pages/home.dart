import 'package:c1_01/pages/check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> me;
  final Function onTap1;
  final Function onTap2;
  final Function onTap3;

  const Home({
    super.key,
    required this.me,
    required this.onTap1,
    required this.onTap2,
    required this.onTap3,
  });
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        leading: Icon(Icons.menu),
        title: Text("Coleta Já", style: TextStyle(color: Colors.green)),
        centerTitle: true,
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/icons/FotoUsuario.jpg'),
          ),
          Icon(Icons.notifications),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          spacing: 10,
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(0),
              trailing: Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [Icon(Icons.diamond), Text("Nível Esmeralda")],
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(
                "Olá, ${widget.me['nome'].toString()}! Seu impacto ecológico este mês",
              ),

              subtitle: Text("Total reciclado: 12.5kg"),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text("PROXIMIDADE ATUAL"),
                    subtitle: Text("A 1.2km de você"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.watch_later), Text("15 min")],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.onTap1();
                      },
                      label: Text("Acompanhar no Mapa"),
                      icon: Icon(Icons.location_pin),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,

              child: ListTile(
                title: Text("Acesso Rápido"),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 80,
                        width: 200,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Check()),
                            );
                          },
                          title: Text(
                            "Novo Descarte",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Check-in",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 80,
                        width: 200,
                        child: ListTile(
                          onTap: () {
                            widget.onTap2();
                          },
                          title: Text(
                            "Histórico",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Relatórios",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(Icons.bar_chart, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 80,
                        width: 200,
                        child: ListTile(
                          onTap: () {
                            widget.onTap3();
                          },
                          title: Text(
                            "Mini Game",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Rota da Coleta",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(
                            CupertinoIcons.game_controller_solid,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              width: double.infinity,

              child: ListTile(
                title: Text("Dicas de Sustentabilidade"),
                subtitle: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 80,
                        width: 200,
                        child: ListTile(
                          onTap: () {
                            widget.onTap1();
                          },
                          title: Text(
                            "PET",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Reciclável",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(Icons.recycling, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 80,
                        width: 200,
                        child: ListTile(
                          onTap: () {
                            widget.onTap1();
                          },
                          title: Text(
                            "Metal",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Reciclável",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(Icons.recycling, color: Colors.white),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 80,
                        width: 200,
                        child: ListTile(
                          onTap: () {
                            widget.onTap1();
                          },
                          title: Text(
                            "Orgânicos",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "Não reciclável",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: Icon(Icons.eco, color: Colors.white),
                        ),
                      ),
                    ],
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
