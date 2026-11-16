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
  static ThemeData darkC = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
    iconTheme: IconThemeData(color: Colors.white),
  );

  static ThemeData lightC = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
    iconTheme: IconThemeData(color: Colors.black),
    
  );

  static ValueNotifier<ThemeData> theme = ValueNotifier(light);

  static bool cont = false;
  static bool isDark = false;

  static void themeT() {
    if (isDark) {
      theme.value = cont ? darkC : dark;
    } else {
      theme.value = cont ? lightC : light;
    }
  }

  static void toogleT() {
    isDark = !isDark;
    themeT();
  }

  static void toogleC() {
    cont = !cont;
    themeT();
  }
}
