import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class SessionStore {
  static const String _sessionKey = 'auth_session';
  static const String _localeKey = 'app_locale';
  static const String _themeKey = 'app_theme_mode';
  static const String _sidebarExpandedKey = 'app_sidebar_expanded';

  Future<void> saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  Future<AuthSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSession.fromJson(map);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return Locale(prefs.getString(_localeKey) ?? 'en');
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeKey) ?? 'system';
    if (raw == 'dark') return ThemeMode.dark;
    if (raw == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> saveSidebarExpanded(bool expanded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sidebarExpandedKey, expanded);
  }

  Future<bool> loadSidebarExpanded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sidebarExpandedKey) ?? true;
  }
}
