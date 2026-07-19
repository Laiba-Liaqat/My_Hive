import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central palette + theme definitions for Hive Focus.
/// Warm honey golds, deep hive-wax browns, and soft cream backgrounds.
class HiveColors {
  HiveColors._();

  // Core honey palette
  static const Color honeyGold = Color(0xFFF5A623);
  static const Color honeyAmber = Color(0xFFE8890C);
  static const Color honeyDeep = Color(0xFFB86B00);
  static const Color waxBrown = Color(0xFF5C3A21);
  static const Color hiveBrownDark = Color(0xFF2E1D10);
  static const Color combCream = Color(0xFFFFF3DE);
  static const Color combCreamDark = Color(0xFFFFE3B3);

  // Status
  static const Color success = Color(0xFF6FA85E);
  static const Color danger = Color(0xFFD8555A);
  static const Color wilted = Color(0xFF8C7B6B);

  // Light theme surfaces
  static const Color lightBg = Color(0xFFFFFBF3);
  static const Color lightSurface = Color(0xFFFFF6E5);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Dark theme surfaces
  static const Color darkBg = Color(0xFF1B120A);
  static const Color darkSurface = Color(0xFF241708);
  static const Color darkCard = Color(0xFF2E1F0F);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: HiveColors.waxBrown,
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: HiveColors.waxBrown,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: HiveColors.lightBg,
      colorScheme: base.colorScheme.copyWith(
        primary: HiveColors.honeyGold,
        secondary: HiveColors.honeyAmber,
        surface: HiveColors.lightSurface,
        error: HiveColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: HiveColors.lightBg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: HiveColors.waxBrown,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: HiveColors.waxBrown,
        ),
      ),
      cardTheme: CardThemeData(
        color: HiveColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HiveColors.honeyGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HiveColors.lightCard,
        selectedItemColor: HiveColors.honeyAmber,
        unselectedItemColor: HiveColors.wilted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerColor: HiveColors.combCreamDark,
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: HiveColors.combCream,
      ),
      headlineMedium: GoogleFonts.fredoka(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: HiveColors.combCream,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: HiveColors.darkBg,
      colorScheme: base.colorScheme.copyWith(
        primary: HiveColors.honeyGold,
        secondary: HiveColors.honeyAmber,
        surface: HiveColors.darkSurface,
        error: HiveColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: HiveColors.darkBg,
        elevation: 0,
        centerTitle: false,
        foregroundColor: HiveColors.combCream,
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: HiveColors.combCream,
        ),
      ),
      cardTheme: CardThemeData(
        color: HiveColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HiveColors.honeyGold,
          foregroundColor: HiveColors.hiveBrownDark,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HiveColors.darkCard,
        selectedItemColor: HiveColors.honeyGold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerColor: const Color(0xFF3D2A16),
      useMaterial3: true,
    );
  }
}
