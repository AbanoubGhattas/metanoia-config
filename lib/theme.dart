import 'package:flutter/material.dart';

const kBG      = Color(0xFF0E0E0E);
const kBG2     = Color(0xFF161616);
const kBG3     = Color(0xFF1E1E1E);
const kBorder  = Color(0xFF2E2E2E);
const kFG      = Color(0xFFE8E8E8);
const kFGDim   = Color(0xFF888888);
const kOrange  = Color(0xFFFF8C00);
const kOrange2 = Color(0xFFFFAA33);
const kGreen   = Color(0xFF4CAF50);
const kRed     = Color(0xFFF44336);
const kBlue    = Color(0xFF2A7FFF);
const kCyan    = Color(0xFF00BCD4);

const kMono = TextStyle(fontFamily: 'monospace', color: kFG);

ThemeData buildTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBG,
  colorScheme: const ColorScheme.dark(
    primary: kOrange,
    secondary: kOrange2,
    surface: kBG2,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kBG,
    foregroundColor: kFG,
    elevation: 0,
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: kOrange,
    unselectedLabelColor: kFGDim,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: kOrange, width: 2),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kBG3,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: kOrange),
    ),
    labelStyle: const TextStyle(color: kFGDim, fontFamily: 'monospace'),
    hintStyle: const TextStyle(color: kFGDim, fontFamily: 'monospace'),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kOrange,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  ),
  dividerColor: kBorder,
);
