import 'package:flutter/material.dart';

class FluttterMidnightNeonTheme {
  FluttterMidnightNeonTheme._();

  // If you want to modify both themes at once, modify the colors below.

  static const Color _primaryColor = Color(0xFF6A71D7); // Soft indigo
  static const Color _primaryInverseColor = Color(0xFF4E56A6); // Muted blue
  static const Color _onSurfaceColor =
      Color.fromARGB(255, 236, 247, 250); // Light lavender
  static const Color _onSurfaceVariant = Color(0xFF8991CC); // Dusty periwinkle
  static const Color _onPrimaryColor =
      Color.fromARGB(255, 237, 239, 255); // Pale lavender
  static const Color _surfaceColor = Color(0xFF444B8A); // Dark indigo
  static const Color _backgroundColor = Color(0xFF393F72); // Deep blue-gray
  static const Color _onSecondaryColor =
      Color(0xFFE0E2FA); // Very light lavender
  static const Color _onBackgroundColor = Color(0xFFB4B8DA); // Soft gray-blue
  static const Color _secondaryColor =
      Color(0xFF787FBF); // Medium lavender blue
  static const Color _primaryContainer = Color(0xFF515785); // Deep muted indigo
  static const Color _errorColor = Color(0xFFBE7D9B); // Muted pinkish-red
  static const Color _onErrorColor = Color(0xFF3A324D); // Dark purple-gray

  // If you want to modify the light theme only, modify the colors below.

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: FluttterMidnightNeonTheme._primaryColor,
      background: FluttterMidnightNeonTheme._backgroundColor,
      primary: FluttterMidnightNeonTheme._primaryColor,
      secondary: FluttterMidnightNeonTheme._secondaryColor,
      inversePrimary: FluttterMidnightNeonTheme._primaryInverseColor,
      onSurface: FluttterMidnightNeonTheme._onSurfaceColor,
      surface: FluttterMidnightNeonTheme._surfaceColor,
      onSurfaceVariant: FluttterMidnightNeonTheme._onSurfaceVariant,
      onPrimary: FluttterMidnightNeonTheme._onPrimaryColor,
      onSecondary: FluttterMidnightNeonTheme._onSecondaryColor,
      onBackground: FluttterMidnightNeonTheme._onBackgroundColor,
      primaryContainer: FluttterMidnightNeonTheme._primaryContainer,
      error: FluttterMidnightNeonTheme._errorColor,
      onError: FluttterMidnightNeonTheme._onErrorColor,
    ),
  );

  // If you want to modify the dark theme only, modify the colors below.

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: FluttterMidnightNeonTheme._primaryColor,
      background: FluttterMidnightNeonTheme._backgroundColor,
      primary: FluttterMidnightNeonTheme._primaryColor,
      secondary: FluttterMidnightNeonTheme._secondaryColor,
      inversePrimary: FluttterMidnightNeonTheme._primaryInverseColor,
      onSurface: FluttterMidnightNeonTheme._onSurfaceColor,
      surface: FluttterMidnightNeonTheme._surfaceColor,
      onSurfaceVariant: FluttterMidnightNeonTheme._onSurfaceVariant,
      onPrimary: FluttterMidnightNeonTheme._onPrimaryColor,
      onSecondary: FluttterMidnightNeonTheme._onSecondaryColor,
      onBackground: FluttterMidnightNeonTheme._onBackgroundColor,
      primaryContainer: FluttterMidnightNeonTheme._primaryContainer,
      error: FluttterMidnightNeonTheme._errorColor,
      onError: FluttterMidnightNeonTheme._onErrorColor,
    ),
  );
}

// A custom theme by Ivan Robayo | Check out FlutterCustomThemesVol1 for more.
// GitHub: @navirobayo 
