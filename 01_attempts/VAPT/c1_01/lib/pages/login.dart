import 'dart:async';

import 'package:c1_01/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final text = TextEditingController();
  bool obs = true;

  int erros = 0;
  int left = 10;
  bool blocked = false;
  Timer? timer;

  void increment() {
    setState(() {
      erros++;
    });
    Fluttertoast.showToast(msg: 'Senha incorreta', backgroundColor: Colors.red);

    if (erros == 3) {
      Fluttertoast.showToast(
        msg: 'Você errou por 3 vezes consecutivas, aguarde 10 segundos para digitar novamente',
        backgroundColor: Colors.red,
      );
      setState(() {
        blocked = true;
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            left--;

            if (left == 0) {
              timer.cancel();
              left = 10;
              erros = 0;
              blocked = false;
            }
          });
        });
      });
    }
  }

  FocusNode focusNode = FocusNode();

  Future<void> startApp() async {}
  @override
  void initState() {
    startApp();

    focusNode.requestFocus();
    super.initState();
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
            Image.asset('assets/ic_launcher.png'),
            TextField(
              controller: text,
              obscureText: obs,
              enabled: !blocked,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: erros != 0 ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: erros != 0 ? Colors.red : Colors.grey,
                  ),
                ),
                hintText: "Digite sua senha",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obs = !obs;
                    });
                  },
                  icon: Icon(obs ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              focusNode: focusNode,
            ),
            if (blocked) Text(left.toString()),
            ElevatedButton(
              onPressed: blocked
                  ? null
                  : () {
                      if (text.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'Necessário digitar a senha',
                          backgroundColor: Colors.red,
                        );
                        return;
                      }

                      if (text.text != "senha123") {
                        increment();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      }
                    },
              child: Text("CONECTAR"),
            ),
          ],
        ),
      ),
    );
  }
}
