// lib/models/settings_state_model.dart (The Complete Model)

import 'package:flutter/material.dart';

class SettingsStateModel with ChangeNotifier {
  // ------------------------------------
  // 1. APPEARANCE SETTINGS (INCLUDES fontSizeScale)
  // ------------------------------------
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;

  // 💥 MISSING GETTER FIX: Add the private variable and the public getter.
  double _fontSizeScale = 1.0;
  double get fontSizeScale => _fontSizeScale;

  // ------------------------------------
  // 2. DATE & TIME SETTINGS
  // ------------------------------------
  bool _is24HourFormat = true;
  bool get is24HourFormat => _is24HourFormat;

  int _startDayOfWeek = DateTime.monday;
  int get startDayOfWeek => _startDayOfWeek;

  // ------------------------------------
  // --- 3. SETTERS (Required to update the state) ---
  // ------------------------------------

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  // 💥 MISSING SETTER FIX: Add the setter for fontSizeScale.
  void setFontSizeScale(double scale) {
    _fontSizeScale = scale;
    notifyListeners();
  }

  void toggleTimeFormat() {
    _is24HourFormat = !_is24HourFormat;
    notifyListeners();
  }

  void setStartDayOfWeek(int day) {
    _startDayOfWeek = day;
    notifyListeners();
  }
}
