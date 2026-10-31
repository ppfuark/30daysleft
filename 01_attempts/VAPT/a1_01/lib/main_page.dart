import 'package:a1_01/pages/cart.dart';
import 'package:a1_01/pages/explore.dart';
import 'package:a1_01/pages/home.dart';
import 'package:a1_01/pages/order.dart';
import 'package:a1_01/pages/profile.dart';
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
      Explore(),
      Cart(),
      Order(),
      Profile(
        onTap: () => setState(() {
          index = 2;
        }),
      ),
    ];

    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(width: w, height: h, child: pages[index]),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Pesquisar"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Carrinho",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Pedidos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },

        unselectedItemColor: Colors.grey.shade300,
        selectedItemColor: Color(0xffD11a1f),
      ),
    );
  }
}
