import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette inspired by Zimbabwean culture
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryRed = Color(0xFFDC2626);
  static const Color accentGreen = Color(0xFF059669);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF1F2937);

  // Game-specific colors
  static const Color correctTile = Color(0xFF10B981); // Green
  static const Color wrongPositionTile = Color(0xFFF59E0B); // Amber
  static const Color notInWordTile = Color(0xFF6B7280); // Gray
  static const Color emptyTile = Color(0xFFFFFFFF);
  static const Color emptyTileBorder = Color(0xFFD1D5DB);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGold,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGold,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGold,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: primaryGold,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
