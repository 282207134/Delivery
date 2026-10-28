import 'package:flutter/material.dart';

abstract final class DeliColors {
  static const green = Color(0xFF4D8052),
      sage = Color(0xFF80AA85),
      pale = Color(0xFFCDDFD0);
  static const cream = Color(0xFFF1F5F1),
      yellow = Color(0xFFFFD374),
      ink = Color(0xFF384A4A);
  static const muted = Color(0xFF7B898A), coral = Color(0xFFFF614A);
}

ThemeData deliTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Mulish',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: DeliColors.green,
    primary: DeliColors.green,
    secondary: DeliColors.yellow,
    surface: Colors.white,
    onSurface: DeliColors.ink,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: DeliColors.ink),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    foregroundColor: DeliColors.ink,
    elevation: 0,
    centerTitle: false,
    titleSpacing: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Mulish',
      fontSize: 17,
      color: DeliColors.ink,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: DeliColors.muted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DeliColors.cream),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DeliColors.cream),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: DeliColors.sage),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: DeliColors.green,
      foregroundColor: Colors.white,
      minimumSize: const Size(48, 54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(
        fontFamily: 'Mulish',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: DeliColors.cream,
    thickness: 1,
    space: 24,
  ),
);
