import 'package:a2_01/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        child: Row(
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/login.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      title: Text("Bem-vindo ao VaptFood"),
                      subtitle: Text("Entre para gerenciar seus pedidos"),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("E-mail"),
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            hintText: "Digite seu e-mail",
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Senha"),
                        TextField(
                          obscureText: obs,
                          controller: pass,
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  "Contate o administrador em contato@adminvapt.com.br",
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Ok!"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text("Esqueci minha senha"),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (email.text.isEmpty) {
                            Fluttertoast.showToast(
                              msg: 'E-mail vazio ou inválido',
                              backgroundColor: Colors.red,
                            );
                            return;
                          }
                          if (pass.text.isEmpty) {
                            Fluttertoast.showToast(
                              msg: 'Senha vazia ou inválida',
                              backgroundColor: Colors.red,
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
