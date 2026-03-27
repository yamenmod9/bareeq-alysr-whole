import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/app_components.dart';
import 'features/admin/admin_pages.dart';
import 'features/auth/auth_pages.dart';
import 'features/customer/customer_pages.dart';
import 'features/merchant/merchant_pages.dart';
import 'l10n/app_localizations.dart';
import 'services/api_client.dart';
import 'services/session_store.dart';
import 'state/auth_provider.dart';
import 'state/feature_providers.dart';
import 'state/locale_provider.dart';
import 'state/theme_provider.dart';

void main() {
  runApp(const BareeqApp());
}

class BareeqApp extends StatelessWidget {
  const BareeqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionStore = SessionStore();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(store: sessionStore),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(store: sessionStore),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(store: sessionStore),
        ),
        ProxyProvider<AuthProvider, ApiClient>(
          update: (_, auth, previous) => ApiClient(token: auth.session?.token),
        ),
        ChangeNotifierProvider(create: (_) => CustomerDashboardProvider()),
        ChangeNotifierProvider(create: (_) => CustomerRequestsProvider()),
        ChangeNotifierProvider(create: (_) => CustomerTransactionsProvider()),
        ChangeNotifierProvider(create: (_) => MerchantRequestsProvider()),
        ChangeNotifierProvider(create: (_) => MerchantSettlementsProvider()),
        ChangeNotifierProvider(create: (_) => AdminStatsProvider()),
      ],
      child: const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LocaleProvider>().restore();
      if (!mounted) return;
      await context.read<ThemeProvider>().restore();
      if (!mounted) return;
      await context.read<AuthProvider>().restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bareeq Alysr',
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return AppLocalizationsProvider(
          localizations: AppLocalizations(localeProvider.locale),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProvider.themeMode,
      onGenerateRoute: _routeFactory,
      initialRoute: '/',
    );
  }

  Route<dynamic> _routeFactory(RouteSettings settings) {
    final auth = context.read<AuthProvider>();
    final route = settings.name ?? '/';

    final publicRoutes = {'/', '/login', '/register'};
    final isPublic = publicRoutes.contains(route);
    final isAuth = auth.isAuthenticated;

    if (!isAuth && !isPublic) {
      return _material(const LoginPage(), const RouteSettings(name: '/login'));
    }

    if (isAuth && (route == '/login' || route == '/register' || route == '/')) {
      return _material(
        _homeForRole(auth.role),
        RouteSettings(name: _homeRouteForRole(auth.role)),
      );
    }

    if (route.startsWith('/customer/') && auth.role != 'customer') {
      return _material(
        _homeForRole(auth.role),
        RouteSettings(name: _homeRouteForRole(auth.role)),
      );
    }
    if (route.startsWith('/merchant/') && auth.role != 'merchant') {
      return _material(
        _homeForRole(auth.role),
        RouteSettings(name: _homeRouteForRole(auth.role)),
      );
    }
    if (route.startsWith('/admin/') && auth.role != 'admin') {
      return _material(
        _homeForRole(auth.role),
        RouteSettings(name: _homeRouteForRole(auth.role)),
      );
    }

    switch (route) {
      case '/':
        return _material(const SplashPage(), settings);
      case '/login':
        return _material(const LoginPage(), settings);
      case '/register':
        return _material(const RegisterPage(), settings);

      case '/customer/dashboard':
        return _protected(
          settings,
          const CustomerDashboardPage(),
          'Dashboard',
          'Credit, requests, and transactions',
        );
      case '/customer/requests':
        return _protected(
          settings,
          const CustomerAcceptPurchasePage(),
          'Accept Purchase',
          'Review pending purchase requests',
        );
      case '/customer/transactions':
        return _protected(
          settings,
          const CustomerTransactionsPage(),
          'My Transactions',
          'Search and manage transactions',
        );
      case '/customer/repayments':
        return _protected(
          settings,
          const CustomerRepaymentsPage(),
          'Repayments',
          'Plans and installment schedule',
        );
      case '/customer/payment':
        return _protected(
          settings,
          const CustomerPaymentPage(),
          'Payment',
          'Make a payment and get receipt details',
        );
      case '/customer/settings':
        return _protected(
          settings,
          const CustomerSettingsPage(),
          'Settings',
          'Profile, security, and preferences',
        );

      case '/merchant/dashboard':
        return _protected(
          settings,
          const MerchantDashboardPage(),
          'Dashboard',
          'Requests, settlements, and quick actions',
        );
      case '/merchant/send-request':
        return _protected(
          settings,
          const MerchantSendRequestPage(),
          'Send Request',
          'Lookup customer and send purchase request',
        );
      case '/merchant/requests':
        return _protected(
          settings,
          const MerchantPurchaseRequestsPage(),
          'Purchase Requests',
          'Track and filter purchase requests',
        );
      case '/merchant/transactions':
        return _protected(
          settings,
          const MerchantTransactionsPage(),
          'Transactions',
          'View transaction details and status',
        );
      case '/merchant/settlements':
        return _protected(
          settings,
          const MerchantSettlementsPage(),
          'Settlements',
          'Review settlements and request withdrawal',
        );
      case '/merchant/settings':
        return _protected(
          settings,
          const MerchantSettingsPage(),
          'Settings',
          'Profile, banking, and branches',
        );

      case '/admin/dashboard':
        return _protected(
          settings,
          const AdminDashboardPage(),
          'Admin Dashboard',
          'System KPIs and activity',
        );
      case '/admin/users':
        return _protected(
          settings,
          const AdminUsersPage(),
          'Users',
          'Role and status management',
        );
      case '/admin/customers':
        return _protected(
          settings,
          const AdminCustomersPage(),
          'Customers',
          'Credit and customer status oversight',
        );
      case '/admin/merchants':
        return _protected(
          settings,
          const AdminMerchantsPage(),
          'Merchants',
          'Merchant performance and moderation',
        );
      case '/admin/transactions':
        return _protected(
          settings,
          const AdminTransactionsPage(),
          'Transactions',
          'System transaction tracking',
        );
      case '/admin/settlements':
        return _protected(
          settings,
          const AdminSettlementsPage(),
          'Settlements',
          'Settlement operations and monitoring',
        );
      case '/admin/settings':
        return _protected(
          settings,
          const AdminSettingsPage(),
          'Settings',
          'Profile and system preferences',
        );
      default:
        return _material(
          _homeForRole(auth.role),
          RouteSettings(name: _homeRouteForRole(auth.role)),
        );
    }
  }

  MaterialPageRoute<dynamic> _material(Widget child, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }

  MaterialPageRoute<dynamic> _protected(
    RouteSettings settings,
    Widget page,
    String title,
    String subtitle,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        final auth = context.watch<AuthProvider>();
        final l10n = AppLocalizations.of(context);
        final role = auth.role;
        final localeProvider = context.read<LocaleProvider>();
        final themeProvider = context.read<ThemeProvider>();
        return AppScaffold(
          title: title,
          subtitle: subtitle,
          currentRoute: settings.name ?? _homeRouteForRole(role),
          roleMenuItems: _menuForRole(role),
          body: page,
          onLogout: () async {
            await auth.logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            }
          },
          onSetLanguage: (locale) => localeProvider.setLocale(locale),
          onToggleTheme: () => themeProvider.toggleMode(),
          onOpenProfile: () {
            final profileRoute = _settingsRouteForRole(role);
            if ((settings.name ?? '') != profileRoute) {
              Navigator.pushReplacementNamed(context, profileRoute);
            }
          },
          breadcrumb: l10n.t('appTitle'),
        );
      },
    );
  }

  Widget _homeForRole(String role) {
    if (role == 'customer') return const CustomerDashboardPage();
    if (role == 'merchant') return const MerchantDashboardPage();
    return const AdminDashboardPage();
  }

  String _homeRouteForRole(String role) {
    if (role == 'customer') return '/customer/dashboard';
    if (role == 'merchant') return '/merchant/dashboard';
    return '/admin/dashboard';
  }

  String _settingsRouteForRole(String role) {
    if (role == 'customer') return '/customer/settings';
    if (role == 'merchant') return '/merchant/settings';
    return '/admin/settings';
  }

  List<RoleMenuItem> _menuForRole(String role) {
    if (role == 'customer') {
      return const [
        RoleMenuItem(
          label: 'Dashboard',
          route: '/customer/dashboard',
          icon: Icons.dashboard_outlined,
        ),
        RoleMenuItem(
          label: 'Accept Purchase',
          route: '/customer/requests',
          icon: Icons.playlist_add_check_circle_outlined,
        ),
        RoleMenuItem(
          label: 'Transactions',
          route: '/customer/transactions',
          icon: Icons.receipt_long_outlined,
        ),
        RoleMenuItem(
          label: 'Repayments',
          route: '/customer/repayments',
          icon: Icons.calendar_month_outlined,
        ),
        RoleMenuItem(
          label: 'Payment',
          route: '/customer/payment',
          icon: Icons.payments_outlined,
        ),
        RoleMenuItem(
          label: 'Settings',
          route: '/customer/settings',
          icon: Icons.settings_outlined,
        ),
      ];
    }
    if (role == 'merchant') {
      return const [
        RoleMenuItem(
          label: 'Dashboard',
          route: '/merchant/dashboard',
          icon: Icons.dashboard_outlined,
        ),
        RoleMenuItem(
          label: 'Send Request',
          route: '/merchant/send-request',
          icon: Icons.send_outlined,
        ),
        RoleMenuItem(
          label: 'Requests',
          route: '/merchant/requests',
          icon: Icons.request_page_outlined,
        ),
        RoleMenuItem(
          label: 'Transactions',
          route: '/merchant/transactions',
          icon: Icons.receipt_outlined,
        ),
        RoleMenuItem(
          label: 'Settlements',
          route: '/merchant/settlements',
          icon: Icons.account_balance_wallet_outlined,
        ),
        RoleMenuItem(
          label: 'Settings',
          route: '/merchant/settings',
          icon: Icons.settings_outlined,
        ),
      ];
    }
    return const [
      RoleMenuItem(
        label: 'Dashboard',
        route: '/admin/dashboard',
        icon: Icons.dashboard_outlined,
      ),
      RoleMenuItem(
        label: 'Users',
        route: '/admin/users',
        icon: Icons.groups_outlined,
      ),
      RoleMenuItem(
        label: 'Customers',
        route: '/admin/customers',
        icon: Icons.person_outline,
      ),
      RoleMenuItem(
        label: 'Merchants',
        route: '/admin/merchants',
        icon: Icons.storefront_outlined,
      ),
      RoleMenuItem(
        label: 'Transactions',
        route: '/admin/transactions',
        icon: Icons.receipt_long_outlined,
      ),
      RoleMenuItem(
        label: 'Settlements',
        route: '/admin/settlements',
        icon: Icons.account_balance_outlined,
      ),
      RoleMenuItem(
        label: 'Settings',
        route: '/admin/settings',
        icon: Icons.settings_outlined,
      ),
    ];
  }
}
