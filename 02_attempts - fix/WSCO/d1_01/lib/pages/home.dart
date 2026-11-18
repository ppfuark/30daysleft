import 'package:d1_01/pages/new_p.dart';
import 'package:d1_01/pages/profile.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> data;
  final int me;

  const Home({super.key, required this.data, required this.me});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = true;
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

  int index = 0;

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
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
                key: Key('home_pop'),
              ),
              title: Row(
                children: [
                  IconButton(
                    key: Key('home_prof'),
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Profile(data: widget.data, me: widget.me),
                        ),
                      );
                    },
                    icon: Icon(Icons.person),
                  ),
                  Text("Comunidade"),
                ],
              ),
              actions: [
                ToggleButtons(
                  key: Key('home_tog'),
                  isSelected: [index == 0, index == 1],
                  onPressed: (index) {
                    setState(() {
                      this.index = index;
                    });
                  },
                  selectedColor: Colors.blue,
                  borderRadius: BorderRadius.circular(999),
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Row(children: [Text("Lista"), Icon(Icons.list)]),
                    ),
                    Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Row(
                        children: [Text("Grid"), Icon(Icons.grid_3x3)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(10),
              child: index == 0
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          ...(widget.data['posts'] as List).map((e) {
                            final a = (widget.data['usuarios'] as List)
                                .firstWhere(
                                  (element) => element['id'] == e['usuario_id'],
                                  orElse: () => {"": ""},
                                );

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                      title: Text(a['nome'].toString()),
                                      subtitle: Text(a['modalidade']),
                                    ),
                                    Image.asset(
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      e['imagem']
                                          .toString()
                                          .replaceAll('media-files', 'assets')
                                          .replaceAll('_0', "_"),
                                    ),
                                    ListTile(
                                      title: Text(e['texto'].toString()),
                                      subtitle: Text(e['tags'].join(" ")),
                                      trailing: Column(
                                        children: [
                                          Text(e['likes'].toString()),
                                          GestureDetector(
                                            key: Key('like_${e['id']}'),
                                            onTap: () {
                                              setState(() {
                                                e['likes']++;
                                              });
                                            },
                                            child: Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.35,
                      ),
                      itemBuilder: (context, index) {
                        final e = (widget.data['posts'])[index];

                        final a = (widget.data['usuarios'] as List).firstWhere(
                          (element) => element['id'] == e['usuario_id'],
                          orElse: () => {"": ""},
                        );

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(a['nome'].toString()),
                                  subtitle: Text(a['modalidade']),
                                ),
                                Image.asset(
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  e['imagem']
                                      .toString()
                                      .replaceAll('media-files', 'assets')
                                      .replaceAll('_0', "_"),
                                ),
                                ListTile(
                                  title: Text(e['texto'].toString()),
                                  subtitle: Text(e['tags'].join(" ")),
                                  trailing: Column(
                                    children: [
                                      Text(e['likes'].toString()),
                                      Icon(Icons.favorite, color: Colors.red),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: (widget.data['posts'] as List).length,
                    ),
            ),
            floatingActionButton: FloatingActionButton(
              key: Key('home_float'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewP()),
                );
              },
              child: Icon(Icons.add),
            ),
          );
  }
}
