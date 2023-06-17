import 'package:flutter/material.dart';

final grey200=Colors.grey[200];
final grey300=Colors.grey[300];
final grey400=Colors.grey[400];
final grey700=Colors.grey[700];
final grey800=Colors.grey[800];
final grey600=Colors.grey[600];
final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.grey[100],
  textTheme: const TextTheme(
      displayLarge:(TextStyle(color: Colors.black87)),
      displayMedium: (TextStyle(color: Colors.black87)),
      displaySmall:(TextStyle(color: Colors.black87)),
      labelLarge:(TextStyle(color: Colors.black87)),
      labelMedium:(TextStyle(color: Colors.black87)),
      labelSmall:(TextStyle(color: Colors.black87)),
      headlineLarge:(TextStyle(color: Colors.black87)),
      headlineMedium:(TextStyle(color: Colors.black87)),
      headlineSmall:(TextStyle(color: Colors.black87)),
      titleLarge:(TextStyle(color: Colors.black87)),
      titleMedium:(TextStyle(color: Colors.black87)),
      titleSmall:(TextStyle(color: Colors.black87)),
      bodyLarge: (TextStyle(color: Colors.black54)),
      bodyMedium:(TextStyle(color: Colors.black54)),
      bodySmall: (TextStyle(color: Colors.black54))
  ),
  brightness: Brightness.light,
  shadowColor: Colors.grey[300],
  cardColor: Colors.black87,
  unselectedWidgetColor: Colors.black54,
  fontFamily: "Montserrat",
  buttonTheme:  ButtonThemeData(
    buttonColor: Colors.grey[100],
    textTheme: ButtonTextTheme.primary
  ),

);

final ThemeData darkTheme = ThemeData(
  textTheme: const TextTheme(
    displayLarge:(TextStyle(color: Colors.white70)),
      displayMedium: (TextStyle(color: Colors.white70)),
      displaySmall:(TextStyle(color: Colors.white70)),
      labelLarge:(TextStyle(color: Colors.white70)),
      labelMedium:(TextStyle(color: Colors.white70)),
      labelSmall:(TextStyle(color: Colors.white70)),
      headlineLarge:(TextStyle(color: Colors.white70)),
      headlineMedium:(TextStyle(color: Colors.white70)),
      headlineSmall:(TextStyle(color: Colors.white70)),
      titleLarge:(TextStyle(color: Colors.white70)),
      titleMedium:(TextStyle(color: Colors.white70)),
      titleSmall:(TextStyle(color: Colors.white70)),
      bodyLarge: (TextStyle(color: Colors.white54)),
      bodyMedium:(TextStyle(color: Colors.white54)),
      bodySmall: (TextStyle(color: Colors.white54)),
  ),
  shadowColor: Colors.grey[700],
  fontFamily: "Montserrat",
  cardColor: Colors.white70,
  unselectedWidgetColor: Colors.white54,
  brightness: Brightness.dark,
  buttonTheme:  ButtonThemeData(
    buttonColor: Colors.grey[900],
  ),
);