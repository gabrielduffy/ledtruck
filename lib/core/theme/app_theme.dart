import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryNeon = Color(0xFFFF7200);
  static const Color primaryHover = Color(0xFFE56600);
  
  // Text Colors
  static const Color textLight = Color(0xFFF0F0FF);
  static const Color textDark = Color(0xFF0D0D1A);
  static const Color textSecondaryDark = Color(0xFF6B6B8A);
  static const Color textSecondaryLight = Color(0xFF444444);

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
      dividerColor: const Color(0xFF13131D),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: textLight),
        headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textLight),
        headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textLight),
        titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textLight),
        bodyMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textLight),
        bodySmall: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textSecondaryDark),
        labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: textLight),
        labelMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: textSecondaryDark),
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
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      cardColor: const Color(0xFFFFFFFF),
      dialogBackgroundColor: const Color(0xFFFFFFFF),
      dividerColor: const Color(0xFFE5E5E5),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: textDark),
        headlineLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textDark),
        headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textDark),
        titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textDark),
        bodyMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textDark),
        bodySmall: GoogleFonts.montserrat(fontWeight: FontWeight.w400, color: textSecondaryLight),
        labelLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: textDark),
        labelMedium: GoogleFonts.montserrat(fontWeight: FontWeight.w500, color: textSecondaryLight),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryNeon,
        secondary: primaryHover,
        surface: Color(0xFFFFFFFF),
      ),
    );
  }
}
