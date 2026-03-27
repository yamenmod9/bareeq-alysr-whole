import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/app_components.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../state/auth_provider.dart';
import '../../state/feature_providers.dart';
import '../../state/locale_provider.dart';
import '../../state/theme_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  double _kpiAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1.34;
    if (width < 420) return 1.54;
    if (width < 900) return 1.7;
    return 1.82;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStatsProvider>().fetch(context.read<ApiClient>());
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<AdminStatsProvider>().state;
    if (state.loading) return const LoadingSkeletonList();
    if (state.error != null)
      return ErrorStateCard(
        message: state.error!,
        onRetry: () =>
            context.read<AdminStatsProvider>().fetch(context.read<ApiClient>()),
      );
    final d = state.data ?? {};
    final totalUsers = (d['total_users'] as num?)?.toInt() ?? 0;
    final totalCustomers = (d['total_customers'] as num?)?.toInt() ?? 0;
    final totalMerchants = (d['total_merchants'] as num?)?.toInt() ?? 0;
    final totalTransactions = (d['total_transactions'] as num?)?.toInt() ?? 0;
    final pendingSettlements = (d['pending_settlements'] as num?)?.toInt() ?? 0;
    final approvalRate = totalTransactions == 0
        ? 0
        : ((totalTransactions - pendingSettlements) / totalTransactions) * 100;
    final operational = pendingSettlements <= 5
        ? 'Operational'
        : 'Review needed';

    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF000000), Color(0xFF131B2E)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform command center',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${approvalRate.toStringAsFixed(1)}% approval health',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'System status: $operational',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF89F5E7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  color: Color(0xFF89F5E7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: _kpiAspectRatio(context),
          children: [
            KpiCard(
              label: 'Total users',
              value: '$totalUsers',
              icon: Icons.groups_outlined,
            ),
            KpiCard(
              label: 'Total customers',
              value: '$totalCustomers',
              icon: Icons.person_outline,
            ),
            KpiCard(
              label: 'Total merchants',
              value: '$totalMerchants',
              icon: Icons.storefront_outlined,
            ),
            KpiCard(
              label: 'Total transactions',
              value: '$totalTransactions',
              icon: Icons.receipt_long_outlined,
            ),
            KpiCard(
              label: 'Pending settlements',
              value: '$pendingSettlements',
              icon: Icons.account_balance_outlined,
            ),
            KpiCard(
              label: 'Platform commission',
              value: formatSar(d['platform_commission']),
              icon: Icons.savings_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            Widget signalsCard() {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Platform signals',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.group_outlined),
                          title: const Text('User to customer ratio'),
                          subtitle: Text(
                            totalCustomers == 0
                                ? 'No customer data yet'
                                : '${(totalUsers / totalCustomers).toStringAsFixed(2)} users/customer',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.pending_actions_outlined),
                          title: const Text('Pending settlements load'),
                          subtitle: Text(
                            totalTransactions == 0
                                ? 'No transactions yet'
                                : '${((pendingSettlements / totalTransactions) * 100).toStringAsFixed(2)}% of transactions',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.health_and_safety_outlined),
                          title: const Text('Operational status'),
                          subtitle: Text(operational),
                          trailing: StatusChip(operational),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget snapshotCard() {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network snapshot',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Merchant coverage',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalMerchants active merchants',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer footprint',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalCustomers registered customers',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Platform commission',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatSar(d['platform_commission']),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (constraints.maxWidth > 980) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: signalsCard()),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: snapshotCard()),
                ],
              );
            }
            return Column(
              children: [
                signalsCard(),
                const SizedBox(height: 12),
                snapshotCard(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  bool loading = true;
  String? error;
  List<dynamic> rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      rows = await context.read<ApiClient>().adminUsers();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);

    final total = rows.length;
    final active = rows.where((e) => e['is_active'] == true).length;
    final suspended = total - active;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Chip(label: Text('Total users: $total')),
                Chip(label: Text('Active: $active')),
                Chip(
                  backgroundColor: suspended > 0
                      ? scheme.errorContainer
                      : scheme.surfaceContainerLow,
                  label: Text(
                    'Suspended: $suspended',
                    style: TextStyle(
                      color: suspended > 0
                          ? scheme.onErrorContainer
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        PaginatedDataTableCard(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Active')),
          ],
          rows: rows
              .map(
                (e) => DataRow(
                  cells: [
                    DataCell(Text(e['id'].toString())),
                    DataCell(Text(e['full_name']?.toString() ?? '-')),
                    DataCell(Text(e['email']?.toString() ?? '-')),
                    DataCell(Text(e['role']?.toString() ?? '-')),
                    DataCell(
                      StatusChip(
                        e['is_active'] == true ? 'active' : 'suspended',
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  bool loading = true;
  String? error;
  List<dynamic> rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      rows = await context.read<ApiClient>().adminCustomers();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);

    return ListView(
      children: rows
          .map(
            (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (e['customer_code'] ?? e['id']).toString(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Limit ${formatSar(e['credit_limit'])} • Available ${formatSar(e['available_balance'])}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(e['status']?.toString() ?? '-'),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class AdminMerchantsPage extends StatefulWidget {
  const AdminMerchantsPage({super.key});

  @override
  State<AdminMerchantsPage> createState() => _AdminMerchantsPageState();
}

class _AdminMerchantsPageState extends State<AdminMerchantsPage> {
  bool loading = true;
  String? error;
  List<dynamic> rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      rows = await context.read<ApiClient>().adminMerchants();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);

    return ListView(
      children: rows
          .map(
            (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['shop_name']?.toString() ?? 'Merchant',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Volume ${formatSar(e['total_volume'])}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(e['status']?.toString() ?? '-'),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  bool loading = true;
  String? error;
  List<dynamic> rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      rows = await context.read<ApiClient>().adminTransactions();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              'Live transaction stream from backend: ${rows.length} records',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 10),
        PaginatedDataTableCard(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Merchant')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Remaining')),
            DataColumn(label: Text('Status')),
          ],
          rows: rows
              .map(
                (e) => DataRow(
                  cells: [
                    DataCell(Text(e['id'].toString())),
                    DataCell(Text(e['customer_id']?.toString() ?? '-')),
                    DataCell(Text(e['merchant_id']?.toString() ?? '-')),
                    DataCell(Text(formatSar(e['total_amount']))),
                    DataCell(Text(formatSar(e['remaining_amount']))),
                    DataCell(StatusChip(e['status']?.toString() ?? '-')),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class AdminSettlementsPage extends StatefulWidget {
  const AdminSettlementsPage({super.key});

  @override
  State<AdminSettlementsPage> createState() => _AdminSettlementsPageState();
}

class _AdminSettlementsPageState extends State<AdminSettlementsPage> {
  bool loading = true;
  String? error;
  List<dynamic> rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      rows = await context.read<ApiClient>().adminSettlements();
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);

    return ListView(
      children: rows
          .map(
            (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settlement ${e['id']}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Net ${formatSar(e['net_amount'])} • Gross ${formatSar(e['gross_amount'])} • Commission ${formatSar(e['commission_amount'])}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(e['status']?.toString() ?? '-'),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool moderationAlerts = true;

  @override
  void initState() {
    super.initState();
    final user =
        context.read<AuthProvider>().session?.user ?? <String, dynamic>{};
    _nameCtrl = TextEditingController(
      text: (user['full_name'] ?? '').toString(),
    );
    _emailCtrl = TextEditingController(text: (user['email'] ?? '').toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    await context.read<AuthProvider>().updateProfileLocal({
      'full_name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile settings saved')));
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LocaleProvider>().locale;
    final theme = context.watch<ThemeProvider>().themeMode;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _profileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  AppFormField(
                    controller: _nameCtrl,
                    label: 'Full name',
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 8),
                  AppFormField(
                    controller: _emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v ?? '').contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppPrimaryButton(
                      label: 'Save profile',
                      onPressed: _saveProfile,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Card(
          child: SwitchListTile(
            value: moderationAlerts,
            onChanged: (value) => setState(() => moderationAlerts = value),
            title: const Text('Moderation alerts'),
            subtitle: const Text(
              'Notify on high-risk approvals and rejections',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(l10n.t('language')),
            subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
            trailing: const Icon(Icons.language),
            onTap: () => context.read<LocaleProvider>().toggle(),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(l10n.t('theme')),
            subtitle: Text(theme.name),
            trailing: const Icon(Icons.brightness_6),
            onTap: () => context.read<ThemeProvider>().toggleMode(),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(l10n.t('logout')),
            onTap: _logout,
          ),
        ),
      ],
    );
  }
}
