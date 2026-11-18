import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final Map<String, dynamic> data;
  final int me;

  const Profile({super.key, required this.data, required this.me});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool editing = false;

  final name = TextEditingController();
  final email = TextEditingController();
  final date = TextEditingController();
  final user = TextEditingController();
  final password = TextEditingController();
  String selectedM = "Tecnologia Web";

  late final Map<String, dynamic> meCopy = (widget.data['usuarios'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((element) => element['id'] == widget.me);

  late List<Map<String, dynamic>> friends = [];

  @override
  void initState() {
    super.initState();
    name.text = meCopy['nome'].toString();
    email.text = meCopy['email'].toString();
    date.text = meCopy['data_nascimento'].toString();
    user.text = meCopy['usuario'].toString();
    selectedM = meCopy['modalidade'].toString();
    friends = _friendsFromIds(meCopy['amigos'] as List);
  }

  List<Map<String, dynamic>> _friendsFromIds(List ids) {
    return (widget.data['usuarios'] as List)
        .cast<Map<String, dynamic>>()
        .where((element) => ids.contains(element['id']))
        .toList();
  }

  Future<void> _openFriends() async {
    final users = (widget.data['usuarios'] as List)
        .cast<Map<String, dynamic>>();
    final draftFriends = List<Map<String, dynamic>>.from(friends);
    final draftNonFriends = users
        .where(
          (person) =>
              person['id'] != widget.me &&
              !draftFriends.any((friend) => friend['id'] == person['id']),
        )
        .toList();

    final shouldSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Meus Amigos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  key: const Key('friends_add'),
                  isExpanded: true,
                  hint: const Text("Adicionar Amigo"),
                  items: draftNonFriends
                      .map(
                        (person) => DropdownMenuItem<int>(
                          value: person['id'] as int,
                          child: Text(person['nome'].toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    setSheetState(() {
                      final person = draftNonFriends.firstWhere(
                        (candidate) => candidate['id'] == id,
                      );
                      draftFriends.add(person);
                      draftNonFriends.remove(person);
                    });
                  },
                ),
                const SizedBox(height: 12),
                ...draftFriends.map(
                  (person) => ListTile(
                    key: Key('friend_${person['id']}'),
                    title: Text(person['nome'].toString()),
                    trailing: IconButton(
                      key: Key('friend_remove_${person['id']}'),
                      onPressed: () {
                        setSheetState(() {
                          draftFriends.remove(person);
                          draftNonFriends.add(person);
                        });
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      key: const Key('friends_cancel'),
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      key: const Key('friends_save'),
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: const Text("Salvar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldSave == true) {
      meCopy['amigos'] = draftFriends.map((friend) => friend['id']).toList();
      setState(() {
        friends = draftFriends;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = (widget.data['usuarios'] as List)
        .where((element) => element['id'] == widget.me)
        .first;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          key: Key('prof_pop'),
        ),
        title: Text("Perfil"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                editing = true;
              });
            },
            key: const Key('profile_edit'),
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _openFriends,
            key: const Key('profile_friends'),
            icon: Icon(Icons.people),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(me['nome'].toString()),
              subtitle: ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(me['modalidade'].toString()),
                subtitle: Text("@${me['usuario']}"),
              ),
            ),
            Row(
              spacing: 30,
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: Text(
                        (widget.data['posts'] as List)
                            .where(
                              (element) => element['usuario_id'] == me['id'],
                            )
                            .length
                            .toString(),
                      ),
                      subtitle: Text("Publicações"),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: Text(
                        (me['amigos'] as List).length.toString(),
                        key: const Key('profile_friend_count'),
                      ),
                      subtitle: Text("Amigos"),
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              enabled: false,
              contentPadding: EdgeInsets.all(0),
              title: Text(
                style: TextStyle(fontSize: 14),
                "E-mail institucional",
              ),
              subtitle: TextField(
                enabled: false,
                key: const Key('profile_email'),
                keyboardType: TextInputType.emailAddress,
                controller: email,
                decoration: InputDecoration(
                  hintText: "usuario@spskills.com.br",
                ),
              ),
            ),
            ListTile(
              enabled: editing,
              contentPadding: EdgeInsets.all(0),
              title: Text(style: TextStyle(fontSize: 14), "Nome Completo"),
              subtitle: TextField(
                key: const Key('profile_name'),
                enabled: editing,
                keyboardType: TextInputType.name,
                controller: name,
                decoration: InputDecoration(hintText: "ex: João Silva"),
              ),
            ),

            ListTile(
              contentPadding: EdgeInsets.all(0),
              enabled: editing,
              title: Text(style: TextStyle(fontSize: 14), "Data Nascimento"),
              subtitle: TextField(
                key: const Key('profile_date'),
                enabled: editing,
                keyboardType: TextInputType.datetime,
                controller: date,
                onTap: () async {
                  if (!editing) return;

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
              enabled: editing,
              contentPadding: EdgeInsets.all(0),
              title: Text(style: TextStyle(fontSize: 14), "Nome Usuário"),
              subtitle: TextField(
                key: const Key('profile_user'),
                enabled: editing,
                keyboardType: TextInputType.name,
                controller: user,
                decoration: InputDecoration(hintText: "@SeuUsuário"),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              title: Text(style: TextStyle(fontSize: 14), "Modalidade"),
              subtitle: DropdownButton(
                key: const Key('profile_modality'),
                items: [
                  ...(widget.data['modalidades'] as List).map(
                    (e) => DropdownMenuItem(
                      value: e['nome'].toString(),
                      child: Text(e['nome'].toString()),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (!editing) return;

                  setState(() {
                    selectedM = value!;
                  });
                },
                value: selectedM,
              ),
            ),
            if (editing)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Nova senha"),
                subtitle: TextField(
                  key: const Key('profile_password'),
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Deixe em branco para manter a senha atual",
                  ),
                ),
              ),
            if (editing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    key: const Key('profile_save'),
                    onPressed: () {
                      if (password.text.isNotEmpty &&
                          password.text.length < 6) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "A senha deve possuir no mínimo 6 caracteres",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      meCopy['nome'] = name.text;
                      meCopy['usuario'] = user.text;
                      meCopy['modalidade'] = selectedM;
                      if (password.text.isNotEmpty) {
                        meCopy['senha'] = password.text;
                      }

                      setState(() {
                        editing = false;
                        password.clear();
                      });
                    },
                    child: Text("Salvar Alterações"),
                  ),
                  ElevatedButton(
                    key: const Key('profile_cancel'),
                    onPressed: () {
                      name.text = meCopy['nome'].toString();
                      email.text = meCopy['email'].toString();
                      date.text = meCopy['data_nascimento'].toString();
                      user.text = meCopy['usuario'].toString();
                      selectedM = meCopy['modalidade'].toString();
                      password.clear();
                      setState(() {
                        editing = false;
                      });
                    },
                    child: const Text("Cancelar"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
