import 'package:flutter/material.dart';

// Base color palette
const Color primaryColor = Color(0xFF310052);
const Color burgundyColor = Color(0xFFA61C3C);
const Color lightYellowColor = Color(0xFFF7FFE0);
const Color lightCoralColor = Color(0xFFFCBFB7);

class AppTheme {
  // Light theme configuration
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightYellowColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      primaryContainer: const Color.fromARGB(255, 65, 11, 101),
      onPrimary: Colors.white,
      secondary: burgundyColor,
      onSecondary: Colors.white,
      tertiary: lightCoralColor,
      background: lightYellowColor,
      onBackground: primaryColor.withOpacity(0.87),
      surface: Colors.white,
      onSurface: primaryColor.withOpacity(0.87),
      error: Colors.red.shade700,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: primaryColor),
      displayMedium: TextStyle(color: primaryColor),
      displaySmall: TextStyle(color: primaryColor),
      headlineMedium: TextStyle(color: primaryColor),
      headlineSmall: TextStyle(color: primaryColor),
      titleLarge: TextStyle(color: primaryColor),
      bodyLarge: TextStyle(color: primaryColor.withOpacity(0.87)),
      bodyMedium: TextStyle(color: primaryColor.withOpacity(0.87)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: burgundyColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: burgundyColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
      labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
      hintStyle: TextStyle(color: primaryColor.withOpacity(0.5)),
    ),
    dividerTheme: DividerThemeData(
      color: primaryColor.withOpacity(0.2),
      thickness: 1,
      space: 24,
    ),
    iconTheme: IconThemeData(color: primaryColor, size: 24),
    chipTheme: ChipThemeData(
      backgroundColor: lightCoralColor.withOpacity(0.7),
      labelStyle: TextStyle(color: primaryColor),
    ),
  );

  // Dark theme configuration
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryColor.withOpacity(0.9),
      onPrimary: lightYellowColor,
      secondary: burgundyColor.withOpacity(0.9),
      onSecondary: lightYellowColor,
      tertiary: lightCoralColor.withOpacity(0.8),
      background: Color(0xFF121212),
      onBackground: lightYellowColor.withOpacity(0.87),
      surface: Color(0xFF222222),
      onSurface: lightYellowColor.withOpacity(0.87),
      error: Colors.red.shade300,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: lightYellowColor,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: lightYellowColor),
      displayMedium: TextStyle(color: lightYellowColor),
      displaySmall: TextStyle(color: lightYellowColor),
      headlineMedium: TextStyle(color: lightYellowColor),
      headlineSmall: TextStyle(color: lightYellowColor),
      titleLarge: TextStyle(color: lightYellowColor),
      bodyLarge: TextStyle(color: lightYellowColor.withOpacity(0.87)),
      bodyMedium: TextStyle(color: lightYellowColor.withOpacity(0.87)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: burgundyColor.withOpacity(0.9),
        foregroundColor: lightYellowColor,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightYellowColor,
        side: BorderSide(color: lightYellowColor.withOpacity(0.8)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightCoralColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightYellowColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightYellowColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightYellowColor.withOpacity(0.6)),
      ),
      labelStyle: TextStyle(color: lightYellowColor.withOpacity(0.7)),
      hintStyle: TextStyle(color: lightYellowColor.withOpacity(0.5)),
    ),
    dividerTheme: DividerThemeData(
      color: lightYellowColor.withOpacity(0.2),
      thickness: 1,
      space: 24,
    ),
    iconTheme: IconThemeData(color: lightYellowColor, size: 24),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF2A2A2A),
      labelStyle: TextStyle(color: lightYellowColor),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: lightCoralColor,
      unselectedItemColor: lightYellowColor.withOpacity(0.5),
    ),
  );
}
