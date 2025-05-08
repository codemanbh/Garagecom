import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  bool _darkMode = false;
  bool get darkMode => _darkMode;

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void setToDarkMode() {
    _darkMode = true;
  }

  void setToLightMode() {
    _darkMode = false;
    notifyListeners();
  }
}
