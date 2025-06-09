import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension ColorSchemeExtension on ColorScheme {
  Color get cardBackground =>
      brightness == Brightness.light ? Colors.white : const Color(0xFF2A2A2A);

  Color get inputFill => brightness == Brightness.light
      ? const Color(0xFFF3F4F6)
      : const Color(0xFF374151);

  Color get socialButtonBg => brightness == Brightness.light
      ? const Color(0xFFE5E7EB)
      : const Color(0xFF374151);

  Color get accent => const Color(0xFF453462);
}

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4FA095),
      brightness: Brightness.light,
      primary: const Color(0xFF4FA095),
      secondary: const Color(0xFF453462),
      surface: const Color(0xFFF9FAFB),
      onSurface: const Color(0xFF1F2937),
    ),
    textTheme: GoogleFonts.figtreeTextTheme(ThemeData.light().textTheme),
    fontFamily: GoogleFonts.figtree().fontFamily,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF453462),
      titleTextStyle: TextStyle(
        color: Color(0xFF453462),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF4FA095), width: 2),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF453462),
      brightness: Brightness.dark,
      primary: const Color(0xFF4FA095),
      secondary: const Color(0xFF6B8E6B),
      surface: const Color(0xFF1F2937),
      onSurface: const Color(0xFFDAD1C2),
    ),
    textTheme: GoogleFonts.figtreeTextTheme(ThemeData.dark().textTheme),
    fontFamily: GoogleFonts.figtree().fontFamily,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF111827),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFDAD1C2),
      titleTextStyle: TextStyle(
        color: Color(0xFFDAD1C2),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF374151), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF4FA095), width: 2),
      ),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
