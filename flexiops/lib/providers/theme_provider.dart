//provider/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Keys for shared preferences
  static const String _themePreferenceKey = 'theme_preference';
  
  // Default to system theme
  ThemeMode _themeMode = ThemeMode.system;
  
  // Constructor - Initialize by loading saved preferences
  ThemeProvider() {
    _loadThemePreference();
  }

  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;
  
  // Check if dark mode is active (considering system theme)
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Get system brightness using media query - not accessible in constructor
      // This will be used when accessed from build context
      final window = WidgetsBinding.instance.window;
      final brightness = window.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Check if dark mode is explicitly enabled (ignoring system)
  bool get isExplicitDarkMode => _themeMode == ThemeMode.dark;
  
  // Load saved theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePreferenceKey);
      
      if (savedTheme != null) {
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, default to system theme
      _themeMode = ThemeMode.system;
    }
  }
  
  // Save theme preference
  Future<void> _saveThemePreference(String themeValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, themeValue);
  }
  
  // Toggle between light and dark theme
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setDarkTheme();
    } else {
      setLightTheme();
    }
  }
  
  // Set light theme
  void setLightTheme() {
    _themeMode = ThemeMode.light;
    _saveThemePreference('light');
    notifyListeners();
  }
  
  // Set dark theme
  void setDarkTheme() {
    _themeMode = ThemeMode.dark;
    _saveThemePreference('dark');
    notifyListeners();
  }
  
  // Follow system theme
  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    _saveThemePreference('system');
    notifyListeners();
  }
}