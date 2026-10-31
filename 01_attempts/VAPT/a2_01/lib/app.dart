import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App {
  App._();

  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(),
    textTheme: GoogleFonts.dosisTextTheme(ThemeData.dark().textTheme),
  );
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(),
    textTheme: GoogleFonts.dosisTextTheme(ThemeData.light().textTheme),
  );

  static ValueNotifier<ThemeData> theme = ValueNotifier(light);

  static void toogle() {
    theme.value = theme.value == dark ? light : dark;
  }
}
