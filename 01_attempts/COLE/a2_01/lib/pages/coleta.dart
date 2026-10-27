import 'dart:convert';

import 'package:a2_01/app.dart';
import 'package:a2_01/login.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Coleta extends StatefulWidget {
  final Function onTap;

  const Coleta({super.key, required this.onTap});
  @override
  State<Coleta> createState() => _ColetaState();
}

class _ColetaState extends State<Coleta> {
  Map<String, dynamic>? selected;
  List coletas = [];

  bool loading = false;

  void startApp() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('token') ?? "";

    final response = await http.get(
      Uri.parse('http://192.168.56.1:8080/api/v1/coletas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // print(response.body);

      setState(() {
        coletas = jsonDecode(response.body)['data'];
      });
    } else {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      });
    }
    return null;
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Coletas"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                App.toogle();
              });
            },
            icon: Icon(
              App.valueNotifier.value == App.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
        ],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Row(
          spacing: 10,
          children: [
            SizedBox(
              width: w * .3,
              height: double.infinity,
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final c = coletas[index];
                  return GestureDetector(
                    onDoubleTap: () async {
                      final SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      final token = sharedPreferences.getString('token') ?? "";

                      final response = await http.put(
                        Uri.parse(
                          'http://192.168.56.1:8080/api/v1/coletas/${c['id']}',
                        ),
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $token',
                        },
                        body: jsonEncode({
                          "id": c['id'],
                          "nome": c['nome'],
                          "tag": c['tag'],
                          "tipoResiduo": c['tipoResiduo'],
                          "dataHoraAgendada": c['dataHoraAgendada'],
                          "foto": c['foto'],
                          "situacao": c['situacao'],
                          "urgencia": !c['urgencia'],
                          "responsavelId": c['responsavelId'],
                          "rota": c['rota'],
                          "observacoes": c['observacoes'],
                        }),
                      );
                      if (response.statusCode == 200 ||
                          response.statusCode == 201 ||
                          response.statusCode == 204) {
                        startApp();
                      }
                    },
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          selected = c;
                          print(selected);
                        });
                      },
                      tileColor: c['urgencia'] ? Color(0x20f4a300) : null,
                      leading: Image.network(c['foto'].toString()),
                      title: Text(c['nome'].toString()),
                      subtitle: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(c['tipoResiduo'].toString().toUpperCase()),
                        subtitle: Text(
                          "${DateTime.parse(c['dataHoraAgendada'].toString()).day}/${DateTime.parse(c['dataHoraAgendada'].toString()).month}/${DateTime.parse(c['dataHoraAgendada'].toString()).year}",
                        ),
                      ),
                      trailing: Chip(label: Text(c['tag'].toString())),
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: coletas.length,
              ),
            ),
            Expanded(
              child: selected == null
                  ? Center(
                      child: Text("Selecione uma coleta para ver os detalhes"),
                    )
                  : Column(
                      children: [
                        ListTile(
                          tileColor: selected!['urgencia']
                              ? Color(0x20f4a300)
                              : null,
                          leading: Image.network(selected!['foto'].toString()),
                          title: Text(selected!['nome'].toString()),
                          subtitle: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              selected!['tipoResiduo'].toString().toUpperCase(),
                            ),
                            subtitle: Text(
                              "${DateTime.parse(selected!['dataHoraAgendada'].toString()).day}/${DateTime.parse(selected!['dataHoraAgendada'].toString()).month}/${DateTime.parse(selected!['dataHoraAgendada'].toString()).year}",
                            ),
                          ),
                          trailing: Chip(
                            label: Text(selected!['tag'].toString()),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.route),
                          title: Text("Rota:"),
                          subtitle: Text(selected!['rota'].toString()),
                        ),
                        ListTile(
                          leading: Icon(Icons.details),
                          title: Text("Observacões:"),
                          subtitle: Text(selected!['observacoes'].toString()),
                        ),

                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                final file = await FilePicker.pickFile(
                                  allowedExtensions: ['pdf'],
                                );
                                await Future.delayed(Duration(seconds: 2));
                                setState(() {
                                  loading = false;
                                });
                                if (file != null) {
                                  Fluttertoast.showToast(
                                    msg: 'Relatório enviado com sucesso!',
                                    backgroundColor: Colors.green,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: 'Erro ao enviar o relatório. Tente novamente',
                                    backgroundColor: Colors.red,
                                  );
                                }
                              },
                              label: Text("Enviar PDF"),
                              icon: Icon(Icons.picture_as_pdf),
                            ),
                            ElevatedButton(
                              onPressed: () async {},
                              child: loading
                                  ? Center(child: CircularProgressIndicator())
                                  : Text("Salvar"),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                widget.onTap();
                              },
                              child: Text("Colaboradores"),
                            ),
                          ],
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
