import 'package:a2_01/app.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
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
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Perfil',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Aparência e avaliações',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: Row(
                      // "id_estabelecimento": "8921",
                      // "nome_estabelecimento": "Burger Joint",
                      // "informacoes_cadastrais": {
                      //   "cnpj": "12.345.678/0001-99",
                      //   "razao_social": "Burger Joint Lanches LDA",
                      //   "data_abertura": "2020-05-15",
                      // },
                      // "contato": {
                      //   "telefone": "+55 11 91234-5678",
                      //   "email": "gerencia@burgerjoint.com",
                      //   "endereco": "Rua das Flores, 123 - Centro",
                      // },
                      // "imagem_real_url":
                      //     "https://storage.vaptfood.com/estabelecimentos/8921/capa.jpg",
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  me['imagem_real_url'].toString(),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(child: Icon(Icons.broken_image)),
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  me['nome_estabelecimento'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                  ),
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          (avals.fold(
                                                    0,
                                                    (previousValue, element) =>
                                                        previousValue +
                                                        (element['avaliacao']
                                                            as int),
                                                  ) /
                                                  avals.length)
                                              .toStringAsFixed(1),
                                        ),
                                        Icon(Icons.star, color: Colors.amber),
                                      ],
                                    ),
                                    Text("${avals.length} Avaliações"),
                                  ],
                                ),
                              ),

                              ListTile(
                                leading: Icon(Icons.description),
                                title: Text(
                                  "CNPJ: ${me['informacoes_cadastrais']['cnpj']}",
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.phone),
                                title: Text(
                                  "TEL: ${me['contato']['telefone']}",
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.email),
                                title: Text(
                                  "E-MAIL: ${me['contato']['email']}",
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.location_pin),
                                title: Text(
                                  "ENDEREÇO: ${me['contato']['endereco']}",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.dark_mode),
                                title: Text(
                                  style: TextStyle(fontSize: 40),
                                  "Modo Claro ${App.valueNotifier.value == App.dark ? "Desligado" : "Ativado"}",
                                ),
                                subtitle: Text(
                                  style: TextStyle(fontSize: 20),
                                  "Altere entre os temas",
                                ),
                                trailing: Switch(
                                  value: App.valueNotifier.value == App.dark,
                                  onChanged: (value) {
                                    setState(() {
                                      App.toogle();
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    "Avaliações de Clientes",
                                    style: TextStyle(fontSize: 40),
                                  ),
                                  subtitle: ListView.builder(
                                    itemBuilder: (context, index) {
                                      final c = avals[index];

                                      final filled =
                                          5 - (c['avaliacao'] as int);

                                      return ListTile(
                                        leading: CircleAvatar(
                                          radius: 40,
                                          backgroundImage: AssetImage(
                                            'assets/images/${c['nome'].toString().split(' ').first.toLowerCase().replaceAll('í', "i")}.jpg',
                                          ),
                                        ),
                                        title: Text(c['nome'].toString()),
                                        subtitle: ListTile(
                                          contentPadding: EdgeInsets.all(0),
                                          title: Row(
                                            children: [
                                              for (
                                                int i = 0;
                                                i < 5 - filled;
                                                i++
                                              )
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                              for (int i = 0; i < filled; i++)
                                                Icon(
                                                  Icons.star_border,
                                                  color: Colors.amber,
                                                ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            c['comentario'].toString(),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: avals.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

final dynamic me = {
  "id_estabelecimento": "8921",
  "nome_estabelecimento": "Burger Joint",
  "informacoes_cadastrais": {
    "cnpj": "12.345.678/0001-99",
    "razao_social": "Burger Joint Lanches LDA",
    "data_abertura": "2020-05-15",
  },
  "contato": {
    "telefone": "+55 11 91234-5678",
    "email": "gerencia@burgerjoint.com",
    "endereco": "Rua das Flores, 123 - Centro",
  },
  "imagem_real_url":
      "https://storage.vaptfood.com/estabelecimentos/8921/capa.jpg",
};

final avals = [
  {
    "nome": "Mariana Costa",
    "comentario": "Entrega rápida e comida muito saborosa!",
    "avaliacao": 5,
  },
  {
    "nome": "Carlos Eduardo",
    "comentario": "Pedido chegou quentinho e bem embalado.",
    "avaliacao": 4,
  },
  {
    "nome": "Fernanda Lima",
    "comentario": "Ótimo atendimento e prazo cumprido.",
    "avaliacao": 5,
  },
  {
    "nome": "Bruno Oliveira",
    "comentario": "A comida estava boa, mas demorou um pouco.",
    "avaliacao": 3,
  },
  {
    "nome": "Juliana Alves",
    "comentario": "Experiência excelente. Voltarei a pedir.",
    "avaliacao": 5,
  },
  {
    "nome": "Rafael Mendes",
    "comentario": "Pedido veio correto e muito bem apresentado.",
    "avaliacao": 4,
  },
  {
    "nome": "Patrícia Souza",
    "comentario": "A entrega foi rápida, mas a comida chegou fria.",
    "avaliacao": 2,
  },
  {
    "nome": "Lucas Ferreira",
    "comentario": "Muito saboroso. Recomendo!",
    "avaliacao": 5,
  },
  {
    "nome": "Amanda Silva",
    "comentario": "Bom custo-benefício e entrega dentro do prazo.",
    "avaliacao": 4,
  },
  {
    "nome": "Gustavo Barbosa",
    "comentario": "Atendimento excelente e pedido impecável.",
    "avaliacao": 5,
  },
];
