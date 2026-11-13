import 'dart:async';
import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/pages/main_page.dart';
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
  @override
  void initState() {
    App.init();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: App.theme,
      builder: (context, value, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: value,
          home: const MyHomePage(),
        );
      },
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

  int errors = 0;
  int left = 10;
  Timer? timer;
  bool blocked = false;

  bool bio = false;

  void increment() {
    Fluttertoast.showToast(
      msg: 'Credenciais inválidas! Revise seus dados e tente novamente.',
      backgroundColor: Colors.red,
    );
    setState(() {
      errors++;
    });

    if (errors == 3) {
      Fluttertoast.showToast(
        msg: 'Login Bloqueado! Tente novamente em 10 segundos..',
        backgroundColor: Colors.red,
      );
      setState(() {
        blocked = true;
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            left--;

            if (left == 0) {
              setState(() {
                timer.cancel();
                blocked = false;
                errors = 0;
                left = 10;
              });
            }
          });
        });
      });
    }
  }

  Future<void> startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final t = sharedPreferences.getString('token');

    final response = await http.get(
      Uri.parse('http://10.109.66.126:3000/competidores'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $t',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        bio = true;
      });
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
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            Image.asset("assets/ic_launcher.png"),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text("Bem-vindo ao WSConecta"),
              subtitle: Text(
                "Uma comunidade para a maior comepticção de educação profissinal do mundo!",
              ),
            ),

            TextField(
              enabled: !blocked,
              controller: email,
              decoration: InputDecoration(hintText: "E-mail"),
            ),
            TextField(
              enabled: !blocked,
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
                  icon: Icon(obs ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () {}, child: Text("Esqueceu a senha?")),
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
                        title: Text("Você deseja realmente sair?"),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Não"),
                          ),
                          TextButton(
                            onPressed: () async {
                              final SharedPreferences sharedPreferences =
                                  await SharedPreferences.getInstance();
                              await sharedPreferences.setString('token', "");
                            },
                            child: Text("Sim"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text("Sair"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: blocked
                  ? null
                  : () async {
                      final response = await http
                          .post(
                            Uri.parse('http://10.109.66.126:3000/auth/login'),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({
                              "email": email.text,
                              "password": pass.text,
                            }),
                          )
                          .timeout(Duration(seconds: 5));
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
                        increment();
                      }
                    },
              child: Text(blocked ? "${left}s" : "Entrar"),
            ),
            Text("ou"),
            ElevatedButton.icon(
              onPressed: bio
                  ? () async {
                      final auth = await LocalAuthentication().authenticate(
                        localizedReason: "Biometria",
                        biometricOnly: true,
                      );

                      if (auth) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      }
                    }
                  : null,
              label: Text("Entrar com Biometria"),
              icon: Icon(Icons.fingerprint),
            ),
          ],
        ),
      ),
    );
  }
}
