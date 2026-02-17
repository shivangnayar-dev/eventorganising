import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigoAccent,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      );
}
