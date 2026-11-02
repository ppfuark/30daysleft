import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App {
  static ThemeData dark = ThemeData(
    colorScheme: ColorScheme.dark(primary: Colors.deepOrange),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
  );
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.light(primary: Colors.deepOrange),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
  );

  static ValueNotifier<ThemeData> theme = ValueNotifier(light);

  static void toogle() {
    theme.value = theme.value == dark ? light : dark;
  }
}
