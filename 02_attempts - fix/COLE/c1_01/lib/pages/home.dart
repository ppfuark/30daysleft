import 'package:c1_01/pages/game.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> me;
  final Function onTap;
  final Function onTap1;
  final Function onTap2;

  const Home({
    super.key,
    required this.me,
    required this.onTap,
    required this.onTap1,
    required this.onTap2,
  });
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  int indexC = 0;

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
            body: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) =>
                    IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
              ),
              title: Text("ColetaJá"),
              centerTitle: true,
              actions: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/FotoUsuario.jpg'),
                ),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 20,
                  children: [
                    ListTile(
                      title: Text(
                        "Olá ${widget.me['nome']}! Seu impacto ecológico este mês\n${widget.me['email']}",
                      ),
                      subtitle: Text("Total reciclado: 12.5kg"),
                      trailing: Chip(label: Text("Expert")),
                    ),
                    Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text("Próxima Coleta"),
                            subtitle: Text(
                              "Caminhão a 1.2km de você - Chegada em 15min",
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                widget.onTap2();
                              },
                              label: Text("Acompanhar no Mapa"),
                              icon: Icon(Icons.location_pin),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(title: Text("Acesso Rápido")),
                    SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 20,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 80,
                              child: GestureDetector(
                                child: Card(
                                  child: Center(
                                    child: Text("Novo Descarte / Check-in"),
                                  ),
                                ),
                                onTap: () {
                                  widget.onTap();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 80,
                              child: GestureDetector(
                                child: Card(
                                  child: Center(
                                    child: Text("Histórico & Relatórios"),
                                  ),
                                ),
                                onTap: () {
                                  widget.onTap1();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 80,
                              child: GestureDetector(
                                child: Card(
                                  child: Center(
                                    child: Text("Rota da Coleta (Mini Game)"),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Menu(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: PageView.builder(
                        onPageChanged: (value) {
                          setState(() {
                            indexC = value;
                          });
                        },
                        itemBuilder: (context, index) {
                          final data = [
                            {
                              "dica": "01",
                              "texto": "Dica de número 01",
                              "icon": Icon(Icons.recycling),
                            },
                            {
                              "dica": "02",
                              "texto": "Dica de número 02",
                              "icon": Icon(Icons.delete),
                            },
                            {
                              "dica": "03",
                              "texto": "Dica de número 03",
                              "icon": Icon(Icons.eco_outlined),
                            },
                          ][index];

                          return ListTile(
                            title: Text(data["texto"].toString()),
                            leading: data["icon"] as Widget,
                          );
                        },
                        itemCount: 3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...[0, 1, 2].map(
                          (e) => Icon(
                            Icons.circle,
                            color: e == indexC ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

final data = {
  "caminhao": {
    "id_frota": "CAM-01",
    "latitude": -22.9250,
    "longitude": -45.4610,
    "status": "em_rota",
    "ultima_atualizacao": "2026-08-27T11:40:00",
  },
  "pontos_coleta": [
    {
      "id": 1,
      "nome": "Ecoponto Centro",
      "latitude": -22.9225,
      "longitude": -45.4580,
      "nivel_lixo_porcentagem": 45,
      "aceita_novas_coletas": true,
      "avaliacao_cliente": 4.8,
      "capacidade_entulho_restante": "2.5 toneladas",
    },
    {
      "id": 2,
      "nome": "Ponto de Descarte Norte",
      "latitude": -22.9100,
      "longitude": -45.4500,
      "nivel_lixo_porcentagem": 100,
      "aceita_novas_coletas": false,
      "avaliacao_cliente": 4.2,
      "capacidade_entulho_restante": "0 toneladas",
    },
    {
      "id": 3,
      "nome": "Galpão de Reciclagem Sul",
      "latitude": -22.9350,
      "longitude": -45.4700,
      "nivel_lixo_porcentagem": 80,
      "aceita_novas_coletas": true,
      "avaliacao_cliente": 4.5,
      "capacidade_entulho_restante": "1.0 tonelada",
    },
    {
      "id": 4,
      "nome": "Caçamba Comunitária Leste",
      "latitude": -22.9200,
      "longitude": -45.4400,
      "nivel_lixo_porcentagem": 15,
      "aceita_novas_coletas": true,
      "avaliacao_cliente": 3.9,
      "capacidade_entulho_restante": "5.0 toneladas",
    },
    {
      "id": 5,
      "nome": "Ecoponto Distrito Industrial",
      "latitude": -22.9450,
      "longitude": -45.4850,
      "nivel_lixo_porcentagem": 100,
      "aceita_novas_coletas": false,
      "avaliacao_cliente": 4.9,
      "capacidade_entulho_restante": "0 toneladas",
    },
  ],
};
