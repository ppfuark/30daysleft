import 'package:flutter/material.dart';

class Cad extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> data;

  const Cad({super.key, required this.data});
  @override
  State<Cad> createState() => _CadState();
}

class _CadState extends State<Cad> {
  final name = TextEditingController();
  final pass1 = TextEditingController();
  bool obs1 = true;
  final pass2 = TextEditingController();
  bool obs2 = true;
  final email = TextEditingController();
  final date = TextEditingController();
  final user = TextEditingController();

  String selectedM = "Tecnologia Web";

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
      appBar: AppBar(
        leading: IconButton(
          key: Key('cad_pop'),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close),
        ),
        title: Text("Novo Competidor"),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(style: TextStyle(fontSize: 14), "Crie sua conta"),
                subtitle: Text(
                  "Preencha os dados abaixo para se cadastrar na plataforma.",
                ),
              ),
              ListTile(
                key: Key('cad_nome'),
                contentPadding: EdgeInsets.all(0),
                title: Text(style: TextStyle(fontSize: 14), "Nome Completo"),
                subtitle: TextField(
                  keyboardType: TextInputType.name,
                  controller: name,
                  decoration: InputDecoration(hintText: "ex: João Silva"),
                ),
              ),
              ListTile(
                key: Key('cad_pass1'),
                contentPadding: EdgeInsets.all(0),
                title: Text(style: TextStyle(fontSize: 14), "Senha"),
                subtitle: TextField(
                  maxLength: 30,
                  keyboardType: TextInputType.visiblePassword,
                  controller: pass1,
                  obscureText: obs1,
                  decoration: InputDecoration(
                    hintText: "Digite sua senha",
                    suffixIcon: IconButton(
                      onPressed: () => setState(() {
                        obs1 = !obs1;
                      }),
                      icon: Icon(
                        obs1 ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                key: Key('cad_pass2'),

                contentPadding: EdgeInsets.all(0),
                title: Text(style: TextStyle(fontSize: 14), "Confirmar Senha"),
                subtitle: TextField(
                  maxLength: 30,
                  keyboardType: TextInputType.visiblePassword,
                  controller: pass2,
                  obscureText: obs2,
                  decoration: InputDecoration(
                    hintText: "Repita a senha",
                    suffixIcon: IconButton(
                      onPressed: () => setState(() {
                        obs2 = !obs2;
                      }),
                      icon: Icon(
                        obs2 ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
              ),

              ListTile(
                key: Key('cad_email'),

                contentPadding: EdgeInsets.all(0),
                title: Text(
                  style: TextStyle(fontSize: 14),
                  "E-mail institucional",
                ),
                subtitle: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: email,
                  decoration: InputDecoration(
                    hintText: "usuario@spskills.com.br",
                  ),
                ),
              ),
              ListTile(
                key: Key('cad_date'),

                contentPadding: EdgeInsets.all(0),
                title: Text(style: TextStyle(fontSize: 14), "Data Nascimento"),
                subtitle: TextField(
                  readOnly: true,
                  keyboardType: TextInputType.datetime,
                  controller: date,
                  onTap: () async {
                    final da = await showDatePicker(
                      context: context,
                      lastDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      currentDate: DateTime.now(),
                    );

                    if (da != null) {
                      setState(() {
                        date.text = da.toString().split(" ").first;
                      });
                    }
                  },
                  decoration: InputDecoration(),
                ),
              ),
              ListTile(
                key: Key('cad_user'),

                contentPadding: EdgeInsets.all(0),
                title: Text(style: TextStyle(fontSize: 14), "Nome Usuário"),
                subtitle: TextField(
                  keyboardType: TextInputType.name,
                  controller: user,
                  onChanged: (value) {
                    setState(() {
                      user.text = user.text.replaceAll('@', "");
                    });
                  },
                  decoration: InputDecoration(hintText: "@SeuUsuário"),
                ),
              ),
              ListTile(
                key: const Key('cad_modal_dropdown'),
                contentPadding: EdgeInsets.all(0),
                title: Text(style: TextStyle(fontSize: 14), "Modalidade"),
                subtitle: Text(selectedM),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final modalities = (widget.data['modalidades'] as List)
                      .cast<Map<String, dynamic>>();
                  final value = await showModalBottomSheet<String>(
                    context: context,
                    builder: (context) => ListView(
                      children: modalities
                          .map(
                            (modality) => ListTile(
                              title: Text(modality['nome'].toString()),
                              onTap: () => Navigator.pop(
                                context,
                                modality['nome'].toString(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                  if (value != null) {
                    setState(() {
                      selectedM = value;
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (user.text.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("O Nome de Usuário é obrigatório"),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }
                  if (pass1.text.length < 6) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "A senha deve possuir no mínimo 6 caracteres",
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }
                  if (pass1.text != pass2.text) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("As senhas não coincidem"),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }

                  (widget.data['usuarios'] as List).add({
                    "id": (widget.data['usuarios'] as List).length + 1,
                    "nome": name.text,
                    "email": email.text,
                    "senha": pass1.text,
                    "usuario": user.text,
                    "data_nascimento": date.text,
                    "modalidade": selectedM,
                    "amigos": [],
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Cadastro realizado com sucesso! Faça seu login.",
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 5),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: Text("Cadastrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
