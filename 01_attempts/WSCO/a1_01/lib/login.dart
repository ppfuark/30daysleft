import 'dart:convert';

import 'package:a1_01/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final text = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;
  bool email = true;

  bool bio = false;

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final res = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://10.109.66.126:3000/modalidades/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $res",
      },
    );
    if (response.statusCode == 200) {
      final auth = await LocalAuthentication().authenticate(
        localizedReason: 'Use a impressão digital para validar sua identidade',
        biometricOnly: true,
      );

      if (auth) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
  }

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
      body: SizedBox(
        width: w,
        height: h,
        child: Column(
          children: [
            Image.asset('assets/spskills-logo.png', width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            email = true;
                          });
                        },
                        icon: Icon(Icons.email),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            email = false;
                          });
                        },
                        icon: Icon(Icons.phone),
                      ),
                    ],
                  ),
                  TextField(
                    controller: text,
                    keyboardType: email
                        ? null
                        : TextInputType.numberWithOptions(),
                    inputFormatters: email
                        ? null
                        : [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: email ? "E-mail" : "Telefone",
                    ),
                  ),
                  TextField(
                    controller: pass,
                    obscureText: obs,
                    decoration: InputDecoration(
                      hintText: "Senha",
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
                  ListTile(
                    leading: Icon(Icons.fingerprint),
                    title: Text("Habilitar biometria"),
                    trailing: Switch(
                      value: bio,
                      onChanged: (value) {
                        setState(() {
                          bio = value;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final response = await http.post(
                        Uri.parse('http://10.109.66.126:3000/auth/login/'),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "email": text.text,
                          "senha": pass.text,
                        }),
                      );
                      if (response.statusCode == 200) {
                        if (bio) {
                          final SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          await sharedPreferences.setString(
                            'token',
                            jsonDecode(response.body)['token'],
                          );
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Home()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dados de acesso inválidos.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text("Logar"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Recupera()),
                      );
                    },
                    child: Text("Esqueci senha"),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Novo usuários somente com o administrador em admin@spskills.com",
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Ok!"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text("Novo usuário"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Recupera extends StatefulWidget {
  const Recupera({super.key});
  @override
  State<Recupera> createState() => _RecuperaState();
}

class _RecuperaState extends State<Recupera> {
  int index = 0;

  final tex = TextEditingController();

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
      appBar: AppBar(title: Text("Recuperar Senha")),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/spskills-logo.png'),
            Text(
              "Recupere o acesso à sua conta",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "Informe seu e-mail ou telefone cadastrado e enviaremos instruções para redefinir senha",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            ),
            ToggleButtons(
              isSelected: [index == 0, index == 1],
              onPressed: (index) {
                setState(() {
                  this.index = index;
                });
              },
              borderRadius: BorderRadius.circular(999),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(children: [Icon(Icons.email), Text("E-mail")]),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(children: [Icon(Icons.phone), Text("Telefone")]),
                ),
              ],
            ),
            TextField(
              controller: tex,
              keyboardType: index == 0
                  ? null
                  : TextInputType.numberWithOptions(),
              inputFormatters: index == 0
                  ? null
                  : [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: index == 0
                    ? "E-mail"
                    : "Digite seu número de telefone",
              ),
            ),
            GestureDetector(
              onTap: () {
                if (RegExp(r'^[0-9a-zA-Z]+@[0-9a-zA-Z]+\.[0-9a-zA-Z]+$')
                    .hasMatch(tex.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Instruções enviadas.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('E-mail ou telefone não encontrado.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(color: Color(0xff003764)),
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "Enviar instruções",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Lembrou a senha"),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Voltar para o login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
