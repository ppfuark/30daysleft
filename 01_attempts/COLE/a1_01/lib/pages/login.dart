import 'package:a1_01/main_page.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

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
            Image.asset('assets/ic_launcher.png', width: 200,),
            Text("Bem-vindo"),
            Text("Entre para salvar o planeta"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Email"),
                TextField(
                  controller: email,
                  decoration: InputDecoration(hintText: "Digite seu e-mail"),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Senha"),
                TextField(
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
                      icon: Icon(obs ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: w,
              child: ElevatedButton(
                onPressed: () {
                  if (email.text.isEmpty || pass.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Campo(s) vazio(s)."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+$')
                      .hasMatch(email.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("E-mail no formato inválido"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                child: Text("Entrar"),
              ),
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
