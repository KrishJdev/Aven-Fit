import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sharp Glassmorphism design system.
///
/// OLED pitch-black surfaces, translucent glass cards, neon-cyan accent,
/// sharp edges (zero border radius) and monospaced tabular numerals so
/// metric columns stack perfectly.
abstract final class AppTheme {
  // ---- Brand palette (locked) ----

  /// OLED pitch-black base surface.
  static const Color oledBlack = Color(0xFF000000);

  /// Primary accent: active states, progress, focus rings.
  static const Color neonCyan = Color(0xFF00F0FF);

  /// Positive deltas and PR badges only.
  static const Color voltGreen = Color(0xFFE2F835);

  /// Destructive actions and warnings only.
  static const Color burntOrange = Color(0xFFE85D04);

  // ---- Glass layers ----

  /// Faint white wash for glass card fills on black.
  static const Color glassFill = Color(0x0AFFFFFF);

  /// Glass card borders ("glass border top" on nav bar).
  static const Color glassBorder = Color(0x1AFFFFFF);

  /// Primary text on black.
  static const Color textPrimary = Colors.white;

  /// De-emphasized text.
  static const Color textSecondary = Color(0x99FFFFFF);

  // ---- Typography ----
  //
  // Inter for UI, JetBrains Mono for numerals. Both are bundled as TTF
  // assets under the exact names google_fonts resolves by
  // ("<family>-<variant>.ttf"), so loading never touches the network —
  // the app stays fully offline-first and deterministic in tests.

  /// UI text styles built on Inter with JetBrains Mono as the numeral
  /// fallback.
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.4),
        ),
      ).apply(fontFamilyFallback: const ['JetBrains Mono']);

  /// Monospaced tabular numerals — use for every stat, weight, timer and
  /// calorie figure so digits align in stacked columns.
  static TextStyle num(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color? color,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ---- Theme ----

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: neonCyan,
      onPrimary: oledBlack,
      secondary: voltGreen,
      onSecondary: oledBlack,
      error: burntOrange,
      onError: oledBlack,
      surface: oledBlack,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: oledBlack,
      textTheme: textTheme,
      dividerColor: glassBorder,
    ).copyWith(
      // Sharp edges everywhere — the "sharp glass" identity.
      cardTheme: CardThemeData(
        color: glassFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: glassBorder),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: oledBlack,
        indicatorColor: glassFill,
        height: 64,
        elevation: 0,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? textPrimary : textSecondary,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: oledBlack,
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: glassFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: neonCyan, width: 1.5),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: glassFill,
        side: BorderSide(color: glassBorder),
        shape: RoundedRectangleBorder(),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF0A0A0A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(),
      ),
    );
  }
}
