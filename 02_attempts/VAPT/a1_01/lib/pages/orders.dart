import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List recents = [];

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
              title: Text("Acompanhamento de Pedido"),
              actions: [
                CircleAvatar(backgroundImage: AssetImage('assets/avatar.png')),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.circle, color: Colors.red),
                    title: Text("Restreamento ao Vivo"),
                  ),
                  ListTile(
                    title: Text("Chegada em..."),
                    subtitle: Text("12 - 18 min"),
                  ),
                  ListTile(
                    title: Text("Entregador"),
                    subtitle: Text("Carlos Alberto"),
                    trailing: Icon(Icons.contact_emergency),
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(color: Colors.black),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      child: ListTile(
                        leading: Icon(Icons.phone, color: Colors.white),
                        title: Text(
                          "Pressione e segure para ligar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      "Resumo do Pedido #8821",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Total"),
                            trailing: Text("R\$ 28,70"),
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
