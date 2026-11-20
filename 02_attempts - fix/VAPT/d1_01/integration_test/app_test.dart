import 'package:d1_01/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('', (WidgetTester tester) async {
    Future<void> tapVisible(Finder finder, {bool? wait}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.tap(finder);
      await tester.pumpAndSettle(Duration(seconds: wait ?? true ? 1 : 1));
    }

    Future<void> enterVisible(Finder finder, String value, {bool? wait}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle(Duration(seconds: 1));
      await tester.enterText(finder, value);
      await tester.pumpAndSettle(Duration(seconds: wait ?? true ? 1 : 1));
    }

    Future<void> tapVisible2(Finder finder, {bool? wait}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await tester.pump(Duration(seconds: 1));
      await tester.ensureVisible(finder);
      await tester.pump(Duration(seconds: 1));
      await tester.tap(finder);
      await tester.pump(Duration(seconds: wait ?? true ? 1 : 1));
    }

    Future<void> enterVisible2(
      Finder finder,
      String value, {
      bool? wait,
    }) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await tester.pump(Duration(seconds: 1));
      await tester.ensureVisible(finder);
      await tester.pump(Duration(seconds: 1));
      await tester.enterText(finder, value);
      await tester.pump(Duration(seconds: wait ?? true ? 1 : 1));
    }

    print('1.');
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    // print('2.');
    // await enterVisible(find.byKey(Key("log_email")), "A@a.com");

    // print('3.');
    // await enterVisible(find.byKey(Key("log_pass")), "123");

    // print("4.");
    // await tapVisible(find.text("Entrar"));

    // print("5.");
    // await tapVisible(find.text("Entrar"));

    // print("6.");
    // await tapVisible(find.text("Entrar"));

    // print("7.");
    // await tapVisible(find.text("Esqueci minha senha"));

    // print("8.");
    // await tapVisible(find.text("Ok!"));

    // print("9.");
    // await tapVisible(find.text("Fale com o suporte"));

    // print("10.");
    // await tapVisible(find.text("Ok!"));

    // print('11.');
    // await enterVisible(
    //   find.byKey(Key("log_email")),
    //   "@claudio123",
    //   wait: false,
    // );
    // await tapVisible(find.text("Entrar"));

    print('12.');
    await enterVisible(find.byKey(Key("log_email")), "gerente@vaptfood.com.br");

    print('13.');
    await enterVisible(find.byKey(Key("log_pass")), "Vapt@2026");

    print("14.");
    await tapVisible2(find.text("Entrar"), wait: false);
    await tester.pump(Duration(seconds: 4));

    print('15.');
    await enterVisible2(find.byKey(Key("home_search")), "Mariana");
    await tapVisible2(find.byKey(Key('home_clear')), wait: false);

    print('16.');
    await enterVisible2(find.byKey(Key("home_search")), "G");

    print("17.");
    await tapVisible2(find.byKey(Key('home_clear')));

    print("18.");
    final card = find.byKey(Key("87234"));
    final column = find.text("Pedidos Recentes");
    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(Duration(seconds: 1));
    await gesture.moveTo(tester.getCenter(column));
    await tester.pump(Duration(seconds: 1));
    await gesture.up();
    await tester.pump(Duration(milliseconds: 1000));

    print("19.");
    await tapVisible2(find.byKey(Key('main_1')));

    print('20.');
    await enterVisible(find.byKey(Key("ord_search")), "87234");

    print('21.');
    await enterVisible(find.byKey(Key("ord_search")), "87");

    print("22.");
    await tapVisible(find.byKey(Key('chip_Em preparo')));

    print("23.");
    await tapVisible(find.byKey(Key('ord_clear')), wait: false);
    await tapVisible(find.byKey(Key('chip_Em preparo')));

    print("24.");
    await tapVisible(find.byKey(Key('chip_Novo')));

    print("25.");
    await tapVisible(find.byKey(Key('chip_Pronto para retirada')));

    print('26.');
    await tapVisible(find.byKey(Key('chip_Todos')), wait: false);
    await enterVisible(find.byKey(Key("ord_search")), "Bruno Oliveira");

    print('26.');
    await tapVisible(find.byKey(Key('chip_Todos')), wait: false);
    await enterVisible(find.byKey(Key("ord_search")), "Bruno Oliveira");

    print('27.');
    await enterVisible(find.byKey(Key("ord_search")), "BruNO OLIVEira");

    print('28.');
    final card1 = find.text("87234");
    await tapVisible(card1);
    await tapVisible(find.text('Ok!'), wait: false);

    print('29.');
    final column1 = find.text("Em preparo");
    final gesture1 = await tester.startGesture(tester.getCenter(card1));
    await tester.pumpAndSettle(Duration(seconds: 1));
    await gesture1.moveTo(tester.getCenter(column1));
    await tester.pumpAndSettle(Duration(seconds: 1));
    await gesture1.up();
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    print('30.');
    await tapVisible(find.byKey(Key("main_2")));

    print('31.');
    await tapVisible(find.byKey(Key("chip_Todas")));

    print('32.');
    await tapVisible(find.byKey(Key("chip_Entregue")));

    print('33.');
    await tapVisible(find.byKey(Key("chip_Em rota")));

    print('34.');
    await tapVisible(find.byKey(Key("card_87234")));

    print('35.');
    await tapVisible(find.byKey(Key("main_3")));

    print('36.');
    final center = tester.getCenter(find.byKey(Key('prof_image')));
    final dedo1 = await tester.startGesture(center - Offset(20, 0), pointer: 1);
    final dedo2 = await tester.startGesture(center + Offset(20, 0), pointer: 2);
    await tester.pumpAndSettle(Duration(seconds: 1));
    await dedo1.moveBy(Offset(100, 0));
    await dedo2.moveBy(Offset(-100, 0));
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    print('37.');
    await tester.drag(find.byKey(Key('prof_image')), Offset(100, 0));
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    print('38.');
    await tapVisible(find.byKey(Key("prof_theme")));

    print('39.');
    await tapVisible(find.byKey(Key("prof_theme")));

    print('40.');
    await enterVisible(find.byKey(Key("prof_tel")), "(190909009) 0-1");

    print('41.');
    await enterVisible(find.byKey(Key("prof_tel")), "(19) 12345-6789");

    print('42.');
    await enterVisible(find.byKey(Key("prof_email")), "aaaaa");

    print('43.');
    await enterVisible(find.byKey(Key("prof_email")), "a@a.com");

    print('44.');
    await tester.drag(find.byKey(Key('card_Carlos Eduardo')), Offset(100, 0));

    print('45.');
    await enterVisible(find.byKey(Key("prof_search")), "Ma");

    print('46.');
    await enterVisible(find.byKey(Key("prof_search")), "Mariana");

    print('47.');
    await enterVisible(find.byKey(Key("prof_search")), "Carambolas");

    print('48.');
    await tapVisible(find.byKey(Key("prof_clear")));

    print('50.');
    await tapVisible(find.byKey(Key("main_4")));
  });
}
