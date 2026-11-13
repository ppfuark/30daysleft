import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App {
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(),
    textTheme: GoogleFonts.dosisTextTheme(ThemeData.light().textTheme),
    primaryColor: Colors.deepOrangeAccent,
  );
  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(),
    textTheme: GoogleFonts.dosisTextTheme(ThemeData.dark().textTheme),
    primaryColor: Colors.deepOrangeAccent,
  );
  static ValueNotifier<ThemeData> valueNotifier = ValueNotifier(light);

  static void toogle() {
    valueNotifier.value = valueNotifier.value == dark ? light : dark;
  }
}
