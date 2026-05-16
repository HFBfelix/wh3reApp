import 'package:flutter/material.dart';

/// Design system Wh3re — fond blanc, accent violet #6A0DAD.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6A0DAD);
  static const Color primaryLight = Color(0xFF8B3DCC);
  static const Color primaryDark = Color(0xFF4A0878);
  static const Color primarySurface = Color(0xFFF3E8FF);

  // ── Backgrounds ────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color scaffold = Color(0xFFFFFFFF);

  // ── Text ───────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // ── Borders & dividers ─────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = primary;
  static const Color divider = Color(0xFFF3F4F6);

  // ── Semantic ───────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Polling weights (gamification) ─────────────────────────────────────
  static const Color weightIndifferent = Color(0xFF9CA3AF);
  static const Color weightWished = Color(0xFF6A0DAD);
  static const Color weightRedhibitory = Color(0xFFEF4444);

  // ── Overlays (bottom sheets blur) ──────────────────────────────────────
  static const Color overlay = Color(0x66000000);
  static const Color glassBackground = Color(0xCCFFFFFF);

  // ── Shimmer ────────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);

  // ── Radius tokens ──────────────────────────────────────────────────────
  static const double radiusCard = 24;
  static const double radiusInput = 16;
  static const double radiusButton = 16;
  static const double radiusSheet = 24;

  // ── Blur tokens (BackdropFilter) ─────────────────────────────────────────
  static const double blurSigmaX = 10;
  static const double blurSigmaY = 10;

  /// [ColorScheme] Material 3 aligné sur la marque Wh3re.
  static ColorScheme get colorScheme => const ColorScheme.light(
        primary: primary,
        onPrimary: textOnPrimary,
        primaryContainer: primarySurface,
        onPrimaryContainer: primaryDark,
        secondary: primaryLight,
        onSecondary: textOnPrimary,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: textOnPrimary,
        outline: border,
      );

  /// [ThemeData] de base pour [MaterialApp].
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: scaffold,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusInput),
            borderSide: const BorderSide(color: borderFocused, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textOnPrimary,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton),
            ),
            elevation: 0,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: textPrimary,
          contentTextStyle: const TextStyle(color: textOnPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusInput),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
