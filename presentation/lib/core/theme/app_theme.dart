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

  // New additions for modern design
  Color get successColor => const Color(0xFF10B981);
  Color get warningColor => const Color(0xFFF59E0B);
  Color get infoColor => const Color(0xFF3B82F6);

  Color get surfaceVariant => brightness == Brightness.light
      ? const Color(0xFFF8FAFC)
      : const Color(0xFF1E293B);

  Color get onSurfaceVariant => brightness == Brightness.light
      ? const Color(0xFF64748B)
      : const Color(0xFF94A3B8);

  Color get shimmerBase => brightness == Brightness.light
      ? const Color(0xFFE2E8F0)
      : const Color(0xFF334155);

  Color get shimmerHighlight => brightness == Brightness.light
      ? const Color(0xFFF1F5F9)
      : const Color(0xFF475569);
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
      surface: const Color(0xFFFDFDFD),
      onSurface: const Color(0xFF1F2937),
      error: const Color(0xFFEF4444),
      outline: const Color(0xFFE5E7EB),
    ),
    textTheme: GoogleFonts.figtreeTextTheme(ThemeData.light().textTheme),
    fontFamily: GoogleFonts.figtree().fontFamily,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),

    // Enhanced AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF453462),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Color(0xFF453462),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Enhanced Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF4FA095), width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2.5),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontWeight: FontWeight.w400,
      ),
    ),

    // Enhanced Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Enhanced Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
    ),

    // Enhanced Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF1F5F9),
      selectedColor: const Color(0xFF4FA095).withOpacity(0.1),
      disabledColor: const Color(0xFFF1F5F9),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4FA095),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
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
      surface: const Color(0xFF1E293B),
      onSurface: const Color(0xFFE2E8F0),
      error: const Color(0xFFF87171),
      outline: const Color(0xFF374151),
    ),
    textTheme: GoogleFonts.figtreeTextTheme(ThemeData.dark().textTheme),
    fontFamily: GoogleFonts.figtree().fontFamily,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0F172A),

    // Enhanced AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE2E8F0),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Color(0xFFE2E8F0),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Enhanced Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF374151), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFF4FA095), width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 2.5),
      ),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w400,
      ),
    ),

    // Enhanced Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Enhanced Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(
          color: Color(0xFF374151),
          width: 0.5,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
    ),

    // Enhanced Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF334155),
      selectedColor: const Color(0xFF4FA095).withOpacity(0.2),
      disabledColor: const Color(0xFF334155),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFE2E8F0),
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4FA095),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
