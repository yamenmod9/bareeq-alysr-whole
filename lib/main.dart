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
import 'services/notification_service.dart';
import 'services/session_store.dart';
import 'state/auth_provider.dart';
import 'state/feature_providers.dart';
import 'state/locale_provider.dart';
import 'state/notification_provider.dart';
import 'state/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  await NotificationService().requestPermissions();
  
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
        ChangeNotifierProvider(
          create: (_) => InAppNotificationProvider(),
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
      if (!mounted) return;
      await context.read<InAppNotificationProvider>().load();
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
          'dashboard',
          'creditRequestsTransactions',
        );
      case '/customer/requests':
        return _protected(
          settings,
          const CustomerAcceptPurchasePage(),
          'acceptPurchase',
          'reviewPendingRequests',
        );
      case '/customer/transactions':
        return _protected(
          settings,
          const CustomerTransactionsPage(),
          'myTransactions',
          'searchManageTransactions',
        );
      case '/customer/repayments':
        return _protected(
          settings,
          const CustomerRepaymentsPage(),
          'repayments',
          'plansInstallmentSchedule',
        );
      case '/customer/payment':
        return _protected(
          settings,
          const CustomerPaymentPage(),
          'payment',
          'makePaymentGetReceipt',
        );
      case '/customer/settings':
        return _protected(
          settings,
          const CustomerSettingsPage(),
          'settings',
          'profileSecurityPreferences',
        );

      case '/merchant/dashboard':
        return _protected(
          settings,
          const MerchantDashboardPage(),
          'dashboard',
          'quickActions',
        );
      case '/merchant/send-request':
        return _protected(
          settings,
          const MerchantSendRequestPage(),
          'sendRequest',
          'lookupCustomerSendRequest',
        );
      case '/merchant/requests':
        return _protected(
          settings,
          const MerchantPurchaseRequestsPage(),
          'purchaseRequests',
          'trackFilterRequests',
        );
      case '/merchant/transactions':
        return _protected(
          settings,
          const MerchantTransactionsPage(),
          'transactions',
          'viewTransactionDetails',
        );
      case '/merchant/settlements':
        return _protected(
          settings,
          const MerchantSettlementsPage(),
          'settlements',
          'reviewSettlementsRequest',
        );
      case '/merchant/settings':
        return _protected(
          settings,
          const MerchantSettingsPage(),
          'settings',
          'profileSecurityPreferences',
        );

      case '/admin/dashboard':
        return _protected(
          settings,
          const AdminDashboardPage(),
          'adminDashboard',
          'systemKPIsActivity',
        );
      case '/admin/users':
        return _protected(
          settings,
          const AdminUsersPage(),
          'users',
          'roleStatusManagement',
        );
      case '/admin/customers':
        return _protected(
          settings,
          const AdminCustomersPage(),
          'customers',
          'creditCustomerOversight',
        );
      case '/admin/merchants':
        return _protected(
          settings,
          const AdminMerchantsPage(),
          'merchants',
          'merchantPerformanceModeration',
        );
      case '/admin/transactions':
        return _protected(
          settings,
          const AdminTransactionsPage(),
          'transactions',
          'viewTransactionDetails',
        );
      case '/admin/settlements':
        return _protected(
          settings,
          const AdminSettlementsPage(),
          'settlements',
          'settlementOperationsMonitoring',
        );
      case '/admin/settings':
        return _protected(
          settings,
          const AdminSettingsPage(),
          'settings',
          'profileSecurityPreferences',
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
    String titleKey,
    String subtitleKey,
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
          title: l10n.t(titleKey),
          subtitle: l10n.t(subtitleKey),
          currentRoute: settings.name ?? _homeRouteForRole(role),
          roleMenuItems: _menuForRole(role, context),
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

  List<RoleMenuItem> _menuForRole(String role, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (role == 'customer') {
      return [
        RoleMenuItem(
          label: l10n.t('dashboard'),
          route: '/customer/dashboard',
          icon: Icons.dashboard_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('acceptPurchase'),
          route: '/customer/requests',
          icon: Icons.playlist_add_check_circle_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('transactions'),
          route: '/customer/transactions',
          icon: Icons.receipt_long_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('repayments'),
          route: '/customer/repayments',
          icon: Icons.calendar_month_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('payment'),
          route: '/customer/payment',
          icon: Icons.payments_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('settings'),
          route: '/customer/settings',
          icon: Icons.settings_outlined,
        ),
      ];
    }
    if (role == 'merchant') {
      return [
        RoleMenuItem(
          label: l10n.t('dashboard'),
          route: '/merchant/dashboard',
          icon: Icons.dashboard_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('sendRequest'),
          route: '/merchant/send-request',
          icon: Icons.send_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('requests'),
          route: '/merchant/requests',
          icon: Icons.request_page_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('transactions'),
          route: '/merchant/transactions',
          icon: Icons.receipt_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('settlements'),
          route: '/merchant/settlements',
          icon: Icons.account_balance_wallet_outlined,
        ),
        RoleMenuItem(
          label: l10n.t('settings'),
          route: '/merchant/settings',
          icon: Icons.settings_outlined,
        ),
      ];
    }
    return [
      RoleMenuItem(
        label: l10n.t('dashboard'),
        route: '/admin/dashboard',
        icon: Icons.dashboard_outlined,
      ),
      RoleMenuItem(
        label: l10n.t('users'),
        route: '/admin/users',
        icon: Icons.groups_outlined,
      ),
      RoleMenuItem(
        label: l10n.t('customers'),
        route: '/admin/customers',
        icon: Icons.person_outline,
      ),
      RoleMenuItem(
        label: l10n.t('merchants'),
        route: '/admin/merchants',
        icon: Icons.storefront_outlined,
      ),
      RoleMenuItem(
        label: l10n.t('transactions'),
        route: '/admin/transactions',
        icon: Icons.receipt_long_outlined,
      ),
      RoleMenuItem(
        label: l10n.t('settlements'),
        route: '/admin/settlements',
        icon: Icons.account_balance_outlined,
      ),
      RoleMenuItem(
        label: l10n.t('settings'),
        route: '/admin/settings',
        icon: Icons.settings_outlined,
      ),
    ];
  }
}
