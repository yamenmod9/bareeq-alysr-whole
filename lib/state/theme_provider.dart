import 'package:flutter/material.dart';

import '../services/session_store.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({required this.store});

  final SessionStore store;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> restore() async {
    _themeMode = await store.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await store.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> toggleMode() async {
    if (_themeMode == ThemeMode.system || _themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}
