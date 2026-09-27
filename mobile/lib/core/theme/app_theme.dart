import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aven Fit UI/UX Design System v2.0 — the single source of truth for every
/// visual token. See `docs/UI_UX_DESIGN_SYSTEM.md` (authoritative; supersedes
/// all prior conventions). Offline-first: Inter + JetBrains Mono are bundled
/// as SHA-256-pinned TTF assets, so `google_fonts` never touches the network.
///
/// Rules (§24.4): never hardcode hex colors, padding values, radii, or text
/// styles in widget files — always reference these tokens.
abstract final class AppTheme {
  // =========================================================================
  // §4  Color system — semantic roles, never raw hue in widget code.
  // =========================================================================

  // ---- Background & surface (§4.1) ----
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceElevated = Color(0xFF141414);
  static const Color surfaceActive = Color(0xFF1A1A1A);

  // ---- Brand & accent (§4.1) ----
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryMuted = Color(0x2600D4AA); // 15%
  static const Color secondary = Color(0xFFC8E640);
  static const Color secondaryMuted = Color(0x26C8E640); // 15%
  static const Color warning = Color(0xFFE8772E);
  static const Color warningMuted = Color(0x26E8772E); // 15%

  // ---- Text (§4.1) ----
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x8CFFFFFF); // 55%
  static const Color textMuted = Color(0x59FFFFFF); // 35%
  static const Color textOnPrimary = Color(0xFF000000);

  // ---- Structural (§4.1) ----
  static const Color border = Color(0x14FFFFFF); // 8%
  static const Color borderFocused = primary;
  static const Color divider = Color(0x0FFFFFFF); // 6%
  static const Color disabled = Color(0x33FFFFFF); // 20%
  static const Color overlay = Color(0x99000000); // 60%

  // ---- Semantic states (§4.1) ----
  static const Color success = secondary;
  static const Color error = warning;
  static const Color info = primary;

  // =========================================================================
  // §6  Spacing scale — 4px-based. No invented values.
  // =========================================================================

  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spaceXxl = 24;
  static const double spaceXxxl = 32;

  // =========================================================================
  // §7  Corner radius scale.
  // =========================================================================

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusFull = 999;

  // =========================================================================
  // §17 Motion scale.
  // =========================================================================

  static const Duration motionFast = Duration(milliseconds: 100);
  static const Duration motionStandard = Duration(milliseconds: 200);
  static const Duration motionSlow = Duration(milliseconds: 300);

  // =========================================================================
  // §25.7 Control sizes.
  // =========================================================================

  static const double buttonHeight = 48;
  static const double chipHeight = 32;
  static const double inputHeight = 48;
  static const double iconButtonSize = 40;
  static const double navBarHeight = 64;
  static const double stepperButtonSize = 36;

  // ---- Icon sizes (§9.2) ----
  static const double iconNav = 22;
  static const double iconAction = 20;
  static const double iconSection = 18;
  static const double iconSmall = 16;
  static const double iconBadge = 14;
  static const double iconEmpty = 28;

  // =========================================================================
  // §5  Typography. Inter (UI) + JetBrains Mono (tabular numerals).
  // =========================================================================

  /// UI text styles built on Inter. JetBrains Mono is the numeral fallback.
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme(
          // display: 28/700
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          // heading: 20/700
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.3,
          ),
          // title: 16/600
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          // body: 14/400
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          // bodyMedium: 14/500
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
          // label: 12/600
          labelLarge: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            height: 1.3,
          ),
          // caption: 11/500
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            height: 1.3,
          ),
        ),
      ).apply(fontFamilyFallback: const ['JetBrains Mono']);

  /// Tabular numerals for every weight, rep, calorie, timer, and stat so
  /// digits align in stacked columns and never "jump" as values change.
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

  /// The ThemeExtension carrying tokens ColorScheme cannot express (§24.3).
  /// Access via `Theme.of(context).extension<AvenFitColors>()!`.
  static const AvenFitColors extension = AvenFitColors._();

  // =========================================================================
  // §24.2  ThemeData.
  // =========================================================================

  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      primary: primary,
      onPrimary: textOnPrimary,
      secondary: secondary,
      onSecondary: textOnPrimary,
      error: warning,
      onError: textOnPrimary,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: divider,
      extensions: const [extension],
    ).copyWith(
      // Cards: solid surface fill, radiusMd, no border by default (§11/§8).
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryMuted,
        height: navBarHeight,
        elevation: 0,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: iconNav,
            color: states.contains(WidgetState.selected) ? primary : textSecondary,
          ),
        ),
      ),
      // Primary button: primary fill, textOnPrimary, radiusSm (§10.1).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      // Outlined secondary button (§10.1).
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(buttonHeight),
          side: const BorderSide(color: primary, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          ),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      // Text/tertiary button (§10.1).
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(iconButtonSize),
          foregroundColor: textPrimary,
        ),
      ),
      // Inputs: surface fill, border default → primary focused (§10.2).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
        hintStyle: TextStyle(color: textMuted),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: warning),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
          borderSide: BorderSide(color: warning, width: 1.5),
        ),
      ),
      // Chips: surface fill / primary when selected (§10.4).
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primaryMuted,
        side: const BorderSide(color: border),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
        ),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      // Snackbars: floating, radiusSm, surfaceElevated (§10.12).
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusSm)),
        ),
        contentTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
      ),
      // Bottom sheets: surfaceElevated, radiusLg top (§10.11).
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
      ),
      // Dialogs: surfaceElevated, radiusMd (§10.10).
      dialogTheme: const DialogThemeData(
        backgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
        ),
      ),
      // Linear progress: primary fill on surface track (§10.8).
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surface,
        linearMinHeight: 4,
      ),
      // Dividers: nearly invisible (§4.1).
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 0.5,
        space: 1,
      ),
      // List tiles: transparent on background, surface when grouped (§10.6).
      listTileTheme: ListTileThemeData(
        textColor: textPrimary,
        iconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceXs),
      ),
    );
  }

}

/// ThemeExtension surfacing the tokens `ColorScheme` cannot carry (§24.3):
/// surface levels, muted accents, text tiers, and structural colors.
@immutable
class AvenFitColors extends ThemeExtension<AvenFitColors> {
  const AvenFitColors._();

  final Color background = AppTheme.background;
  final Color surface = AppTheme.surface;
  final Color surfaceElevated = AppTheme.surfaceElevated;
  final Color surfaceActive = AppTheme.surfaceActive;
  final Color primaryMuted = AppTheme.primaryMuted;
  final Color secondaryMuted = AppTheme.secondaryMuted;
  final Color warningMuted = AppTheme.warningMuted;
  final Color textPrimary = AppTheme.textPrimary;
  final Color textSecondary = AppTheme.textSecondary;
  final Color textMuted = AppTheme.textMuted;
  final Color textOnPrimary = AppTheme.textOnPrimary;
  final Color border = AppTheme.border;
  final Color borderFocused = AppTheme.borderFocused;
  final Color divider = AppTheme.divider;
  final Color disabled = AppTheme.disabled;
  final Color overlay = AppTheme.overlay;

  @override
  AvenFitColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceActive,
    Color? primaryMuted,
    Color? secondaryMuted,
    Color? warningMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnPrimary,
    Color? border,
    Color? borderFocused,
    Color? divider,
    Color? disabled,
    Color? overlay,
  }) =>
      AvenFitColors._();

  @override
  AvenFitColors lerp(AvenFitColors? other, double t) => this;
}
