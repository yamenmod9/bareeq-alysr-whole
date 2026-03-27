import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'appTitle': 'Bareeq Alysr',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'customer': 'Customer',
      'merchant': 'Merchant',
      'admin': 'Admin',
    },
    'ar': {
      'appTitle': 'بريق اليسر',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'light': 'فاتح',
      'dark': 'داكن',
      'system': 'حسب النظام',
      'customer': 'عميل',
      'merchant': 'تاجر',
      'admin': 'مشرف',
    },
  };

  String t(String key) {
    final lang = _strings[locale.languageCode] ?? _strings['en']!;
    return lang[key] ?? _strings['en']![key] ?? key;
  }

  static AppLocalizations of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_AppLocalizationsInherited>();
    return inherited!.localizations;
  }
}

class AppLocalizationsProvider extends StatelessWidget {
  const AppLocalizationsProvider({
    super.key,
    required this.localizations,
    required this.child,
  });

  final AppLocalizations localizations;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _AppLocalizationsInherited(localizations: localizations, child: child);
  }
}

class _AppLocalizationsInherited extends InheritedWidget {
  const _AppLocalizationsInherited({
    required this.localizations,
    required super.child,
  });

  final AppLocalizations localizations;

  @override
  bool updateShouldNotify(covariant _AppLocalizationsInherited oldWidget) {
    return oldWidget.localizations.locale != localizations.locale;
  }
}
