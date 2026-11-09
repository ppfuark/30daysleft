import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  App._();

  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(),
    textTheme: GoogleFonts.inriaSansTextTheme(ThemeData.light().textTheme),
  );
  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(),
    textTheme: GoogleFonts.inriaSansTextTheme(ThemeData.dark().textTheme),
  );

  static ValueNotifier<ThemeData> theme = ValueNotifier(light);

  static Future<void> toogle() async {
    theme.value = theme.value == dark ? light : dark;
    final share = await SharedPreferences.getInstance();

    await share.setBool('dark', theme.value == dark);
  }

  static Future<void> init() async {
    final share = await SharedPreferences.getInstance();

    if (share.getBool('dark') ?? false) {
      toogle();
    }
  }
}
