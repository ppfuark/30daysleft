import 'package:a1_01/pages/cart.dart';
import 'package:a1_01/pages/home.dart';
import 'package:a1_01/pages/orders.dart';
import 'package:a1_01/pages/profile.dart';
import 'package:a1_01/pages/search.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  int index = 0;

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
    final pages = [
      Home(),
      Search(
        onTap: () {
          setState(() {
            index = 4;
          });
        },
      ),
      Cart(),
      Orders(),
      Profile(),
    ];

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
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Início",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "Explore",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: "Carrinho",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: "Pedidos",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Perfil",
                ),
              ],
              currentIndex: index,
              onTap: (value) {
                setState(() {
                  index = value;
                });
              },
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.deepOrangeAccent,
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(10),
              child: pages[index],
            ),
          );
  }
}
