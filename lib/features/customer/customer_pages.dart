import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/app_components.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../state/auth_provider.dart';
import '../../state/feature_providers.dart';
import '../../state/locale_provider.dart';
import '../../state/theme_provider.dart';

class CustomerDashboardPage extends StatefulWidget {
  const CustomerDashboardPage({super.key});

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  double _kpiAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1.34;
    if (width < 420) return 1.56;
    if (width < 900) return 1.72;
    return 1.84;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final api = context.read<ApiClient>();
      context.read<CustomerDashboardProvider>().fetch(api);
      context.read<CustomerRequestsProvider>().fetch(api);
      context.read<CustomerTransactionsProvider>().fetch(api);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dash = context.watch<CustomerDashboardProvider>().state;
    final requests = context.watch<CustomerRequestsProvider>().state;
    final tx = context.watch<CustomerTransactionsProvider>().state;

    if (dash.loading) {
      return const LoadingSkeletonList(count: 4);
    }
    if (dash.error != null) {
      return ErrorStateCard(
        message: dash.error!,
        onRetry: () => context.read<CustomerDashboardProvider>().fetch(
          context.read<ApiClient>(),
        ),
      );
    }

    final d = dash.data ?? {};
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available balance',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatSar(d['available_balance']),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(
                      'Outstanding ${formatSar(d['outstanding_balance'])}',
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.white),
                    side: BorderSide.none,
                  ),
                  Chip(
                    label: Text('Credit limit ${formatSar(d['credit_limit'])}'),
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: Colors.white),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: _kpiAspectRatio(context),
          children: [
            KpiCard(
              label: 'Credit limit',
              value: formatSar(d['credit_limit']),
              icon: Icons.speed_outlined,
            ),
            KpiCard(
              label: 'Available balance',
              value: formatSar(d['available_balance']),
              icon: Icons.account_balance_wallet_outlined,
            ),
            KpiCard(
              label: 'Outstanding',
              value: formatSar(d['outstanding_balance']),
              icon: Icons.payments_outlined,
            ),
            KpiCard(
              label: 'Active transactions',
              value: '${d['active_transactions'] ?? 0}',
              icon: Icons.receipt_long_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            Widget upcomingPanel() {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming payments',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (tx.loading)
                        const LoadingSkeletonList(count: 2)
                      else if ((tx.data ?? []).isEmpty)
                        const EmptyStateCard(message: 'No upcoming payments')
                      else
                        ...tx.data!
                            .take(4)
                            .map(
                              (e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    e['merchant_name']?.toString() ??
                                        'Merchant',
                                  ),
                                  subtitle: Text(
                                    'Remaining ${formatSar(e['remaining_amount'])}',
                                  ),
                                  trailing: StatusChip(
                                    e['status']?.toString() ?? 'pending',
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            }

            Widget requestsPanel() {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pending requests',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (requests.loading)
                        const LoadingSkeletonList(count: 2)
                      else if ((requests.data ?? []).isEmpty)
                        const EmptyStateCard(message: 'No pending requests')
                      else
                        ...requests.data!
                            .take(4)
                            .map(
                              (e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    e['merchant_name']?.toString() ??
                                        'Merchant',
                                  ),
                                  subtitle: Text(formatSar(e['amount'])),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
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
                  Expanded(child: upcomingPanel()),
                  const SizedBox(width: 12),
                  Expanded(child: requestsPanel()),
                ],
              );
            }
            return Column(
              children: [
                upcomingPanel(),
                const SizedBox(height: 12),
                requestsPanel(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CustomerAcceptPurchasePage extends StatelessWidget {
  const CustomerAcceptPurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerRequestsPage();
  }
}

class CustomerRequestsPage extends StatefulWidget {
  const CustomerRequestsPage({super.key});

  @override
  State<CustomerRequestsPage> createState() => _CustomerRequestsPageState();
}

class _CustomerRequestsPageState extends State<CustomerRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerRequestsProvider>().fetch(context.read<ApiClient>());
    });
  }

  Future<void> _accept(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmActionDialog(
        title: 'Accept request',
        message: 'Do you want to accept this request?',
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<ApiClient>().acceptPurchaseRequest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Request accepted')));
    context.read<CustomerRequestsProvider>().fetch(context.read<ApiClient>());
  }

  Future<void> _reject(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmActionDialog(
        title: 'Reject request',
        message: 'Do you want to reject this request?',
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<ApiClient>().rejectPurchaseRequest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Request rejected')));
    context.read<CustomerRequestsProvider>().fetch(context.read<ApiClient>());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<CustomerRequestsProvider>().state;
    if (state.loading) return const LoadingSkeletonList();
    if (state.error != null) {
      return ErrorStateCard(
        message: state.error!,
        onRetry: () => context.read<CustomerRequestsProvider>().fetch(
          context.read<ApiClient>(),
        ),
      );
    }
    final data = state.data ?? [];
    if (data.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 420,
          child: EmptyStateCard(message: 'No pending requests'),
        ),
      );
    }

    return ListView(
      children: data
          .map(
            (e) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            e['merchant_name']?.toString() ?? 'Merchant',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(e['status']?.toString() ?? 'pending'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatSar(e['amount']),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e['description']?.toString().trim().isEmpty ?? true
                                ? 'No description provided'
                                : e['description'].toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppPrimaryButton(
                          label: 'Accept',
                          onPressed: () => _accept(e['id'] as int),
                        ),
                        AppSecondaryButton(
                          label: 'Reject',
                          onPressed: () => _reject(e['id'] as int),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class CustomerTransactionsPage extends StatefulWidget {
  const CustomerTransactionsPage({super.key});

  @override
  State<CustomerTransactionsPage> createState() =>
      _CustomerTransactionsPageState();
}

class _CustomerTransactionsPageState extends State<CustomerTransactionsPage> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerTransactionsProvider>().fetch(
        context.read<ApiClient>(),
      );
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CustomerTransactionsProvider>().state;
    final all = state.data ?? [];
    final filtered = all.where((e) {
      final q = search.text.trim().toLowerCase();
      if (q.isEmpty) return true;
      return (e['merchant_name']?.toString().toLowerCase().contains(q) ??
              false) ||
          (e['transaction_number']?.toString().toLowerCase().contains(q) ??
              false);
    }).toList();

    if (state.loading) return const LoadingSkeletonList();
    if (state.error != null)
      return ErrorStateCard(
        message: state.error!,
        onRetry: () => context.read<CustomerTransactionsProvider>().fetch(
          context.read<ApiClient>(),
        ),
      );

    return ListView(
      children: [
        FilterBar(
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: search,
                decoration: const InputDecoration(
                  labelText: 'Search transactions',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            AppSecondaryButton(
              label: 'Reset filters',
              onPressed: () {
                search.clear();
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          const EmptyStateCard(message: 'No transactions found')
        else
          PaginatedDataTableCard(
            columns: const [
              DataColumn(label: Text('Transaction')),
              DataColumn(label: Text('Merchant')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Remaining')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Date')),
            ],
            rows: filtered
                .map(
                  (e) => DataRow(
                    cells: [
                      DataCell(
                        Text(
                          e['transaction_number']?.toString() ??
                              e['id'].toString(),
                        ),
                      ),
                      DataCell(Text(e['merchant_name']?.toString() ?? '-')),
                      DataCell(Text(formatSar(e['amount']))),
                      DataCell(Text(formatSar(e['remaining_amount']))),
                      DataCell(StatusChip(e['status']?.toString() ?? '-')),
                      DataCell(Text(formatDate(e['created_at']))),
                    ],
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class CustomerRepaymentsPage extends StatefulWidget {
  const CustomerRepaymentsPage({super.key});

  @override
  State<CustomerRepaymentsPage> createState() => _CustomerRepaymentsPageState();
}

class _CustomerRepaymentsPageState extends State<CustomerRepaymentsPage> {
  bool loading = true;
  String? error;
  List<dynamic> plans = const [];

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
      plans = await context.read<ApiClient>().customerRepaymentPlans();
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
    if (plans.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 420,
          child: EmptyStateCard(message: 'No repayment plans'),
        ),
      );
    }

    return ListView(
      children: plans
          .map(
            (p) => Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p['plan_months'] ?? '-'} months plan',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(p['status']?.toString() ?? '-'),
                      ],
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
                            'Total ${formatSar(p['total_amount'])}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Remaining ${formatSar(p['remaining_amount'])}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class CustomerPaymentPage extends StatefulWidget {
  const CustomerPaymentPage({super.key});

  @override
  State<CustomerPaymentPage> createState() => _CustomerPaymentPageState();
}

class _CustomerPaymentPageState extends State<CustomerPaymentPage> {
  List<dynamic> transactions = const [];
  bool loading = true;
  String? error;
  int? selectedTransactionId;
  final amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      transactions = await context.read<ApiClient>().customerTransactions();
      final active = transactions
          .where((e) => e['status'] == 'active')
          .toList();
      if (active.isNotEmpty) {
        selectedTransactionId = active.first['id'] as int;
        amountCtrl.text = (active.first['remaining_amount'] ?? '0').toString();
      }
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pay() async {
    if (selectedTransactionId == null) return;
    final amount = double.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid amount')));
      return;
    }
    try {
      await context.read<ApiClient>().payTransaction(
        transactionId: selectedTransactionId!,
        amount: amount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment successful')));
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);

    final active = transactions.where((e) => e['status'] == 'active').toList();
    if (active.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 420,
          child: EmptyStateCard(message: 'No active transactions to pay'),
        ),
      );
    }

    final selected = active.firstWhere(
      (e) => e['id'] == selectedTransactionId,
      orElse: () => active.first,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final remainingBefore =
            double.tryParse(selected['remaining_amount'].toString()) ?? 0;
        final entered = double.tryParse(amountCtrl.text) ?? 0;
        final remainingAfter = entered < remainingBefore
            ? (remainingBefore - entered)
            : 0;

        Widget paymentForm = Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment form',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: selectedTransactionId,
                  items: active
                      .map(
                        (e) => DropdownMenuItem<int>(
                          value: e['id'] as int,
                          child: Text(
                            'TXN ${e['transaction_number'] ?? e['id']}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedTransactionId = v;
                      final picked = active.firstWhere((e) => e['id'] == v);
                      amountCtrl.text = (picked['remaining_amount'] ?? '0')
                          .toString();
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Transaction'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppPrimaryButton(label: 'Pay now', onPressed: _pay),
                ),
              ],
            ),
          ),
        );

        Widget summary = Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summary', style: Theme.of(context).textTheme.titleMedium),
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
                        'Remaining before',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatSar(remainingBefore),
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
                        'Remaining after payment',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatSar(remainingAfter),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (constraints.maxWidth > 980) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: paymentForm),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: summary),
            ],
          );
        }

        return ListView(
          children: [paymentForm, const SizedBox(height: 12), summary],
        );
      },
    );
  }
}

class CustomerSettingsPage extends StatefulWidget {
  const CustomerSettingsPage({super.key});

  @override
  State<CustomerSettingsPage> createState() => _CustomerSettingsPageState();
}

class _CustomerSettingsPageState extends State<CustomerSettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool notificationsEnabled = true;
  bool codeBusy = false;
  String? customerCode;

  @override
  void initState() {
    super.initState();
    final user =
        context.read<AuthProvider>().session?.user ?? <String, dynamic>{};
    _nameCtrl = TextEditingController(
      text: (user['full_name'] ?? '').toString(),
    );
    _emailCtrl = TextEditingController(text: (user['email'] ?? '').toString());
    _phoneCtrl = TextEditingController(text: (user['phone'] ?? '').toString());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCustomerCode());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    await context.read<AuthProvider>().updateProfileLocal({
      'full_name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile settings saved')));
  }

  Future<void> _loadCustomerCode() async {
    setState(() => codeBusy = true);
    try {
      final data = await context.read<ApiClient>().customerProfile();
      customerCode = data['customer_code']?.toString();
    } on ApiException {
      customerCode = null;
    } finally {
      if (mounted) setState(() => codeBusy = false);
    }
  }

  Future<void> _regenerateCode() async {
    setState(() => codeBusy = true);
    try {
      final data = await context.read<ApiClient>().regenerateCustomerCode();
      customerCode = data['customer_code']?.toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New customer code: ${customerCode ?? '-'}')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => codeBusy = false);
    }
  }

  Future<void> _copyCode() async {
    final code = customerCode;
    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No code available to copy')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Customer code copied')));
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = context.watch<LocaleProvider>().locale;
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final l10n = AppLocalizations.of(context);

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    codeBusy ? 'Loading...' : (customerCode ?? 'Unavailable'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppSecondaryButton(
                      label: codeBusy ? 'Please wait...' : 'Regenerate code',
                      onPressed: codeBusy ? () {} : _regenerateCode,
                    ),
                    AppPrimaryButton(
                      label: 'Copy code',
                      onPressed: codeBusy ? () {} : _copyCode,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _profileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
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
                  const SizedBox(height: 8),
                  AppFormField(
                    controller: _phoneCtrl,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
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
            value: notificationsEnabled,
            onChanged: (value) => setState(() => notificationsEnabled = value),
            title: const Text('Notifications'),
            subtitle: const Text('Enable app notifications'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(l10n.t('language')),
            subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
            trailing: const Icon(Icons.language),
            onTap: () async {
              final selected = await showModalBottomSheet<String>(
                context: context,
                showDragHandle: true,
                builder: (_) => ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: const Text('English'),
                      subtitle: const Text('en'),
                      trailing: locale.languageCode == 'en'
                          ? const Icon(Icons.check)
                          : null,
                      dense: true,
                      onTap: () => Navigator.pop(context, 'en'),
                    ),
                    ListTile(
                      title: const Text('العربية'),
                      subtitle: const Text('ar'),
                      trailing: locale.languageCode == 'ar'
                          ? const Icon(Icons.check)
                          : null,
                      dense: true,
                      onTap: () => Navigator.pop(context, 'ar'),
                    ),
                  ],
                ),
              );
              if (selected == null) return;
              await context.read<LocaleProvider>().setLocale(Locale(selected));
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text(l10n.t('theme')),
            subtitle: Text(themeMode.name),
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
