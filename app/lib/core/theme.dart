import 'package:flutter/material.dart';
import 'constants.dart';

/// PillSafe design system.
///
/// Status colour palette targets WCAG AAA (7:1) contrast ratio
/// for text on tinted status backgrounds.
class AppTheme {
  AppTheme._();

  // ── Status fill / border / text colours ──────────────────────────────
  static const Color greenFill = Color(0xFFE6F4EA);
  static const Color greenBorder = Color(0xFF1B7735);
  static const Color greenText = Color(0xFF0D3D1A);

  static const Color yellowFill = Color(0xFFFFF8E1);
  static const Color yellowBorder = Color(0xFF9A6700);
  static const Color yellowText = Color(0xFF4A3200);

  static const Color redFill = Color(0xFFFFEBEE);
  static const Color redBorder = Color(0xFFB71C1C);
  static const Color redText = Color(0xFF5B0000);

  static const Color greyFill = Color(0xFFF5F5F5);
  static const Color greyBorder = Color(0xFF555555);
  static const Color greyText = Color(0xFF1A1A1A);

  // ── UI colours ────────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF4F6F8);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF555555);
  static const Color cardBorder = Color(0xFFDDDDDD);

  // ── Typography ────────────────────────────────────────────────────────
  static const TextStyle headingStyle = TextStyle(
    fontSize: kHeadingTextSp,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: kBodyTextSp,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: kButtonTextSp,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle smallStyle = TextStyle(
    fontSize: kSmallTextSp,
    color: textSecondary,
    height: 1.4,
  );

  // ── App ThemeData ─────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        colorSchemeSeed: primaryBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceWhite,
          foregroundColor: textPrimary,
          elevation: 1,
          titleTextStyle: TextStyle(
            fontSize: kHeadingTextSp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: kBodyTextSp, color: textPrimary),
          bodyMedium: TextStyle(fontSize: kBodyTextSp, color: textPrimary),
          titleLarge: TextStyle(
            fontSize: kHeadingTextSp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, kMinTapTarget),
            textStyle: buttonStyle,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, kMinTapTarget),
            textStyle: buttonStyle,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: cardBorder),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          hintStyle: const TextStyle(
              fontSize: kBodyTextSp, color: textSecondary),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: surfaceWhite,
        ),
        useMaterial3: true,
      );
}
