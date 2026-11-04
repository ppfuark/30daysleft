import 'package:d1_01/pages/cad.dart';
import 'package:d1_01/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Color(0xff003764))),
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
  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Ws Connecta"),
        actions: [Image.asset('assets/ic_launcher.png')],
      ),
      body: Container(
        width: w,
        height: h,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text("Bem-vindo"),
                subtitle: Text("Acesse sua conta para continuar"),
              ),
              TextField(
                key: Key('main_email'),
                keyboardType: TextInputType.emailAddress,
                controller: email,
                decoration: InputDecoration(hintText: "@spskills.com.br"),
              ),
              TextField(
                key: Key('main_pass'),
                keyboardType: TextInputType.visiblePassword,
                controller: pass,
                obscureText: obs,
                decoration: InputDecoration(
                  hintText: "Digite sua senha",
                  suffixIcon: IconButton(
                    onPressed: () => setState(() {
                      obs = !obs;
                    }),
                    icon: Icon(obs ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (email.text.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "O e-mail da São Paulo Skills é obrigatório",
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }
                  if (!(RegExp(r'^[a-z0-9A-Z\.]+@spskills.com.br$')
                      .hasMatch(email.text))) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Utilize seu e-mail institucional @spskills.com.br",
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }
                  if (pass.text.isEmpty) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("A senha é obrigatória"),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }

                  final exist = (data['usuarios'] as List).where(
                    (element) =>
                        element['email'] == email.text &&
                        element['senha'] == pass.text,
                  );

                  if (exist.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Home(data: data, me: exist.first['id']),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Credenciais inválidas. Verifique seu e-mail e senha.",
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                    return;
                  }
                },
                child: Text("Entrar"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Não possui conta?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Cad(data: data),
                        ),
                      );
                    },
                    child: Text("Cadastre-se aqui"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final Map<String, List<Map<String, dynamic>>> data = {
  "usuarios": [
    {
      "id": 1,
      "nome": "Competidor Exemplo",
      "email": "competidor.exemplo@spskills.com.br",
      "senha": "MinhaSenhaForte123",
      "usuario": "competidor.master",
      "data_nascimento": "2006-05-12",
      "modalidade": "Desenvolvimento de Aplicativos Móveis",
      "amigos": [2, 3, 4],
    },
    {
      "id": 2,
      "nome": "Mariana Costa",
      "email": "mariana.costa@spskills.com.br",
      "senha": "UserPass@2026",
      "usuario": "mari.web",
      "data_nascimento": "2007-08-20",
      "modalidade": "Tecnologia Web",
      "amigos": [1, 5],
    },
    {
      "id": 3,
      "nome": "Ricardo Ferreira",
      "email": "ricardo.ferreira@spskills.com.br",
      "senha": "Security#99",
      "usuario": "ricardo.cyber",
      "data_nascimento": "2005-03-15",
      "modalidade": "Segurança Cibernética",
      "amigos": [1, 4],
    },
    {
      "id": 4,
      "nome": "Beatriz Souza",
      "email": "beatriz.souza@spskills.com.br",
      "senha": "Design@Strong",
      "usuario": "bia.design",
      "data_nascimento": "2008-11-10",
      "modalidade": "Tecnologia em Design Gráfico",
      "amigos": [1, 3, 5],
    },
    {
      "id": 5,
      "nome": "Gabriel Santos",
      "email": "gabriel.santos@spskills.com.br",
      "senha": "Electro!2026",
      "usuario": "gabs.eletronica",
      "data_nascimento": "2006-01-25",
      "modalidade": "Eletrônica",
      "amigos": [2, 4],
    },
  ],
  "modalidades": [
    {"id": 1, "nome": "Controle Industrial"},
    {"id": 2, "nome": "Desenho Mecânico em CAD"},
    {"id": 3, "nome": "Eletrônica"},
    {"id": 4, "nome": "Fresagem a CNC"},
    {"id": 5, "nome": "Indústria 4.0"},
    {"id": 6, "nome": "Integração de Sistemas Robóticos"},
    {"id": 7, "nome": "Manufatura Aditiva"},
    {"id": 8, "nome": "Desenvolvimento de Aplicativos Móveis"},
    {"id": 9, "nome": "Mecatrônica"},
    {"id": 10, "nome": "Robótica Móvel Autônoma"},
    {"id": 11, "nome": "Soldagem"},
    {"id": 12, "nome": "Tecnologia da Água"},
    {"id": 13, "nome": "Tornearia a CNC"},
    {"id": 14, "nome": "Tecnologia Química Laboratorial"},
    {"id": 15, "nome": "Tecnologia em Design Industrial"},
    {"id": 16, "nome": "Tecnologia Optoeletrônica"},
    {"id": 17, "nome": "Tecnologias de Energias Verdes"},
    {"id": 18, "nome": "Computação em Nuvem"},
    {"id": 19, "nome": "Desenvolvimentos de Aplicativos Móveis"},
    {"id": 20, "nome": "Redes de Cabeamento Estruturados"},
    {"id": 21, "nome": "Segurança Cibernética"},
    {"id": 22, "nome": "Sistema de Gestão de Redes"},
    {"id": 23, "nome": "Soluções em Softwares para Negócios"},
    {"id": 24, "nome": "Tecnologia Web"},
    {"id": 25, "nome": "Funilaria Automotiva"},
    {"id": 26, "nome": "Logística & Envios Internacionais"},
    {"id": 27, "nome": "Manutenção Aeronáutica"},
    {"id": 28, "nome": "Pintura Automotiva"},
    {"id": 29, "nome": "Tecnologia Automotiva"},
    {"id": 30, "nome": "Tecnologia de Veículos Ferroviários"},
    {"id": 31, "nome": "Tecnologia de Veículos Pesados"},
    {"id": 32, "nome": "Confeitaria"},
    {"id": 33, "nome": "Panificação"},
    {"id": 34, "nome": "Arte Digital 3D para Jogos"},
    {"id": 35, "nome": "Joalheria"},
    {"id": 36, "nome": "Tecnologia da Moda"},
    {"id": 37, "nome": "Tecnologia em Design Gráfico"},
    {"id": 38, "nome": "Visual Merchandising"},
    {"id": 39, "nome": "Carpintaria"},
    {"id": 40, "nome": "Construção Digital - BIM"},
    {"id": 41, "nome": "Construção de Espaços Verdes"},
    {"id": 42, "nome": "Construção em Alvenaria"},
    {"id": 43, "nome": "Construções em Concreto"},
    {"id": 44, "nome": "Instalações Elétricas"},
    {"id": 45, "nome": "Instalações Hidráulicas e de Aquecimento"},
    {"id": 46, "nome": "Marcenaria de Estruturas"},
    {"id": 47, "nome": "Movelaria"},
    {"id": 48, "nome": "Pintura Decorativa"},
    {"id": 49, "nome": "Revestimentos Cerâmicos"},
    {"id": 50, "nome": "Sistemas de Refrigeração"},
    {"id": 51, "nome": "Sistemas Drywall"},
  ],
  "posts": [
    {
      "id": 1,
      "usuario_id": 1,
      "texto": "Preparando para a São Paulo Skills! #DevSkills #Foco",
      "tags": ["#DevSkills", "#Foco"],
      "imagem": "media-files/posts/post_01.png",
      "likes": 24,
      "data_publicacao": "2026-05-12T10:00:00Z",
    },
    {
      "id": 2,
      "usuario_id": 2,
      "texto": "Finalizando o layout responsivo do projeto! 🚀",
      "tags": ["#WebDesign", "#Responsive"],
      "imagem": "media-files/posts/post_02.png",
      "likes": 18,
      "data_publicacao": "2026-05-12T11:30:00Z",
    },
    {
      "id": 3,
      "usuario_id": 3,
      "texto":
          "Testando cenários de invasão simulada no laboratório de redes hoje.",
      "tags": ["#CyberSecurity", "#PenTest"],
      "imagem": "media-files/posts/post_03.png",
      "likes": 31,
      "data_publicacao": "2026-05-12T13:15:00Z",
    },
    {
      "id": 4,
      "usuario_id": 4,
      "texto": "Explorando novas paletas de cores para o próximo projeto gráfico. 🎨",
      "tags": ["#Design", "#Criatividade"],
      "imagem": "media-files/posts/post_04.png",
      "likes": 42,
      "data_publicacao": "2026-05-12T14:45:00Z",
    },
    {
      "id": 5,
      "usuario_id": 5,
      "texto": "Montagem de circuito concluída, hora de calibrar os sensores!",
      "tags": ["#Eletronica", "#Hardware"],
      "imagem": "media-files/posts/post_05.png",
      "likes": 15,
      "data_publicacao": "2026-05-12T16:00:00Z",
    },
    {
      "id": 6,
      "usuario_id": 1,
      "texto": "Revisando os casos de teste antes da entrega final do módulo.",
      "tags": ["#QA", "#MobileDev"],
      "imagem": "media-files/posts/post_06.png",
      "likes": 9,
      "data_publicacao": "2026-05-13T09:20:00Z",
    },
    {
      "id": 7,
      "usuario_id": 2,
      "texto":
          "Publicando o novo componente reutilizável no repositório do time.",
      "tags": ["#FrontEnd", "#OpenSource"],
      "imagem": "media-files/posts/post_07.png",
      "likes": 27,
      "data_publicacao": "2026-05-13T10:50:00Z",
    },
    {
      "id": 8,
      "usuario_id": 3,
      "texto": "Configurando firewall e políticas de acesso para o desafio de amanhã.",
      "tags": ["#RedesDeSeguranca", "#Firewall"],
      "imagem": "media-files/posts/post_08.png",
      "likes": 12,
      "data_publicacao": "2026-05-13T12:05:00Z",
    },
    {
      "id": 9,
      "usuario_id": 4,
      "texto":
          "Protótipo de identidade visual pronto para apresentação da banca.",
      "tags": ["#Branding", "#Portfolio"],
      "imagem": "media-files/posts/post_09.png",
      "likes": 36,
      "data_publicacao": "2026-05-13T15:30:00Z",
    },
    {
      "id": 10,
      "usuario_id": 5,
      "texto":
          "Soldando os últimos componentes da placa antes dos testes finais.",
      "tags": ["#Eletronica", "#Soldagem"],
      "imagem": "media-files/posts/post_10.png",
      "likes": 20,
      "data_publicacao": "2026-05-13T17:10:00Z",
    },
  ],
};
