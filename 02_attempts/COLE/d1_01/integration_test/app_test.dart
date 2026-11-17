import 'package:d1_01/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    Future<void> tapVisible(Finder finder, {bool? wait}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await tester.pumpAndSettle(Durations.medium1);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle(Durations.medium1);
      await tester.tap(finder);
      await tester.pumpAndSettle(
        wait ?? true ? Duration(seconds: 2) : Duration(seconds: 1),
      );
    }

    Future<void> enterVisible(Finder finder, String value, {bool? wait}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await tester.pumpAndSettle(Durations.medium1);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle(Durations.medium1);
      await tester.enterText(finder, value);
      await tester.pumpAndSettle(
        wait ?? true ? Duration(seconds: 2) : Duration(seconds: 1),
      );
    }

    print("1.");
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(seconds: 2));

    print("2.");
    await enterVisible(find.byKey(Key('main_pin')), "12", wait: false);
    await tapVisible(find.text("Entrar"));

    print("3.");
    await enterVisible(find.byKey(Key('main_pin')), "12345", wait: false);
    await tapVisible(find.text("Entrar"));

    print("4.");
    await enterVisible(find.byKey(Key('main_pin')), "9999", wait: false);
    await tapVisible(find.text("Entrar"));

    print("5.");
    await enterVisible(find.byKey(Key('main_pin')), "8888", wait: false);
    await tapVisible(find.text("Entrar"));

    print("6.");
    await enterVisible(find.byKey(Key('main_pin')), "7777", wait: false);
    await tapVisible(find.text("Entrar"));

    print("7.");
    await enterVisible(find.byKey(Key('main_pin')), "1234", wait: false);
    await tapVisible(find.text("Entrar"));

    print("8.");
    await tapVisible(find.text("Coleta Comum"));

    print("12.");
    await tapVisible(find.byKey(Key('comum_check')));

    print("13.");
    await tapVisible(find.byKey(Key('comum_not')));

    print("14.");
    await tapVisible(find.text("Orgânica"));

    print("15.");
    await tapVisible(find.byKey(Key('comum_drop')), wait: false);
    await tapVisible(find.text("Tarde"));

    print("16.");
    await enterVisible(find.byKey(Key('comum_search')), "Rua Xyz 123");

    print("17.");
    await enterVisible(
      find.byKey(Key('comum_search')),
      "Rua Doutor Luiz Miranda",
    );

    print("18.");
    await tapVisible(find.text("Relatório detalhado"));
    await tapVisible(find.text("Fechar"), wait: false);

    print("19.");
    await tapVisible(find.text("Chat com a Prefeitura"));

    print("20.");
    await tapVisible(find.text("Fechar"));

    print("21.");
    await tapVisible(find.byKey(Key('comum_pop')), wait: false);
    await tapVisible(find.text("Coleta Seletiva"));

    print("24.");
    await tapVisible(find.text("Papel"));

    print("25.");
    await tester.pumpAndSettle(Duration(seconds: 2));

    print("27.");
    await tapVisible(find.byKey(Key('delete_35')));

    print("28.");
    await tapVisible(find.text("Start"));

    print("39.");
    await tapVisible(find.byKey(Key('game_trash')));

    print("40.");
    await tester.pumpAndSettle(Duration(seconds: 2));

    print("41.");
    await tapVisible(find.text("Trocar por Benefícioss"));

    print("42.");
    await tester.pumpAndSettle(Duration(seconds: 2));

    print("43.");
    await enterVisible(find.byKey(Key('game_pin')), "12345");

    print("44.");
    await tapVisible(find.text("Trocar por Benefícioss"), wait: false);
    await enterVisible(find.byKey(Key('game_pin')), "1234");

    print("45.");
    await tapVisible(find.byKey(Key('1 Coleta Grátis')));

    print("46.");
    await tapVisible(find.text("Coletar"));

    print("48.");
    await tapVisible(find.byKey(Key('game_pop_home')));
  });
}
