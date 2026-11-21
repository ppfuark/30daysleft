import 'package:d1_01/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('', (WidgetTester tester) async {
    tester.testTextInput.register();

    Future<void> settle({int ms = 800}) async {
      const step = 100;
      for (var i = 0; i < ms ~/ step; i++) {
        await tester.pump(const Duration(milliseconds: step));
      }
    }

    Future<void> tapVisible(Finder finder, {int wait = 800}) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await settle(ms: 1000);
      await tester.ensureVisible(finder);
      await settle(ms: 1000);
      await tester.tap(finder);
      await settle(ms: wait);
    }

    Future<void> enterVisible(
      Finder finder,
      String value, {
      int wait = 800,
    }) async {
      tester
          .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
          .clearSnackBars();

      await settle(ms: 1000);
      await tester.ensureVisible(finder.first);
      await settle(ms: 1000);
      await tester.enterText(finder.first, value);
      await settle(ms: wait);
    }

    Future<void> dragAndDrop(Finder from, Finder to, {int wait = 800}) async {
      final gesture = await tester.startGesture(tester.getCenter(from.first));
      await settle(ms: 800);
      await gesture.moveTo(tester.getCenter(to.first));
      await settle(ms: 500);
      await gesture.up();
      await settle(ms: wait);
    }

    print('1.');
    await tester.pumpWidget(MyApp());
    await settle();

    print('2.');
    await enterVisible(find.byKey(Key("log_email")), "A@a.com");

    print('3.');
    await enterVisible(find.byKey(Key("log_pass")), "123");

    print("4.");
    await tapVisible(find.text("Entrar"));

    print("5.");
    await tapVisible(find.text("Entrar"));

    print("6.");
    await tapVisible(find.text("Entrar"));

    print("7.");
    await tapVisible(find.text("Esqueci minha senha"));

    print("8.");
    await tapVisible(find.text("Ok!"));

    print("9.");
    await tapVisible(find.text("Fale com o suporte"));

    print("10.");
    await tapVisible(find.text("Ok!"));

    print('11.');
    await enterVisible(find.byKey(Key("log_email")), "@claudio123");
    await tapVisible(find.text("Entrar"));

    print('12.');
    await enterVisible(find.byKey(Key("log_email")), "gerente@vaptfood.com.br");

    print('13.');
    await enterVisible(find.byKey(Key("log_pass")), "Vapt@2026");

    print("14.");
    await tapVisible(find.text("Entrar"), wait: 4000);

    print('15.');
    await enterVisible(find.byKey(Key("home_search")), "Mariana");
    await tapVisible(find.byKey(Key('home_clear')));

    print('16.');
    await enterVisible(find.byKey(Key("home_search")), "G");

    print("17.");
    await tapVisible(find.byKey(Key('home_clear')));

    print("18.");
    await dragAndDrop(find.byKey(Key("87234")), find.text("Pedidos Recentes"));

    print("19.");
    await tapVisible(find.byKey(Key('main_1')));

    print('20.');
    await enterVisible(find.byKey(Key("ord_search")), "87234");

    print('21.');
    await enterVisible(find.byKey(Key("ord_search")), "87");

    print("22.");
    await tapVisible(find.byKey(Key('chip_Em preparo')));

    print("23.");
    await tapVisible(find.byKey(Key('ord_clear')));
    await tapVisible(find.byKey(Key('chip_Em preparo')));

    print("24.");
    await tapVisible(find.byKey(Key('chip_Novo')));

    print("25.");
    await tapVisible(find.byKey(Key('chip_Pronto para retirada')));

    print('26.');
    await tapVisible(find.byKey(Key('chip_Todos')));
    await enterVisible(find.byKey(Key("ord_search")), "Bruno Oliveira");

    print('26.');
    await tapVisible(find.byKey(Key('chip_Todos')));
    await enterVisible(find.byKey(Key("ord_search")), "Bruno Oliveira");

    print('27.');
    await enterVisible(find.byKey(Key("ord_search")), "BruNO OLIVEira");

    print('28.');
    await tapVisible(find.byKey(Key('ord_clear')), wait: 500);
    final card1 = find.text("#87234").first;
    await tapVisible(card1);
    await tapVisible(find.text('Ok!'), wait: 100);

    print('29.');
    await dragAndDrop(card1, find.text("Em preparo"));
    await tapVisible(find.text('Sim'), wait: 100);

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
    await settle();
    await dedo1.moveBy(Offset(100, 0));
    await dedo2.moveBy(Offset(-100, 0));
    await settle();
    await dedo1.up();
    await dedo2.up();
    await settle();

    print('37.');
    await tester.drag(find.byKey(Key('prof_image')), Offset(100, 0));
    await settle();

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
    await tester.fling(
      find.byKey(Key('card_Carlos Eduardo')),
      Offset(-500, 0),
      1000,
    );
    await settle();

    print('45.');
    await enterVisible(find.byKey(Key("prof_search")), "Ma");

    print('46.');
    await enterVisible(find.byKey(Key("prof_search")), "Mariana");

    print('47.');
    await enterVisible(find.byKey(Key("prof_search")), "Carambolas");

    print('48.');
    await tapVisible(find.byKey(Key("prof_clear")));

    print('49.');
    await tester.fling(
      find.byKey(Key('card_Fernanda Lima')),
      Offset(-500, 0),
      1000,
    );
    await settle();

    print('50.');
    await tapVisible(find.byKey(Key("main_4")));
  });
}
