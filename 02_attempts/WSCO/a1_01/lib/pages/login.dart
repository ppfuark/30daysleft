import 'dart:convert';

import 'package:a1_01/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  final text = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;
  bool isEmail = true;
  bool bio = false;
  final node = FocusNode();

  Future<void> startApp() async {
    try {
      final share = await SharedPreferences.getInstance();
      final bioS = share.getBool('bio') ?? false;

      if (bioS) {
        setState(() {
          bio = bioS;
        });

        final auth = await LocalAuthentication().authenticate(
          localizedReason:
              'Use a impressão digital para validar sua identidade',
          biometricOnly: true,
          authMessages: [
          ]
        );
        if (auth) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          setState(() {
            loading = false;
          });
        }
      }

      setState(() {
        loading = false;
      });

      node.requestFocus();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro ao iniciar a Widget'),
          content: Text(e.toString()),
        ),
      );
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startApp();
    });
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
            body: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/spskills-logo.png',
                    width: w,
                    fit: BoxFit.fill,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isEmail = true;
                                  });
                                },
                                label: Text(""),
                                icon: Icon(Icons.email),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isEmail = false;
                                  });
                                },
                                label: Text(""),
                                icon: Icon(Icons.phone),
                              ),
                            ],
                          ),
                          TextField(
                            focusNode: node,
                            controller: text,
                            decoration: InputDecoration(
                              hintText: isEmail ? "E-mail" : "Telefone",
                            ),
                            keyboardType: isEmail
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            inputFormatters: isEmail
                                ? null
                                : [FilteringTextInputFormatter.digitsOnly],
                          ),
                          TextField(
                            controller: pass,
                            obscureText: obs,
                            decoration: InputDecoration(
                              hintText: 'Senha',
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
                              onChanged: (value) async {
                                setState(() {
                                  bio = value;
                                });
                                final share =
                                    await SharedPreferences.getInstance();

                                await share.setBool('bio', value);
                              },
                            ),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff003467),
                            ),
                            onPressed: () async {
                              try {
                                final res = await http.post(
                                  Uri.parse(
                                    'http://10.109.66.126:3000/auth/login/',
                                  ),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'email': text.text,
                                    'senha': pass.text,
                                  }),
                                );
                                final json = jsonDecode(res.body);
                                if (res.statusCode == 200) {
                                  final share =
                                      await SharedPreferences.getInstance();
                                  await share.setString('token', json['token']);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Home(),
                                    ),
                                  );

                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Dados de acesso inválidos",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Erro ao realizar post: ${e.toString()}',
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
                              }
                            },
                            child: Text(
                              "Logar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Forgot(),
                                ),
                              );
                            },
                            child: Text("Esqueci senha"),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Para novos usuários contate o admin em admin@wsco.com.br',
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
                            child: Text("Novo usuário"),
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

class Forgot extends StatefulWidget {
  const Forgot({super.key});
  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  final text = TextEditingController();
  int index = 0;
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
            appBar: AppBar(title: Text("Recuperar Senha"), centerTitle: true),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(30),
              child: Column(
                spacing: 20,
                children: [
                  Image.asset('assets/spskills-logo.png', width: w * .8),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text(
                      "Recupere a acesso à sua conta",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Informe seu e-mail ou telefone cadastrado e enviaremos instruções para redefinir sua senha",
                    ),
                  ),
                  ToggleButtons(
                    isSelected: [index == 0, index == 1],
                    onPressed: (index) {
                      setState(() {
                        this.index = index;
                      });
                    },
                    selectedColor: Colors.blue,
                    borderRadius: BorderRadius.circular(99),
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.email), Text("E-mail")],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Icon(Icons.phone), Text("Telefone")],
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: text,
                    decoration: InputDecoration(
                      hintText: index == 0
                          ? "E-mail"
                          : "Digite seu número de telefone",
                    ),
                    keyboardType: index == 0
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                    inputFormatters: index == 0
                        ? null
                        : [FilteringTextInputFormatter.digitsOnly],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff003467),
                    ),
                    onPressed: () {
                      if (text.text.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Instruções foram enviadas"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Dados de acesso não encontrados."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Enviar instruções",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Lembrou a senha? Voltar para o login"),
                  ),
                ],
              ),
            ),
          );
  }
}
