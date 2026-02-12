import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PWColors {
  static const yellow = Color(0xFFFFD84D);
  static const blue = Color(0xFF6EC6E9);
  static const coral = Color(0xFFFF7A7A);
  static const mint = Color(0xFF7ED6B2);
  static const navy = Color(0xFF2F3A4A);

  static const bg = Color(0xFFFDFDFD);
}

ThemeData planetWondersTheme() {
  final base = ThemeData(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: PWColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PWColors.blue,
      primary: PWColors.blue,
      secondary: PWColors.coral,
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: PWColors.navy,
      ),
      headlineSmall: GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: PWColors.navy,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: PWColors.navy,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: PWColors.navy,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
        elevation: 4,
        shadowColor: PWColors.navy.withValues(alpha: 0.25),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 6,
      shadowColor: PWColors.navy.withValues(alpha: 0.15),
      indicatorColor: PWColors.blue.withValues(alpha: 0.2),
    ),
    cardTheme: const CardThemeData(
      elevation: 4,
      shadowColor: Color(0x1F2F3A4A), // navy at ~12%
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 4,
      shadowColor: Color(0x1F2F3A4A),
    ),
  );
}