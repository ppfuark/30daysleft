import 'dart:convert';

import 'package:a2_01/main_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;
  bool bio = false;
  bool loading = false;

  bool show1 = false;
  bool show2 = false;

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
            Image.asset('assets/ic_launcher.png', width: 200),
            TextField(
              controller: email,
              decoration: InputDecoration(
                hintText: "E-mail",
                helperText: "Formato de e-mail inválido",
                helperStyle: TextStyle(
                  color: show1 ? Colors.red : Colors.transparent,
                ),
              ),
            ),
            TextField(
              controller: pass,
              obscureText: obs,
              decoration: InputDecoration(
                hintText: "Senha",
                helperText: "A senha deve ter no mínimo 6 caracteres",
                helperStyle: TextStyle(
                  color: show2 ? Colors.red : Colors.transparent,
                ),
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
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                if (!RegExp(
                  r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+\.[a-zA-Z0-9]+$',
                ).hasMatch(email.text)) {
                  setState(() {
                    show1 = true;
                  });
                  setState(() {
                    loading = false;
                  });
                  return;
                } else {
                  setState(() {
                    show1 = false;
                  });
                }
                if (pass.text.length < 6) {
                  setState(() {
                    show2 = true;
                  });
                  setState(() {
                    loading = false;
                  });
                  return;
                } else {
                  setState(() {
                    show2 = false;
                  });
                }

                final response = await http.post(
                  Uri.parse('http://192.168.56.1:8080/api/v1/auth/login/'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'email': email.text,
                    'password': pass.text,
                  }),
                );

                setState(() {
                  loading = false;
                });

                if (response.statusCode == 200) {
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  await sharedPreferences.setString(
                    'token',
                    jsonDecode(response.body)['token'],
                  );

                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainPage()),
                    );
                  });
                } else {
                  Fluttertoast.showToast(
                    msg: 'E-mail ou senha incorretos. Verifique suas credenciais.',
                    backgroundColor: Colors.red,
                  );
                }
              },
              child: loading ? CircularProgressIndicator() : Text("Entrar"),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final auth = await LocalAuthentication().authenticate(
                  localizedReason: "Biometria",
                  biometricOnly: true,
                );

                if (auth) {
                  Fluttertoast.showToast(
                    msg: 'Autenticação biométrica reconhecida, porém token informado está inválido.',
                    backgroundColor: Colors.red,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: 'Autenticação biométrica não reconhecida. Tente novamente ou use senha.',
                    backgroundColor: Colors.red,
                  );
                }
              },
              label: Text("Entrar com Biometria"),
              icon: Icon(Icons.fingerprint),
            ),
          ],
        ),
      ),
    );
  }
}
