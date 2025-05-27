import 'package:flutter/material.dart';

class Styles {
  static Color backgroundColor = Color.fromRGBO(30, 30, 30, 1);
  static Color backgroundSecondaryColor = Color.fromRGBO(50, 50, 50, 1);
  static Color textColor = Colors.white;

  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: backgroundColor,
    titleTextStyle: TextStyle(color: textColor, fontSize: 20),
  );

  static BottomNavigationBarThemeData bottomNavigationAppBarTheme = BottomNavigationBarThemeData(
    backgroundColor: backgroundColor,
    selectedItemColor: textColor,
    unselectedItemColor: Colors.grey,
  );

  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(color: textColor, fontSize: 34, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
    headlineLarge: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
    titleSmall: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: textColor, fontSize: 16),
    bodyMedium: TextStyle(color: textColor, fontSize: 14),
    bodySmall: TextStyle(color: textColor, fontSize: 12),
    labelLarge: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
    labelMedium: TextStyle(color: textColor, fontSize: 14),
    labelSmall: TextStyle(color: textColor, fontSize: 12),
  );

  static EdgeInsets viewPadding = EdgeInsets.all(28);
}