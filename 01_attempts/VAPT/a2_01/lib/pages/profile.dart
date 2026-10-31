import 'package:a2_01/app.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
        automaticallyImplyLeading: false,
        title: ListTile(
          title: Text(
            "Perfil",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          subtitle: Text("Aparência e avaliações"),
        ),
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Image.network(
                    profile['imagem_real_url'].toString(),
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Icon(Icons.broken_image, size: 90)),
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  ListTile(
                    title: Text(
                      profile['nome_estabelecimento'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber),
                        Text(
                          (avals.fold(
                                    0,
                                    (previousValue, element) =>
                                        previousValue +
                                        (element['avaliacao'] as int),
                                  ) /
                                  avals.length)
                              .toString(),
                        ),

                        Spacer(),
                        Text("${avals.length} Avaliações"),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.receipt),
                    title: Text("CNPJ"),
                    subtitle: Text(
                      profile['informacoes_cadastrais']['cnpj'].toString(),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text("TEL"),
                    subtitle: Text(profile['contato']['telefone'].toString()),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text("E-MAIL"),
                    subtitle: Text(profile['contato']['email'].toString()),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_pin),
                    title: Text("ENDEREÇO"),
                    subtitle: Text(profile['contato']['endereco'].toString()),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.dark_mode_outlined),
                    ),
                    title: Text(
                      "Modo Claro ${App.theme.value == App.dark ? "Desativado" : "Ativado"}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    subtitle: Text("Altere entre os temas"),
                    trailing: Switch(
                      value: App.theme.value == App.dark,
                      onChanged: (value) {
                        setState(() {
                          App.toogle();
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Avaliações de Clientes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final e = avals[index];

                        final left = 5 - (e['avaliacao'] as int);

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(e['nome'].toString()),
                            subtitle: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 0; i < 5 - left; i++)
                                    Icon(Icons.star, color: Colors.amber),
                                  for (int i = 0; i < left; i++)
                                    Icon(Icons.star_border, color: Colors.grey),
                                ],
                              ),
                              subtitle: Text(e['comentario'].toString()),
                            ),
                          ),
                        );
                      },
                      itemCount: avals.length,
                      shrinkWrap: true,
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

final Map<String, dynamic> profile = {
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
