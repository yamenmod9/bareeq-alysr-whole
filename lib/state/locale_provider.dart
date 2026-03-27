import 'package:flutter/material.dart';

import '../services/session_store.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({required this.store});

  final SessionStore store;
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> restore() async {
    _locale = await store.loadLocale();
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await store.saveLocale(locale);
    notifyListeners();
  }

  Future<void> toggle() async {
    await setLocale(_locale.languageCode == 'en' ? const Locale('ar') : const Locale('en'));
  }
}
