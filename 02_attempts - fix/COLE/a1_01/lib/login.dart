import 'package:a1_01/main_page.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

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
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Image.asset('assets/ic_launcher.png', height: 100),
                  ListTile(
                    title: Text("Bem-vindo"),
                    subtitle: Text("Entre para salvar o planeta"),
                  ),
                  ListTile(
                    title: Text("E-mail"),
                    subtitle: TextField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "Digite seu e-mail",
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text("Senha"),
                    subtitle: TextField(
                      controller: pass,
                      obscureText: obs,
                      decoration: InputDecoration(
                        hintText: "Digite sua senha",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obs = !obs;
                            });
                          },
                          icon: Icon(
                            obs ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!RegExp(
                            r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+$',
                          ).hasMatch(email.text) ||
                          pass.text.isEmpty) {
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      }
                    },
                    child: Text("Entrar"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Não tem conta?"),
                      TextButton(onPressed: () {}, child: Text("Cadastre-se")),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
