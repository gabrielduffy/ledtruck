import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryNeon = Color(0xFFFF7200);
  static const Color primaryHover = Color(0xFFE56600);
  
  // Text Colors
  static const Color textLight = Color(0xFFF0F0FF);
  static const Color textDark = Color(0xFF0D0D1A);
  static const Color textSecondaryDark = Color(0xFF6B6B8A);
  static const Color textSecondaryLight = Color(0xFF6B6B8A);

  // Status Colors
  static const Color statusLigado = Color(0xFFFF7200);
  static const Color statusEstoque = Color(0xFF4A9EFF);
  static const Color statusManutencao = Color(0xFFFFB020);
  static const Color statusInativo = Color(0xFF444455);
  static const Color statusDesligado = Color(0xFF6B6B8A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryNeon,
      scaffoldBackgroundColor: const Color(0xFF050508),
      cardColor: const Color(0xFF0D0D14),
      dialogBackgroundColor: const Color(0xFF13131E),
      dividerColor: const Color(0xFF13131E),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: textLight),
        headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textLight),
        titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textLight),
        bodyMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textLight),
        labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: textLight),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: primaryHover,
        surface: Color(0xFF13131E),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryNeon,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: const Color(0xFFFFFFFF),
      dialogBackgroundColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFE0E0E0),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: textDark),
        headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textDark),
        titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textDark),
        labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: textDark),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryNeon,
        secondary: primaryHover,
        surface: Color(0xFFFFFFFF),
      ),
    );
  }
}
