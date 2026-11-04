import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:d1_01/main.dart';

void main() {
  testWidgets('Fluxo de login, cadastro, feed, publicação e perfil', (
    WidgetTester tester,
  ) async {
    Future<void> tapVisible(Finder finder) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.tap(finder);
      await tester.pumpAndSettle(Duration(seconds: 5));
    }

    Future<void> enterVisible(Finder finder, String value) async {
      await tester.ensureVisible(finder);
      await tester.enterText(finder, value);
      await tester.pumpAndSettle(Duration(seconds: 5));
    }

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tapVisible(find.widgetWithText(ElevatedButton, 'Entrar'));
    expect(
      find.text('O e-mail da São Paulo Skills é obrigatório'),
      findsOneWidget,
    );

    await enterVisible(find.byKey(const Key('main_email')), 'aluno@email.com');
    await tapVisible(find.widgetWithText(ElevatedButton, 'Entrar'));
    expect(
      find.text('Utilize seu e-mail institucional @spskills.com.br'),
      findsOneWidget,
    );

    await enterVisible(
      find.byKey(const Key('main_email')),
      'aluno@spskills.com.br',
    );
    await tapVisible(find.widgetWithText(ElevatedButton, 'Entrar'));
    expect(find.text('A senha é obrigatória'), findsOneWidget);

    await enterVisible(find.byKey(const Key('main_pass')), 'senhaErrada');
    await tapVisible(find.widgetWithText(ElevatedButton, 'Entrar'));
    expect(
      find.text('Credenciais inválidas. Verifique seu e-mail e senha.'),
      findsOneWidget,
    );

    await enterVisible(
      find.byKey(const Key('main_pass')),
      'MinhaSenhaForte123',
    );
    await enterVisible(
      find.byKey(const Key('main_email')),
      'competidor.exemplo@spskills.com.br',
    );
    await tapVisible(find.widgetWithText(ElevatedButton, 'Entrar'));
    expect(find.text('Comunidade'), findsOneWidget);

    await tapVisible(find.byKey(const Key('home_pop')));
    await tapVisible(find.text('Cadastre-se aqui'));

    await tapVisible(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    expect(find.text('O Nome de Usuário é obrigatório'), findsOneWidget);

    await enterVisible(find.byKey(const Key('cad_user')), '@JoaoSkillsDev');
    final usernameField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(const Key('cad_user')),
        matching: find.byType(TextField),
      ),
    );
    expect(usernameField.controller!.text, 'JoaoSkillsDev');
    await tapVisible(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    expect(
      find.text('A senha deve possuir no mínimo 6 caracteres'),
      findsOneWidget,
    );

    await enterVisible(find.byKey(const Key('cad_pass1')), 'skill');
    await enterVisible(find.byKey(const Key('cad_pass2')), 'skill');
    await tapVisible(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    expect(
      find.text('A senha deve possuir no mínimo 6 caracteres'),
      findsOneWidget,
    );

    await enterVisible(find.byKey(const Key('cad_pass1')), 'SPskills2026');
    await enterVisible(find.byKey(const Key('cad_pass2')), 'Skills2026SP');
    await tapVisible(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    expect(find.text('As senhas não coincidem'), findsOneWidget);

    await enterVisible(find.byKey(const Key('cad_nome')), 'João Silva');
    await enterVisible(find.byKey(const Key('cad_pass1')), 'SPskills2026');
    await enterVisible(find.byKey(const Key('cad_pass2')), 'SPskills2026');
    await enterVisible(
      find.byKey(const Key('cad_email')),
      'joao.silva@spskills.com.br',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tapVisible(find.byKey(const Key('cad_modal_dropdown')));
    await tapVisible(find.text('Desenvolvimento de Aplicativos Móveis'));
    expect(find.text('Desenvolvimento de Aplicativos Móveis'), findsOneWidget);
    await tapVisible(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    expect(
      find.text('Cadastro realizado com sucesso! Faça seu login.'),
      findsOneWidget,
    );

    await enterVisible(
      find.byKey(const Key('main_email')),
      'joao.silva@spskills.com.br',
    );
    await enterVisible(find.byKey(const Key('main_pass')), 'SPskills2026');
    await tapVisible(find.widgetWithText(ElevatedButton, 'Entrar'));
    expect(find.text('Comunidade'), findsOneWidget);

    await tapVisible(find.byKey(const Key('home_grid')));
    await tapVisible(find.byKey(const Key('home_list')));
    await tapVisible(find.byKey(const Key('home_like_0')));
    await tapVisible(find.byType(FloatingActionButton));

    await tapVisible(find.text('Descartar'));
    expect(find.text('Deseja descartar este post?'), findsOneWidget);
    await tapVisible(find.text('Não'));
    expect(find.text('Novo Post'), findsOneWidget);

    await tapVisible(find.byKey(const Key('new_publish')));
    expect(
      find.text(
        'Sua publicação não pode estar vazia. Adicione texto ou imagem.',
      ),
      findsOneWidget,
    );

    await enterVisible(find.byKey(const Key('new_text')), 'x' * 350);
    await tapVisible(find.byKey(const Key('new_publish')));
    expect(find.text('Limite de caracteres excedido (300)'), findsOneWidget);

    await enterVisible(find.byKey(const Key('new_text')), '');
    await enterVisible(find.byKey(const Key('new_tag')), 'x' * 51);
    await tapVisible(find.byKey(const Key('new_publish')));
    expect(
      find.text('Tag superior à 50 caracteres, insira outra tag!'),
      findsOneWidget,
    );

    await enterVisible(find.byKey(const Key('new_tag')), '#Mobile');
    await tapVisible(find.byKey(const Key('new_tag_add')));
    expect(find.text('#Mobile'), findsOneWidget);
    await enterVisible(
      find.byKey(const Key('new_text')),
      'Preparando para a São Paulo Skills!',
    );
    await tapVisible(find.byKey(const Key('new_publish')));
    expect(find.text('Publicação enviada com sucesso!'), findsOneWidget);
    expect(find.text('Comunidade'), findsOneWidget);

    await tapVisible(find.byKey(const Key('home_profile')));
    expect(find.text('Perfil'), findsOneWidget);
    await tapVisible(find.byKey(const Key('profile_edit')));
    expect(
      tester.widget<TextField>(find.byKey(const Key('profile_email'))).readOnly,
      isTrue,
    );

    await enterVisible(find.byKey(const Key('profile_password')), '12345');
    await tapVisible(find.byKey(const Key('profile_save')));
    expect(
      find.text('A senha deve possuir no mínimo 6 caracteres'),
      findsOneWidget,
    );

    await enterVisible(
      find.byKey(const Key('profile_name')),
      'Nome descartado',
    );
    await tapVisible(find.byKey(const Key('profile_cancel')));
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('profile_name')))
          .controller!
          .text,
      'João Silva',
    );

    await tapVisible(find.byKey(const Key('profile_edit')));
    await enterVisible(
      find.byKey(const Key('profile_name')),
      'João Atualizado',
    );
    await enterVisible(find.byKey(const Key('profile_user')), 'JoaoSkills');
    await tapVisible(find.byKey(const Key('profile_save')));
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('profile_name')))
          .controller!
          .text,
      'João Atualizado',
    );

    await tapVisible(find.byKey(const Key('profile_friends')));
    expect(find.text('Meus Amigos'), findsOneWidget);
    await tapVisible(find.byKey(const Key('friends_add')));
    await tapVisible(find.text('Gabriel Santos'));
    expect(find.byKey(const Key('friend_5')), findsOneWidget);
    await tapVisible(find.byKey(const Key('friends_cancel')));
    expect(find.text('Perfil'), findsOneWidget);

    await tapVisible(find.byKey(const Key('profile_friends')));
    expect(find.byKey(const Key('friend_5')), findsNothing);
    await tapVisible(find.byKey(const Key('friends_add')));
    await tapVisible(find.text('Gabriel Santos'));
    await tapVisible(find.byKey(const Key('friends_save')));
    expect(
      tester.widget<Text>(find.byKey(const Key('profile_friend_count'))).data,
      '1',
    );

    await tapVisible(find.byKey(const Key('profile_friends')));
    await tapVisible(find.byKey(const Key('friend_remove_5')));
    expect(find.byKey(const Key('friend_5')), findsNothing);
    await tapVisible(find.byKey(const Key('friends_add')));
    await tapVisible(find.text('Mariana Costa'));
    await tapVisible(find.byKey(const Key('friends_save')));
    expect(
      tester.widget<Text>(find.byKey(const Key('profile_friend_count'))).data,
      '1',
    );
  });
}
