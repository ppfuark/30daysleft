import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  App._();

  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(),
    textTheme: GoogleFonts.inriaSansTextTheme(ThemeData.dark().textTheme),
  );
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(),
    textTheme: GoogleFonts.inriaSansTextTheme(ThemeData.light().textTheme),
  );

  static ValueNotifier<ThemeData> theme = ValueNotifier(light);

  static Future<void> init() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final dark = sharedPreferences.getBool('dark') ?? false;

    if (dark) {
      toogle();
    }
  }

  static Future<void> toogle() async {
    theme.value = theme.value == dark ? light : dark;

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    await sharedPreferences.setBool('dark', theme.value == dark);
  }
}
