import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  App._();
  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    primaryColor: Colors.blue,
  );
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    primaryColor: Colors.blue,
  );
  static ValueNotifier<ThemeData> theme = ValueNotifier(light);
  static void toogle() {
    theme.value = theme.value == dark ? light : dark;
  }

  static Future<void> init() async {
    final share = await SharedPreferences.getInstance();
    if (share.getBool('dark') ?? false) {
      toogle();
    }
  }
}
