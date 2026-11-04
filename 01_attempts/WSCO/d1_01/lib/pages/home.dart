import 'package:d1_01/pages/new.dart';
import 'package:d1_01/pages/profil.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> data;
  final int me;

  const Home({super.key, required this.data, required this.me});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;

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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          key: Key('home_pop'),
        ),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Profil(data: widget.data, me: widget.me),
                  ),
                );
              },
              key: const Key('home_profile'),
              icon: Icon(Icons.person),
            ),
            Text("Comunidade"),
          ],
        ),
        actions: [
          ToggleButtons(
            isSelected: [index == 0, index == 1],
            borderRadius: BorderRadius.circular(999),
            selectedColor: Color(0xff003764),
            onPressed: (index) {
              setState(() {
                this.index = index;
              });
            },
            children: [
              Padding(
                key: Key('home_list'),
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [Text("Lista"), Icon(Icons.list)]),
              ),
              Padding(
                key: Key('home_grid'),
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [Text("Grid"), Icon(Icons.grid_3x3)]),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => New(data: widget.data, me: widget.me),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: index == 0
            ? ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final i = (widget.data["posts"] as List)[index];
                  final a = (widget.data["usuarios"] as List)
                      .where((element) => i['usuario_id'] == element['id'])
                      .first;

                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(a['nome'].toString()),
                          subtitle: Text(a['modalidade'].toString()),
                        ),
                        if (i['imagem'].toString().isNotEmpty)
                          Image.asset(
                            fit: BoxFit.cover,
                            i['imagem']
                                .toString()
                                .replaceAll('media-files', 'assets')
                                .replaceAll(
                                  i['imagem'].toString().contains('10')
                                      ? ""
                                      : "0",
                                  "",
                                ),
                            height: 100,
                            width: double.infinity,
                          ),
                        ListTile(
                          title: Text(i['texto'].toString()),
                          subtitle: Text((i['tags'] as List).join(" ")),
                        ),
                        Row(
                          children: [
                            IconButton(
                              key: Key("home_like_$index"),
                              onPressed: () {
                                setState(() {
                                  i['likes']++;
                                });
                              },
                              icon: Icon(Icons.favorite, color: Colors.red),
                            ),
                            Text(i['likes'].toString()),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                itemCount: (widget.data["posts"] as List).length,
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.35,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final i = (widget.data["posts"] as List)[index];
                  final a = (widget.data["usuarios"] as List)
                      .where((element) => i['usuario_id'] == element['id'])
                      .first;

                  return Card(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(a['nome'].toString()),
                            subtitle: Text(a['modalidade'].toString()),
                          ),
                          if (i['imagem'].toString().isNotEmpty)
                            Image.asset(
                              fit: BoxFit.cover,
                              i['imagem']
                                  .toString()
                                  .replaceAll('media-files', 'assets')
                                  .replaceAll(
                                    i['imagem'].toString().contains('10')
                                        ? ""
                                        : "0",
                                    "",
                                  ),
                              height: 100,
                              width: double.infinity,
                            ),
                          ListTile(
                            title: Text(i['texto'].toString()),
                            subtitle: Text((i['tags'] as List).join(" ")),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    i['likes']++;
                                  });
                                },
                                icon: Icon(Icons.favorite, color: Colors.red),
                              ),
                              Text(i['likes'].toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: (widget.data["posts"] as List).length,
              ),
      ),
    );
  }
}
