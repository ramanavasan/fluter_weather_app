// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color cardBg = Color(0x26FFFFFF);
  static const Color cardBgDark = Color(0x1AFFFFFF);
  static const Color white = Colors.white;
  static const Color whiteTransparent = Color(0xB3FFFFFF);

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 96,
        fontWeight: FontWeight.w200,
        color: white,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 60,
        fontWeight: FontWeight.w300,
        color: white,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: white,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: white,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: whiteTransparent,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: white,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: whiteTransparent,
      ),
      bodySmall: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: whiteTransparent,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: whiteTransparent,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: whiteTransparent,
      ),
    );
  }

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      textTheme: _buildTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }
}
