import 'package:d1_01/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    Future<void> tapVisible(Finder finder, {bool? wait}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.tap(finder);
      await tester.pumpAndSettle(
        wait ?? true ? Duration(seconds: 1) : Duration(seconds: 1),
      );
    }

    Future<void> enterVisible(Finder finder, String text, {bool? wait}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.enterText(finder, text);
      await tester.pumpAndSettle(
        wait ?? true ? Duration(seconds: 1) : Duration(seconds: 1),
      );
    }

    print('1');
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 5));

    print('2');
    await tapVisible(find.widgetWithText(ElevatedButton, "Entrar"));

    print('3');
    await enterVisible(
      find.byKey(Key('log_email')),
      "aluno@email.com",
      wait: false,
    );
    await tapVisible(find.widgetWithText(ElevatedButton, "Entrar"));

    print('4');
    await enterVisible(
      find.byKey(Key('log_email')),
      "aluno@spskills.com.br",
      wait: false,
    );
    await tapVisible(find.widgetWithText(ElevatedButton, "Entrar"));

    print('5');
    await enterVisible(find.byKey(Key('log_pass')), "senhaErrada", wait: false);
    await tapVisible(find.widgetWithText(ElevatedButton, "Entrar"));

    print('6');
    await enterVisible(
      find.byKey(Key('log_email')),
      "competidor.exemplo@spskills.com.br",
    );
    await enterVisible(
      find.byKey(Key('log_pass')),
      "MinhaSenhaForte123",
      wait: false,
    );
    await tapVisible(find.widgetWithText(ElevatedButton, "Entrar"));

    print('7');
    await tapVisible(
      find.widgetWithIcon(IconButton, Icons.arrow_back),
      wait: false,
    );
    await tapVisible(
      find.widgetWithText(TextButton, "Não possui conta? Cadastre-se aqui"),
    );

    print('8');
    await tapVisible(find.widgetWithText(ElevatedButton, "Cadastrar"));

    print('9');
    await enterVisible(find.byKey(Key('cad_user')), "@JoaoSkillsDev");

    print('10');
    await enterVisible(find.byKey(Key('cad_pass1')), "skill", wait: false);
    await tapVisible(find.widgetWithText(ElevatedButton, "Cadastrar"));

    print('11');
    await enterVisible(
      find.byKey(Key('cad_pass1')),
      "SPskills2026",
      wait: false,
    );
    await enterVisible(
      find.byKey(Key('cad_pass2')),
      "Skills2026SP",
      wait: false,
    );
    await tapVisible(find.widgetWithText(ElevatedButton, "Cadastrar"));

    // print('15');
    await enterVisible(
      find.byKey(Key('cad_pass1')),
      "SPskills2026",
      wait: false,
    );
    await enterVisible(
      find.byKey(Key('cad_pass2')),
      "SPskills2026",
      wait: false,
    );
    // await tapVisible(find.byKey(Key('cad_drop')));

    // print('16');
    // await tester.tap(find.text("Desenvolvimento de Aplicativos Móveis"));

    print('17');
    await enterVisible(find.byKey(Key('cad_nome')), "João Silva", wait: false);
    await enterVisible(
      find.byKey(Key('cad_email')),
      "joao.silva@spskills.com.br",
      wait: false,
    );
    await tapVisible(find.widgetWithText(ElevatedButton, "Cadastrar"));

    print("18");
    await tapVisible(find.widgetWithText(IconButton, "X"));

    print('19');
    await enterVisible(
      find.byKey(Key('log_email')),
      "joao.silva@spskills.com.br",
      wait: false,
    );
    await enterVisible(
      find.byKey(Key('log_pass')),
      "SPskills2026",
      wait: false,
    );
    await tapVisible(find.widgetWithText(ElevatedButton, "Entrar"));

    print("20");
    await tapVisible(find.byKey(Key('home_tog')));

    print("21");
    await tapVisible(find.byKey(Key('home_tog')));

    print("22");
    await tapVisible(find.byKey(Key('like_1')));

    print("23");
    await tapVisible(find.byKey(Key('home_float')));

    print("24");
    await tapVisible(find.widgetWithText(TextButton, "Descartar"));

    print("25");
    await tapVisible(find.widgetWithText(TextButton, "Não"));

    print("26");
    await tapVisible(find.widgetWithText(ElevatedButton, "Publicar"));

    print('27');
    await enterVisible(find.byKey(Key('new_text')), "a" * 350, wait: false);
    await tapVisible(find.widgetWithText(ElevatedButton, "Publicar"));

    print('28');
    await enterVisible(find.byKey(Key('new_tag')), "a" * 51, wait: false);
    await tapVisible(find.widgetWithText(ElevatedButton, "Publicar"));

    print('29');
    await enterVisible(
      find.byKey(Key('new_text')),
      "Preparando para a São Paulo Skills!",
    );

    print('30');
    await enterVisible(find.byKey(Key('new_tag')), "#Mobile");

    print("31");
    await tapVisible(find.widgetWithText(ElevatedButton, "Publicar"));

    print("32");
    await tapVisible(find.widgetWithIcon(IconButton, Icons.person));

    print("33");
    await tapVisible(find.widgetWithIcon(IconButton, Icons.edit));

    print('34');
    await enterVisible(
      find.byKey(Key('profile_email')),
      "Preparando para a São Paulo Skills!",
    );
    
    print('37');
    await enterVisible(find.byKey(Key('profile_password')), "o");

    print('38');
    await tapVisible(find.widgetWithText(ElevatedButton, "Cancelar"));

    print("39");
    await tapVisible(find.widgetWithIcon(IconButton, Icons.edit), wait: false);
    await tapVisible(find.widgetWithText(ElevatedButton, "Salvar Alterações"));

    print("40");
    await tapVisible(find.byKey(const Key('profile_friends')));

    print("41");
    await tapVisible(find.byKey(const Key('friend_remove_5')));

    print("42");
    await tapVisible(find.byKey(const Key('friends_add')));

    print("43");
    await tapVisible(find.text('Mariana Costa'));

    print("44");
    await tapVisible(find.byKey(const Key('friends_save')));

    print("45");
  });
}
