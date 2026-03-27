import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/app_components.dart';
import '../../l10n/app_localizations.dart';
import '../../state/auth_provider.dart';
import '../../state/locale_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.restore();
      if (!mounted) return;
      if (auth.isAuthenticated) {
        final role = auth.role;
        if (role == 'customer') {
          Navigator.pushReplacementNamed(context, '/customer/dashboard');
        } else if (role == 'merchant') {
          Navigator.pushReplacementNamed(context, '/merchant/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.t('appTitle'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text('v1.0.0'),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text.trim(), _password.text.trim());
    if (!mounted) return;

    if (ok) {
      if (auth.role == 'customer') {
        Navigator.pushReplacementNamed(context, '/customer/dashboard');
      } else if (auth.role == 'merchant') {
        Navigator.pushReplacementNamed(context, '/merchant/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final isMobile = MediaQuery.of(context).size.width < 700;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF071219),
                    const Color(0xFF0A161E),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    scheme.primary.withValues(alpha: 0.14),
                    scheme.secondary.withValues(alpha: 0.09),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 520 : 480),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 14 : 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.t('appTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          AppFormField(
                            controller: _email,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty || !value.contains('@')) return 'Enter valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          AppFormField(
                            controller: _password,
                            label: 'Password',
                            obscure: true,
                            validator: (v) => (v ?? '').isEmpty ? 'Password required' : null,
                          ),
                          const SizedBox(height: 12),
                          if (auth.error != null) Text(auth.error!, style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 8),
                          SizedBox(width: double.infinity, child: AppPrimaryButton(label: l10n.t('login'), onPressed: _submit)),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                                child: Text(l10n.t('register')),
                              ),
                              IconButton(
                                onPressed: () => context.read<LocaleProvider>().toggle(),
                                icon: const Icon(Icons.language),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _nationalId = TextEditingController();
  final _shop = TextEditingController();
  String _role = 'customer';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _nationalId.dispose();
    _shop.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      email: _email.text,
      password: _password.text,
      fullName: _name.text,
      role: _role,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      nationalId: _nationalId.text.trim().isEmpty ? null : _nationalId.text.trim(),
      shopName: _role == 'merchant' ? _shop.text.trim() : null,
    );

    if (!mounted) return;
    if (ok) {
      if (auth.role == 'customer') {
        Navigator.pushReplacementNamed(context, '/customer/dashboard');
      } else if (auth.role == 'merchant') {
        Navigator.pushReplacementNamed(context, '/merchant/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final isMobile = MediaQuery.of(context).size.width < 700;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF071219),
                    const Color(0xFF0A161E),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    scheme.primary.withValues(alpha: 0.14),
                    scheme.secondary.withValues(alpha: 0.09),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 560 : 560),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 14 : 18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.t('register'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          AppFormField(controller: _name, label: 'Full Name', validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null),
                          const SizedBox(height: 10),
                          AppFormField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress, validator: (v) => (v ?? '').contains('@') ? null : 'Invalid email'),
                          const SizedBox(height: 10),
                          AppFormField(controller: _password, label: 'Password', obscure: true, validator: (v) => (v ?? '').length < 8 ? 'Minimum 8 chars' : null),
                          const SizedBox(height: 10),
                          AppFormField(controller: _phone, label: 'Phone', keyboardType: TextInputType.phone),
                          const SizedBox(height: 10),
                          AppFormField(controller: _nationalId, label: 'National ID'),
                          const SizedBox(height: 10),
                          AppDropdownField<String>(
                            value: _role,
                            label: 'Role',
                            onChanged: (v) => setState(() => _role = v ?? 'customer'),
                            items: const [
                              DropdownMenuItem(value: 'customer', child: Text('Customer')),
                              DropdownMenuItem(value: 'merchant', child: Text('Merchant')),
                            ],
                          ),
                          if (_role == 'merchant') ...[
                            const SizedBox(height: 10),
                            AppFormField(controller: _shop, label: 'Shop Name', validator: (v) => (v ?? '').trim().isEmpty ? 'Required for merchant' : null),
                          ],
                          if (auth.error != null) ...[
                            const SizedBox(height: 8),
                            Text(auth.error!, style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 10),
                          SizedBox(width: double.infinity, child: AppPrimaryButton(label: l10n.t('register'), onPressed: _submit)),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: Text(l10n.t('login')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
