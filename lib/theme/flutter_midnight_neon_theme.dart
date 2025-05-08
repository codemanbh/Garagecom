import 'package:flutter/material.dart';

class FlutterMidnightNeonTheme {
  FlutterMidnightNeonTheme._();

  // Global color definitions used in both light and dark themes.

  // Primary accent: Electric Purple
  static const Color _primaryColor = Color(0xFF7F5AF0);
  // Darker variant of primary for contrast elements
  static const Color _primaryInverseColor = Color(0xFF553C9A);
  // Text and icon color for surfaces
  static const Color _onSurfaceColor = Color(0xFFE0E0E0);
  // Secondary text/icon color on surfaces
  static const Color _onSurfaceVariant = Color(0xFFB0B0B0);
  // Contrast color for text/icons on primary elements
  static const Color _onPrimaryColor = Color(0xFFFFFFFF);
  // Surface color for cards, sheets, etc.
  static const Color _surfaceColor = Color(0xFF1F1F1F);
  // Background color of the app (near-black)
  static const Color _backgroundColor = Color(0xFF121212);
  // Secondary accent: Neon Teal
  static const Color _secondaryColor = Color(0xFF64FFDA);
  // Contrast color for secondary elements (used here as dark text)
  static const Color _onSecondaryColor = Color(0xFF000000);
  // Text color on the background
  static const Color _onBackgroundColor = Color(0xFFCCCCCC);
  // Muted version of primary used for containers
  static const Color _primaryContainer = Color(0xFF4B3B6D);
  // Error color (inspired by Material dark error)
  static const Color _errorColor = Color(0xFFCF6679);
  // Text/icon color on error elements
  static const Color _onErrorColor = Color(0xFF000000);

  // Light theme (can be adjusted separately if needed)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: _primaryColor,
      background: _backgroundColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      inversePrimary: _primaryInverseColor,
      onSurface: _onSurfaceColor,
      surface: _surfaceColor,
      onSurfaceVariant: _onSurfaceVariant,
      onPrimary: _onPrimaryColor,
      onSecondary: _onSecondaryColor,
      onBackground: _onBackgroundColor,
      primaryContainer: _primaryContainer,
      error: _errorColor,
      onError: _onErrorColor,
    ),
  );

  // Dark theme designed for dark mode with high contrast and vibrant accents.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: _primaryColor,
      background: _backgroundColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      inversePrimary: _primaryInverseColor,
      onSurface: _onSurfaceColor,
      surface: _surfaceColor,
      onSurfaceVariant: _onSurfaceVariant,
      onPrimary: _onPrimaryColor,
      onSecondary: _onSecondaryColor,
      onBackground: _onBackgroundColor,
      primaryContainer: _primaryContainer,
      error: _errorColor,
      onError: _onErrorColor,
    ),
  );
}
