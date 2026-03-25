import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores
  static const Color primary = Color(0xFF1A1A2E);
  static const Color accent = Color(0xFF00E87A);
  static const Color background = Color(0xFF0A0A0F);
  static const Color cardSurface = Color(0xFF12121A);
  static const Color secondarySurface = Color(0xFF1A1A26);
  static const Color textMain = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF7A7A9A);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: cardSurface,
      onSurface: textMain,
      surfaceVariant: secondarySurface,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: const TextStyle(color: textMain),
      bodyMedium: const TextStyle(color: textSecondary),
    ),
    cardTheme: CardTheme(
      color: cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondarySurface,
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textMain.withValues(alpha: 0.2)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: Colors.white,
      onSurface: primary,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
  );
}
