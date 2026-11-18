import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:d1_01/pages/home.dart';
import 'package:flutter/material.dart';
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
  final key = GlobalKey<NavigatorState>();

  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((event) {
      if (event.contains(ConnectivityResult.none)) {
        ScaffoldMessenger.of(key.currentContext!).showSnackBar(
          SnackBar(
            content: Text(
              "Sem conexão com internet. Autentiação e criação de posts não serão realizado.",
            ),
            duration: Duration(days: 099),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      key: key,
      theme: ThemeData(
        textTheme: GoogleFonts.inriaSansTextTheme(),
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
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

  final email = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;

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
            body: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Ws Conenecta"),
              actions: [Image.asset('assets/ic_launcher.png')],
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
                  ListTile(
                    title: Text("Bem-vindo"),
                    subtitle: Text("Acesse sua conta para continuar"),
                  ),
                  ListTile(
                    title: Text("E-mail"),
                    subtitle: TextField(
                      key: Key('log_email'),
                      controller: email,
                      decoration: InputDecoration(hintText: "@spskills.com.br"),
                    ),
                  ),
                  ListTile(
                    title: Text("Senha"),
                    subtitle: TextField(
                      obscureText: obs,
                      key: Key('log_pass'),
                      controller: pass,
                      decoration: InputDecoration(
                        hintText: "Digite sua senha",
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obs = !obs;
                            });
                          },
                          icon: Icon(
                            obs ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (email.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'O e-mail da São Paulo Skills é obrigatório',
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (!email.text.contains('@spskills.com.br')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Utilize seu e-mail institucional @spskills.com.br',
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (pass.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('A senha é obrigatória'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Credenciais inválidas. Verifique seu e-mail e senha.',
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Text("Entrar"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cadastro(data: data),
                            ),
                          );
                        },
                        child: Text("Não possui conta? Cadastre-se aqui"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

class Cadastro extends StatefulWidget {
  final Map<String, dynamic> data;
  const Cadastro({super.key, required this.data});
  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> with TickerProviderStateMixin {
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

  final nome = TextEditingController();
  final email = TextEditingController();
  final born = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  bool obs = true;
  final pass1 = TextEditingController();
  bool obs1 = true;
  final date = TextEditingController();
  String selectedM = "Tecnologia Web";

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
                icon: Text("X"),
                key: Key('cad_back'),
              ),
              title: Text("Novo Competidor"),
            ),
            body: Container(
              width: w,
              height: h,
              decoration: BoxDecoration(),
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Text("Crie sua conta"),
                      subtitle: Text(
                        "Preencha os dados abaixo para se cadastrar na plataforma.",
                      ),
                    ),
                    ListTile(
                      key: Key('cad_nome'),
                      title: Text("Nome Completo"),
                      subtitle: TextField(
                        controller: nome,
                        decoration: InputDecoration(hintText: "ex: João Silva"),
                      ),
                    ),
                    ListTile(
                      key: Key('cad_pass1'),

                      title: Text("Senha"),
                      subtitle: TextField(
                        obscureText: obs,
                        controller: pass,
                        decoration: InputDecoration(
                          hintText: "Digite sua senha",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obs = !obs;
                              });
                            },
                            icon: Icon(
                              obs ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      key: Key('cad_pass2'),

                      title: Text("Confirmar Senha"),
                      subtitle: TextField(
                        obscureText: obs1,
                        controller: pass1,
                        decoration: InputDecoration(
                          hintText: "Repita a sua senha",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obs1 = !obs1;
                              });
                            },
                            icon: Icon(
                              obs1 ? Icons.visibility : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      key: Key('cad_email'),

                      title: Text("E-mail institucional"),
                      subtitle: TextField(
                        controller: email,
                        decoration: InputDecoration(
                          hintText: "usuario@spskills.com.br",
                        ),
                      ),
                    ),
                    ListTile(
                      key: Key('cad_date'),

                      title: Text("Data Nascimento"),
                      subtitle: TextField(
                        controller: date,
                        decoration: InputDecoration(),
                      ),
                    ),
                    ListTile(
                      key: Key('cad_user'),

                      title: Text("Nome Usuário"),
                      subtitle: TextField(
                        controller: user,
                        decoration: InputDecoration(hintText: "@SeuUsuário"),
                      ),
                    ),
                    ListTile(
                      title: Text("Modalidades"),
                      subtitle: DropdownButton(
                        key: Key('cad_drop'),
                        items: [
                          ...(widget.data['modalidades'] as List).map(
                            (e) => DropdownMenuItem(
                              value: e['nome'].toString(),
                              child: Text(e['nome'].toString()),
                            ),
                          ),
                        ],
                        value: selectedM,
                        onChanged: (value) {
                          setState(() {
                            selectedM = value!;
                          });
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (user.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('O Nome de Usuário é obrigatório'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                        if (pass.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'A senha deve possuir no mínimo 6 caracteres.',
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                        if (pass.text != pass1.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('As senhas não coincidem.'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cadastro realizado com sucesso! Faça seu login.',
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        setState(() {
                          (widget.data['usuarios']
                                  as List<Map<String, dynamic>>)
                              .add({
                                "amigos": [],
                                "data_nascimento": "2006-05-12",
                                "email": email.text,
                                "id": widget.data['usuarios'].length + 1,
                                "modalidade": selectedM,
                                "nome": nome.text,
                                "senha": pass.text,
                                "usuario": user.text,
                              });
                        });
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

final Map<String, List<Map<String, dynamic>>> data = {
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
      "data_publicacao": "2026-05-12T10:00:00Z",
      "id": 1,
      "imagem": "media-files/posts/post_01.png",
      "likes": 24,
      "tags": ["#DevSkills", "#Foco"],
      "texto": "Preparando para a São Paulo Skills! #DevSkills #Foco",
      "usuario_id": 1,
    },
    {
      "data_publicacao": "2026-05-12T11:30:00Z",
      "id": 2,
      "imagem": "media-files/posts/post_02.png",
      "likes": 18,
      "tags": ["#WebDesign", "#Responsive"],
      "texto": "Finalizando o layout responsivo do projeto! 🚀",
      "usuario_id": 2,
    },
    {
      "data_publicacao": "2026-05-12T13:15:00Z",
      "id": 3,
      "imagem": "media-files/posts/post_03.png",
      "likes": 31,
      "tags": ["#CyberSecurity", "#PenTest"],
      "texto":
          "Testando cenários de invasão simulada no laboratório de redes hoje.",
      "usuario_id": 3,
    },
    {
      "data_publicacao": "2026-05-12T14:45:00Z",
      "id": 4,
      "imagem": "media-files/posts/post_04.png",
      "likes": 42,
      "tags": ["#Design", "#Criatividade"],
      "texto":
          "Explorando novas paletas de cores para o próximo projeto gráfico. 🎨",
      "usuario_id": 4,
    },
    {
      "data_publicacao": "2026-05-12T16:00:00Z",
      "id": 5,
      "imagem": "media-files/posts/post_05.png",
      "likes": 15,
      "tags": ["#Eletronica", "#Hardware"],
      "texto": "Montagem de circuito concluída, hora de calibrar os sensores!",
      "usuario_id": 5,
    },
    {
      "data_publicacao": "2026-05-13T09:20:00Z",
      "id": 6,
      "imagem": "media-files/posts/post_06.png",
      "likes": 9,
      "tags": ["#QA", "#MobileDev"],
      "texto": "Revisando os casos de teste antes da entrega final do módulo.",
      "usuario_id": 1,
    },
    {
      "data_publicacao": "2026-05-13T10:50:00Z",
      "id": 7,
      "imagem": "media-files/posts/post_07.png",
      "likes": 27,
      "tags": ["#FrontEnd", "#OpenSource"],
      "texto":
          "Publicando o novo componente reutilizável no repositório do time.",
      "usuario_id": 2,
    },
    {
      "data_publicacao": "2026-05-13T12:05:00Z",
      "id": 8,
      "imagem": "media-files/posts/post_08.png",
      "likes": 12,
      "tags": ["#RedesDeSeguranca", "#Firewall"],
      "texto":
          "Configurando firewall e políticas de acesso para o desafio de amanhã.",
      "usuario_id": 3,
    },
    {
      "data_publicacao": "2026-05-13T15:30:00Z",
      "id": 9,
      "imagem": "media-files/posts/post_09.png",
      "likes": 36,
      "tags": ["#Branding", "#Portfolio"],
      "texto":
          "Protótipo de identidade visual pronto para apresentação da banca.",
      "usuario_id": 4,
    },
    {
      "data_publicacao": "2026-05-13T17:10:00Z",
      "id": 10,
      "imagem": "media-files/posts/post_10.png",
      "likes": 20,
      "tags": ["#Eletronica", "#Soldagem"],
      "texto":
          "Soldando os últimos componentes da placa antes dos testes finais.",
      "usuario_id": 5,
    },
  ],
  "usuarios": [
    {
      "amigos": [2, 3, 4],
      "data_nascimento": "2006-05-12",
      "email": "competidor.exemplo@spskills.com.br",
      "id": 1,
      "modalidade": "Desenvolvimento de Aplicativos Móveis",
      "nome": "Competidor Exemplo",
      "senha": "MinhaSenhaForte123",
      "usuario": "competidor.master",
    },
    {
      "amigos": [1, 5],
      "data_nascimento": "2007-08-20",
      "email": "mariana.costa@spskills.com.br",
      "id": 2,
      "modalidade": "Tecnologia Web",
      "nome": "Mariana Costa",
      "senha": "UserPass@2026",
      "usuario": "mari.web",
    },
    {
      "amigos": [1, 4],
      "data_nascimento": "2005-03-15",
      "email": "ricardo.ferreira@spskills.com.br",
      "id": 3,
      "modalidade": "Segurança Cibernética",
      "nome": "Ricardo Ferreira",
      "senha": "Security#99",
      "usuario": "ricardo.cyber",
    },
    {
      "amigos": [1, 3, 5],
      "data_nascimento": "2008-11-10",
      "email": "beatriz.souza@spskills.com.br",
      "id": 4,
      "modalidade": "Tecnologia em Design Gráfico",
      "nome": "Beatriz Souza",
      "senha": "Design@Strong",
      "usuario": "bia.design",
    },
    {
      "amigos": [2, 4],
      "data_nascimento": "2006-01-25",
      "email": "gabriel.santos@spskills.com.br",
      "id": 5,
      "modalidade": "Eletrônica",
      "nome": "Gabriel Santos",
      "senha": "Electro!2026",
      "usuario": "gabs.eletronica",
    },
  ],
};
