import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Accent colors — identical in light and dark themes.
// ---------------------------------------------------------------------------

class PWColors {
  static const yellow = Color(0xFFFFD84D);
  static const blue = Color(0xFF6EC6E9);
  static const coral = Color(0xFFFF7A7A);
  static const mint = Color(0xFF7ED6B2);
  static const navy = Color(0xFF2F3A4A);

  static const bg = Color(0xFFFDFDFD);
}

// ---------------------------------------------------------------------------
// Semantic colors that vary between light and dark mode.
//
// Access via: PWThemeColors.of(context).cardBg
// ---------------------------------------------------------------------------

class PWThemeColors extends ThemeExtension<PWThemeColors> {
  const PWThemeColors({
    required this.background,
    required this.cardBg,
    required this.textPrimary,
    required this.textMuted,
    required this.shadowColor,
  });

  final Color background;
  final Color cardBg;
  final Color textPrimary;
  final Color textMuted;
  final Color shadowColor;

  // ── Light palette ──

  static const light = PWThemeColors(
    background: Color(0xFFEAF8FF),
    cardBg: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0D1B2A),
    textMuted: Color(0xFF5A6A7A),
    shadowColor: Color(0xFF0D1B2A),
  );

  // ── Dark palette (soft night, NOT pure black) ──

  static const dark = PWThemeColors(
    background: Color(0xFF0E1B2B),
    cardBg: Color(0xFF1B2F4A),
    textPrimary: Color(0xFFFFFFFF),
    textMuted: Color(0xFFB0C4DE),
    shadowColor: Color(0xFF000000),
  );

  /// Convenience accessor from any widget.
  static PWThemeColors of(BuildContext context) =>
      Theme.of(context).extension<PWThemeColors>()!;

  @override
  PWThemeColors copyWith({
    Color? background,
    Color? cardBg,
    Color? textPrimary,
    Color? textMuted,
    Color? shadowColor,
  }) {
    return PWThemeColors(
      background: background ?? this.background,
      cardBg: cardBg ?? this.cardBg,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  PWThemeColors lerp(covariant PWThemeColors? other, double t) {
    if (other == null) return this;
    return PWThemeColors(
      background: Color.lerp(background, other.background, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

// ---------------------------------------------------------------------------
// Theme builders
// ---------------------------------------------------------------------------

/// Light theme — the default kid-friendly look.
ThemeData planetWondersLightTheme({bool reduceMotion = false}) => _buildTheme(
      brightness: Brightness.light,
      colors: PWThemeColors.light,
      reduceMotion: reduceMotion,
    );

/// Dark theme — soft night mode for low-light use.
ThemeData planetWondersDarkTheme({bool reduceMotion = false}) => _buildTheme(
      brightness: Brightness.dark,
      colors: PWThemeColors.dark,
      reduceMotion: reduceMotion,
    );

/// Legacy alias so existing code that calls `planetWondersTheme()` still works.
ThemeData planetWondersTheme() => planetWondersLightTheme();

ThemeData _buildTheme({
  required Brightness brightness,
  required PWThemeColors colors,
  bool reduceMotion = false,
}) {
  final isDark = brightness == Brightness.dark;
  final base = ThemeData(useMaterial3: true, brightness: brightness);

  return base.copyWith(
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PWColors.blue,
      brightness: brightness,
      primary: PWColors.blue,
      secondary: PWColors.coral,
      surface: colors.cardBg,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.baloo2(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: colors.textPrimary,
      ),
      headlineSmall: GoogleFonts.baloo2(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        elevation: 4,
        shadowColor: colors.shadowColor.withValues(alpha: 0.25),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        foregroundColor: colors.textPrimary,
        side: BorderSide(
          color: colors.textMuted.withValues(alpha: 0.3),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 6,
      shadowColor: colors.shadowColor.withValues(alpha: 0.15),
      indicatorColor: PWColors.blue.withValues(alpha: 0.2),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: colors.cardBg,
      shadowColor: colors.shadowColor.withValues(alpha: 0.12),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: isDark ? colors.background : Colors.transparent,
      foregroundColor: colors.textPrimary,
      shadowColor: colors.shadowColor.withValues(alpha: 0.12),
    ),
    dividerTheme: DividerThemeData(
      color: colors.textMuted.withValues(alpha: 0.15),
    ),
    pageTransitionsTheme: reduceMotion
        ? const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            },
          )
        : null,
    extensions: [colors],
  );
}
