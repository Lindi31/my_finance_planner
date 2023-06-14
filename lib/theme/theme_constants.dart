import 'package:flutter/material.dart';

const COLOR_PRIMARY = Colors.deepOrangeAccent;

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: COLOR_PRIMARY,
    fontFamily: "Montserrat");

ThemeData darkTheme = ThemeData(
  fontFamily: "Montserrat",
  brightness: Brightness.dark,
  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.all<Color>(Colors.grey),
    thumbColor: MaterialStateProperty.all<Color>(Colors.white),
  ),
);
