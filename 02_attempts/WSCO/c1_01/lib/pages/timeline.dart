import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class Timeline extends StatefulWidget {
  final Map<String, dynamic> me;

  const Timeline({super.key, required this.me});
  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;

  List users = [];
  List posts = [];
  List comments = [];
  String lang = 'pt-BR';

  Future<void> startApp() async {
    try {
      if (WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
          'en') {
        setState(() {
          lang = 'en-US';
        });
      }
      if (WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
          'es') {
        setState(() {
          lang = 'es-ES';
        });
      }

      final raw = await rootBundle.loadString('assets/lista_de_usuarios.json');
      final json = jsonDecode(raw);
      setState(() {
        users = json;
      });
      final raw1 = await rootBundle.loadString(
        'assets/postagens_timeline.json',
      );
      final json1 = jsonDecode(raw1);
      setState(() {
        posts = json1['timeline']['postagens'];
        posts.sort((a, b) {
          return DateTime.parse(
            b['horarioPostagem'].toString(),
          ).compareTo(DateTime.parse(a['horarioPostagem'].toString()));
        });
      });

      final raw2 = await rootBundle.loadString('assets/comentarios.xml');
      final xml = XmlDocument.parse(raw2);
      List data = [];
      for (var element in xml.findAllElements('comentario')) {
        setState(() {
          data.add({
            'postId': element.findAllElements('postId').first.innerText,
            'conteudo': element.findAllElements('conteudo').first.innerText,
            'dataComentario': element
                .findAllElements('dataComentario')
                .first
                .innerText,
            'curtidas': element.findAllElements('curtidas').first.innerText,
            'userId': element
                .findAllElements('usuario')
                .first
                .findAllElements('id')
                .first
                .innerText,
          });
        });
      }
      setState(() {
        comments = data;
      });

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
            appBar: AppBar(
              title: Text("Timeline"),
              automaticallyImplyLeading: false,
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(0),
                    height: 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 20,
                        children: [
                          ...users.map(
                            (e) => Column(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: AssetImage(
                                    'assets/users/${e['foto']}',
                                  ),
                                ),
                                Text(e['nome'].toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: 20,
                        children: [
                          ...posts.map((e) {
                            final a = users
                                .where(
                                  (element) => element['id'] == e['autorId'],
                                )
                                .first;

                            final com = comments.where(
                              (element) =>
                                  element['postId'] == e['id'].toString(),
                            );
                            com.toList().sort(
                              (a, b) => b['curtidas'].toString().compareTo(
                                a['curtidas'].toString(),
                              ),
                            );

                            final likes = com.fold(
                              0,
                              (previousValue, element) =>
                                  previousValue +
                                  int.parse(element['curtidas'] ?? 0),
                            );

                            final time = DateTime.now()
                                .difference(
                                  DateTime.parse(
                                    e['horarioPostagem'].toString(),
                                  ),
                                )
                                .inDays
                                .abs();

                            return Card(
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.all(2),
                                title: ListTile(
                                  contentPadding: EdgeInsets.all(0),

                                  title: Text(a['nome'].toString()),
                                  subtitle: Text(
                                    a['modalidade'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage(
                                      'assets/users/${a['foto'].toString()}',
                                    ),
                                  ),
                                  trailing: Text("há $time dias"),
                                ),
                                subtitle: ListTile(
                                  contentPadding: EdgeInsets.all(10),
                                  title: Text(
                                    e['postagemI18n'][lang].toString(),
                                  ),
                                  subtitle: Row(
                                    spacing: 10,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.favorite),
                                          Text(likes.toString()),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.comment),
                                          Text(com.length.toString()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      ...com.map((e) {
                                        final a = users
                                            .where(
                                              (element) =>
                                                  element['id'].toString() ==
                                                  e['userId'],
                                            )
                                            .first;

                                        return ListTile(
                                          title: Text(a['nome'].toString()),
                                          subtitle: Text(e['conteudo']),
                                          leading: CircleAvatar(
                                            backgroundImage: AssetImage(
                                              'assets/users/${a['foto'].toString()}',
                                            ),
                                          ),
                                          trailing: Text(e['curtidas']),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
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
