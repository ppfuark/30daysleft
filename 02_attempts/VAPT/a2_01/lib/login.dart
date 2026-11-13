import 'package:a2_01/main_page.dart';
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

  static const _animatedItemCount = 6;

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
        msg: 'Os dados não podem estar vazios.',
        backgroundColor: Colors.red,
      );
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
                                            'Para redefinir senha entre em contato com:\n admin@vapt.com',
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
                                onPressed: _isExiting ? null : _submitLogin,
                                child: Text("Entrar"),
                              ),
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
