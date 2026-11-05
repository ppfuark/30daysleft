import 'dart:convert';

import 'package:attempt_02/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.inriaSansTextTheme(),
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
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
  List users = [];

  Future<void> startApp() async {
    final raw = await rootBundle.loadString('assets/lista_de_usuarios.json');
    final json = jsonDecode(raw);
    setState(() {
      users = json;
    });
  }

  final name = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

  int erros = 0;
  bool blocked = false;

  Future<void> increment() async {
    Fluttertoast.showToast(
      msg: 'Usuário/Senha inválidos!',
      backgroundColor: Colors.red,
    );
    setState(() {
      erros++;
    });

    if (erros >= 3) {
      setState(() {
        blocked = true;
      });
      Fluttertoast.showToast(
        msg: 'Login bloqueado: aguarde 30 segundos!',
        backgroundColor: Colors.red,
      );
      await Future.delayed(Duration(seconds: 30));
      setState(() {
        blocked = false;
        erros = 0;
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
          spacing: 10,
          children: [
            Image.asset('assets/ic_launcher.png'),
            Text("Login"),
            TextField(
              controller: name,
              decoration: InputDecoration(hintText: "Usuário"),
            ),
            TextField(
              controller: pass,
              obscureText: obs,
              obscuringCharacter: "*",
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
            ElevatedButton(
              onPressed: blocked
                  ? null
                  : () {
                      final exist = users.where(
                        (element) =>
                            element['e-mail'] == name.text &&
                            element['data de nascimento'].toString().replaceAll(
                                  '/',
                                  '',
                                ) ==
                                pass.text,
                      );

                      if (exist.isEmpty) {
                        increment();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainPage(me: exist.first),
                          ),
                        );
                      }
                    },
              child: Text("Acessar"),
            ),
            ElevatedButton(
              onPressed: blocked ? null : () {},
              child: Text("Cadastre-se"),
            ),
            Text("ou entre com"),
            FaIcon(FontAwesomeIcons.google),
          ],
        ),
      ),
    );
  }
}
