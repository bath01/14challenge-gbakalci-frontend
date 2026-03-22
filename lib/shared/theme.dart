import 'package:flutter/material.dart';

// ——— COULEURS ———
const Color ciOrange = Color(0xFFFF8C00);
const Color ciGreen  = Color(0xFF009E49);
const Color darkBg   = Color(0xFF0A0A0E);
const Color surface  = Color(0xFF131318);
const Color card     = Color(0xFF1A1A22);
const Color cardHover= Color(0xFF22222C);
const Color border   = Color(0xFF2A2A35);
const Color textP    = Color(0xFFF0EDE6);
const Color textS    = Color(0xFF888888);
const Color textDim  = Color(0xFF444444);

// ——— THÈME GLOBAL ———
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBg,
  colorScheme: const ColorScheme.dark(
    primary: ciOrange,
    secondary: ciGreen,
    surface: surface,
    onPrimary: Colors.white,
    onSurface: textP,
  ),
  fontFamily: 'DM Sans',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32, fontWeight: FontWeight.w800,
      color: textP, letterSpacing: -1,
    ),
    titleLarge: TextStyle(
      fontSize: 18, fontWeight: FontWeight.w800,
      color: textP, letterSpacing: -0.5,
    ),
    titleMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.w700,
      color: textP,
    ),
    bodyMedium: TextStyle(
      fontSize: 13, fontWeight: FontWeight.w400,
      color: textS,
    ),
    bodySmall: TextStyle(
      fontSize: 11, fontWeight: FontWeight.w400,
      color: textS,
    ),
    labelSmall: TextStyle(
      fontSize: 9, fontWeight: FontWeight.w600,
      color: textDim,
    ),
  ),
);