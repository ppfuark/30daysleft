import 'dart:convert';

import 'package:a1_01/main_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isOff = false;

  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        setState(() {
          isOff = true;
          Fluttertoast.showToast(
            msg: 'Falha de conexão. Verifique sua internet e tente novamente',
            backgroundColor: Colors.red,
          );
        });
      } else {
        setState(() {
          isOff = false;
        });
      }
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepOrange)),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;
  bool bio = true;
  bool loading = false;

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://192.168.56.1:3000/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        bio = true;
      });
    } else {
      bio = false;
    }
  }

  final text = TextEditingController();

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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset('assets/ic_launcher.png'),
            Text("Bem-vindo de volta"),
            Text("Sabores frescos a apenas um login de distância"),
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "name@example.com"),
            ),
            TextField(
              obscureText: obs,
              controller: pass,
              decoration: InputDecoration(
                hintText: "Senha",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obs = !obs;
                    });
                  },
                  icon: Icon(obs ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("E-mail"),
                        content: TextField(
                          controller: text,
                          decoration: InputDecoration(
                            hintText: "Digite seu e-mail",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (RegExp(
                                r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z0-9]+$',
                              ).hasMatch(text.text)) {
                                final response = await http.post(
                                  Uri.parse(
                                    'http://192.168.56.1:3000/forgotPassword',
                                  ),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'email': text.text}),
                                );
                                if (response.statusCode == 200) {
                                  Fluttertoast.showToast(
                                    msg: 'Envio do link de redefinição.',
                                    backgroundColor: Colors.green,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: 'E-mail não cadastrado.',
                                    backgroundColor: Colors.red,
                                  );
                                }
                              } else {
                                Fluttertoast.showToast(
                                  msg: 'E-mail no formato inválido',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            child: Text("Resetar Senha"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text("Esqueceu?"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                final response = await http.post(
                  Uri.parse('http://192.168.56.1:3000/api/auth/login'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'email': email.text,
                    'password': pass.text,
                  }),
                );
                if (response.statusCode == 200) {
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  await sharedPreferences.setString(
                    'token',
                    jsonDecode(response.body)['token'],
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: 'Dados de acesso inválidos.',
                    backgroundColor: Colors.red,
                  );
                }
                setState(() {
                  loading = false;
                });
              },
              child: loading ? CircularProgressIndicator() : Text("ENTRAR"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("OU")],
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.fingerprint),
              onPressed: bio
                  ? () async {
                      final auth = await LocalAuthentication().authenticate(
                        localizedReason: "Biometria",
                      );

                      if (auth) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      }
                    }
                  : null,
              label: Text("ENTRAR"),
            ),
          ],
        ),
      ),
    );
  }
}
