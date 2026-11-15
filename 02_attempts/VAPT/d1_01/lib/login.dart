import 'package:d1_01/main_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
  bool _isExiting = false;

  int erros = 0;
  bool blocked = false;

  Future<void> increment(bool t) async {
    if (t) {
      Fluttertoast.showToast(
        msg: 'E-mail ou senha incorretos',
        backgroundColor: Colors.red,
      );
    }
    setState(() {
      erros++;
    });

    if (erros == 3) {
      setState(() {
        blocked = true;
        email.clear();
        pass.clear();
      });

      await Future.delayed(Duration(seconds: 10));

      setState(() {
        blocked = false;
      });
    }
  }

  static const _animatedItemCount = 7;

  Widget _animatedItem(int index, Widget child) {
    final start = index / _animatedItemCount;
    final end = (index + 1) / _animatedItemCount;
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  Future<void> _submitLogin() async {
    if (email.text.isEmpty || pass.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Campos vazios! Tente Novamente',
        backgroundColor: Colors.red,
      );
      increment(false);
      return;
    }

    if (!RegExp(
      r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+$',
    ).hasMatch(email.text)) {
      Fluttertoast.showToast(
        msg: 'E-mail no formato inválido!',
        backgroundColor: Colors.red,
      );
      increment(false);
      return;
    }

    if (email.text != "gerente@vaptfood.com.br" && pass.text != "Vapt@2026") {
      increment(true);
      return;
    }

    setState(() {
      _isExiting = true;
    });
    await _controller.reverse();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
      (route) => false,
    );
  }

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.forward();
    startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

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
              padding: EdgeInsets.all(0),
              child: Row(
                children: [
                  _animatedItem(
                    0,
                    Image.asset(
                      'assets/images/login.png',
                      width: w * .5,
                      height: h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          _animatedItem(
                            1,
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text(
                                "Bem-vindo ao VaptFood",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Entre para gerenciar seus pedidos",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          _animatedItem(
                            2,
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text("E-mail"),
                              subtitle: TextField(
                                key: Key('log_email'),
                                controller: email,
                                decoration: InputDecoration(
                                  hintText: "Digite seu e-mail",
                                ),
                              ),
                            ),
                          ),
                          _animatedItem(
                            3,
                            ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Text("Senha"),
                              subtitle: TextField(
                                key: Key('log_pass'),
                                controller: pass,
                                obscureText: obs,
                                decoration: InputDecoration(
                                  hintText: "Digite sua senha",
                                  suffixIcon: GestureDetector(
                                    onLongPressStart: (d) {
                                      setState(() {
                                        obs = false;
                                      });
                                    },
                                    onLongPressEnd: (d) {
                                      setState(() {
                                        obs = true;
                                      });
                                    },
                                    child: Icon(
                                      obs
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _animatedItem(
                            4,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Opção indisponível no momento',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Ok!'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text("Esqueci minha senha"),
                                ),
                              ],
                            ),
                          ),
                          _animatedItem(
                            5,
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isExiting || blocked
                                    ? null
                                    : _submitLogin,
                                child: Text("Entrar"),
                              ),
                            ),
                          ),
                          _animatedItem(
                            6,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Problemas para acessar?"),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Opção indisponível no momento',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Ok!'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Text("Fale com o suporte"),
                                ),
                              ],
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
