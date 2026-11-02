import 'package:c1_01/pages/chat.dart';
import 'package:c1_01/pages/home.dart';
import 'package:c1_01/pages/orders.dart';
import 'package:c1_01/pages/profile.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  Future<void> startApp() async {}
  @override
  void initState() {
    super.initState();
    startApp();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Home(),
      Orders(orders: orders),
      Chat(messages: messages),
      Profile(),
    ];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Pedidos"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Conversa"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },

        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.orange,
      ),
      body: SizedBox(width: w, height: h, child: pages[index]),
    );
  }
}

List messages = [
  {"time": "10:42", "content": "Olá", "chef": true, "text": true},
  {
    "time": "10:43",
    "content": "Como foi o pedido?",
    "chef": true,
    "text": true,
  },
  {
    "time": "10:45",
    "content": "Tudo certo, entrega finalizada.",
    "chef": false,
    "text": true,
  },
  {
    "time": "10:46",
    "content": "Olá",
    "chef": false,
    "text": false,
    "maxDuration": 10,
  },
];
List<Map<String, dynamic>> orders = [
  {
    "id_pedido": "#8921",
    "status": "COLETADO",
    "restaurante": "BURGER JOINT",
    "cliente": "João Silva",
    "itens": "2x Smash Burger, 1x Fritas Crinkle, 1x Refri Cola",
    "endereco": "Rua das Flores, 123 - Apto 42 Centro",
    "image": null,
  },
  {
    "id_pedido": "#8922",
    "status": "A CAMINHO",
    "restaurante": "SUSHI EXPRESS",
    "cliente": "Mariana Costa",
    "itens": "1x Combo Salmão 20 peças, 2x Hashi extra",
    "endereco": "Av. Paulista, 1000 - Conj 54 Bela Vista",
    "image": null,
  },
  {
    "id_pedido": "#8923",
    "status": "NO ESTABELECIMENTO",
    "restaurante": "MAMMA MIA PIZZERIA",
    "cliente": "Carlos Andrade",
    "itens": "1x Pizza Calabresa Grande, 1x Pizza Marguerita Média",
    "endereco": "Rua Augusta, 500 Consolação",
    "image": null,
  },
];
