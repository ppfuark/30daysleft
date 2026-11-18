import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App {
  App._();

  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
  );

  static ValueNotifier<ThemeData> valueNotifier = ValueNotifier(dark);

  static void toogle() {
    valueNotifier.value = valueNotifier.value == dark ? light : dark;
  }
}
