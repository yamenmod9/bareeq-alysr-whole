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

class MerchantDashboardPage extends StatefulWidget {
  const MerchantDashboardPage({super.key});

  @override
  State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
}

class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
  bool loading = true;
  String? error;
  Map<String, dynamic>? dashboard;
  List<dynamic> transactions = const [];

  double _kpiAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1.28;
    if (width < 640) return 1.58;
    if (width < 900) return 1.74;
    return 1.86;
  }

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
      final api = context.read<ApiClient>();
      dashboard = await api.merchantDashboard();
      await context.read<MerchantRequestsProvider>().fetch(api);
      await context.read<MerchantSettlementsProvider>().fetch(api);
      try {
        transactions = await api.merchantTransactions();
      } catch (_) {
        transactions = const [];
      }
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<double> _weeklyVolumes(List<dynamic> rows) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final totals = List<double>.filled(7, 0);

    for (final row in rows) {
      final createdAt = DateTime.tryParse((row['created_at'] ?? '').toString());
      if (createdAt == null) continue;
      if (createdAt.isBefore(monday) ||
          createdAt.isAfter(now.add(const Duration(days: 1))))
        continue;
      final idx = createdAt.weekday - 1;
      final amount =
          (row['amount'] as num?)?.toDouble() ??
          (row['total_amount'] as num?)?.toDouble() ??
          0;
      totals[idx] += amount;
    }
    return totals;
  }

  Map<String, int> _statusCounts(List<dynamic> rows) {
    final counts = <String, int>{'approved': 0, 'pending': 0, 'other': 0};
    for (final row in rows) {
      final status = (row['status'] ?? '').toString().toLowerCase();
      if (status.contains('approve') ||
          status.contains('paid') ||
          status.contains('complete')) {
        counts['approved'] = (counts['approved'] ?? 0) + 1;
      } else if (status.contains('pending') || status.contains('process')) {
        counts['pending'] = (counts['pending'] ?? 0) + 1;
      } else {
        counts['other'] = (counts['other'] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isPhone = width < 640;
    final kpiColumns = width >= 1100
        ? 4
        : (width >= 720 ? 3 : (width >= 360 ? 2 : 1));
    final requestState = context.watch<MerchantRequestsProvider>().state;
    final settlementState = context.watch<MerchantSettlementsProvider>().state;
    if (loading) return const LoadingSkeletonList(count: 4);
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);
    final d = dashboard ?? {};
    final statusCounts = _statusCounts(transactions);
    final weeklyVolumes = _weeklyVolumes(transactions);
    final maxWeeklyVolume = weeklyVolumes.fold<double>(
      0,
      (p, e) => e > p ? e : p,
    );
    final requestRows = requestState.data ?? const [];
    final approvedRequests = requestRows
        .where(
          (e) =>
              (e['status']?.toString().toLowerCase() ?? '').contains('approve'),
        )
        .length;
    final approvalRate = requestRows.isEmpty
        ? 0.0
        : (approvedRequests / requestRows.length) * 100;
    final settlementRows = settlementState.data ?? const [];
    final processedSettlements = settlementRows
        .where(
          (e) =>
              (e['status']?.toString().toLowerCase() ?? '').contains('process'),
        )
        .length;
    final settlementHealth = settlementRows.isEmpty
        ? 0.0
        : (processedSettlements / settlementRows.length) * 100;
    final summaryChipBg = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : const Color(0xFF89F5E7).withValues(alpha: 0.92);
    final summaryChipText = isDark ? Colors.white : const Color(0xFF00201D);

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
                'Settlement balance',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatSar(d['pending_settlement']),
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
                      'Total settled ${formatSar(d['total_settled'])}',
                    ),
                    backgroundColor: summaryChipBg,
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: summaryChipText),
                    side: BorderSide.none,
                  ),
                  Chip(
                    label: Text('Transactions ${d['total_transactions'] ?? 0}'),
                    backgroundColor: summaryChipBg,
                    labelStyle: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: summaryChipText),
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
          crossAxisCount: kpiColumns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: _kpiAspectRatio(context),
          children: [
            KpiCard(
              label: 'Request count',
              value: '${d['total_transactions'] ?? 0}',
              icon: Icons.request_page_outlined,
            ),
            KpiCard(
              label: 'Approved requests',
              value: '$approvedRequests',
              icon: Icons.task_alt_outlined,
            ),
            KpiCard(
              label: 'Settlement totals',
              value: formatSar(d['total_settled']),
              icon: Icons.assured_workload_outlined,
            ),
            KpiCard(
              label: 'Available settlement balance',
              value: formatSar(d['pending_settlement']),
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                if (isPhone)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/merchant/send-request',
                        ),
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Send'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/merchant/settlements',
                        ),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('Settlements'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/merchant/requests',
                        ),
                        icon: const Icon(Icons.search_outlined),
                        label: const Text('Requests'),
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/merchant/send-request',
                        ),
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('Send request'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/merchant/settlements',
                        ),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('View settlements'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/merchant/requests',
                        ),
                        icon: const Icon(Icons.search_outlined),
                        label: const Text('Review requests'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            Widget salesTrendCard() {
              const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales over time (7d)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transactions.isEmpty
                            ? 'Waiting for transaction history from backend'
                            : 'Based on live merchant transactions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 170,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (i) {
                            final value = weeklyVolumes[i];
                            final factor = maxWeeklyVolume <= 0
                                ? 0.08
                                : (value / maxWeeklyVolume).clamp(0.08, 1.0);
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      value <= 0 ? '-' : formatSar(value),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 120 * factor,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xFF89F5E7),
                                            scheme.surfaceContainerHigh,
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      labels[i],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            Widget qualityCard() {
              final totalStatuses = statusCounts.values.fold<int>(
                0,
                (p, e) => p + e,
              );
              final approvedShare = totalStatuses == 0
                  ? 0.0
                  : (statusCounts['approved']! / totalStatuses) * 100;
              final pendingShare = totalStatuses == 0
                  ? 0.0
                  : (statusCounts['pending']! / totalStatuses) * 100;

              Widget metricRow(String label, double value, Color color) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '${value.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: (value / 100).clamp(0, 1),
                        color: color,
                        backgroundColor: scheme.surfaceContainer,
                      ),
                    ),
                  ],
                );
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Performance quality',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      metricRow(
                        'Request approval rate',
                        approvalRate,
                        const Color(0xFF0C9488),
                      ),
                      const SizedBox(height: 10),
                      metricRow(
                        'Settlement processing health',
                        settlementHealth,
                        scheme.secondary,
                      ),
                      const SizedBox(height: 10),
                      metricRow(
                        'Transaction approvals in stream',
                        approvedShare,
                        const Color(0xFF89F5E7),
                      ),
                      const SizedBox(height: 10),
                      metricRow(
                        'Transaction pending share',
                        pendingShare,
                        scheme.error,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text('Approved ${statusCounts['approved']}'),
                          ),
                          Chip(
                            label: Text('Pending ${statusCounts['pending']}'),
                          ),
                          Chip(label: Text('Other ${statusCounts['other']}')),
                        ],
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
                  Expanded(flex: 3, child: salesTrendCard()),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: qualityCard()),
                ],
              );
            }

            return Column(
              children: [
                salesTrendCard(),
                const SizedBox(height: 12),
                qualityCard(),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            Widget requestPanel() {
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
                      if (requestState.loading)
                        const LoadingSkeletonList(count: 3)
                      else if ((requestState.data ?? []).isEmpty)
                        const EmptyStateCard(message: 'No pending requests')
                      else
                        ...requestState.data!
                            .where(
                              (e) =>
                                  (e['status']?.toString().toLowerCase() ?? '')
                                      .contains('pending'),
                            )
                            .take(4)
                            .map(
                              (e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    e['customer_name']?.toString() ??
                                        'Customer',
                                  ),
                                  subtitle: Text(formatSar(e['amount'])),
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

            Widget settlementsPanel() {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent settlements',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (settlementState.loading)
                        const LoadingSkeletonList(count: 3)
                      else if ((settlementState.data ?? []).isEmpty)
                        const EmptyStateCard(message: 'No settlements yet')
                      else
                        ...settlementState.data!
                            .take(4)
                            .map(
                              (e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text('Settlement ${e['id']}'),
                                  subtitle: Text(formatSar(e['net_amount'])),
                                  trailing: StatusChip(
                                    e['status']?.toString() ?? '-',
                                  ),
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
                  Expanded(child: requestPanel()),
                  const SizedBox(width: 12),
                  Expanded(child: settlementsPanel()),
                ],
              );
            }
            return Column(
              children: [
                requestPanel(),
                const SizedBox(height: 12),
                settlementsPanel(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class MerchantSendRequestPage extends StatefulWidget {
  const MerchantSendRequestPage({super.key});

  @override
  State<MerchantSendRequestPage> createState() =>
      _MerchantSendRequestPageState();
}

class _MerchantSendRequestPageState extends State<MerchantSendRequestPage> {
  final lookupCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final unitPriceCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: '1');
  Map<String, dynamic>? customer;

  @override
  void dispose() {
    lookupCtrl.dispose();
    descriptionCtrl.dispose();
    unitPriceCtrl.dispose();
    quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final customerCode = lookupCtrl.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(customerCode)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 8-character customer code'),
        ),
      );
      return;
    }

    try {
      final c = await context.read<ApiClient>().lookupCustomer(customerCode);
      setState(() => customer = c);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _send() async {
    if (customer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Validate customer first')));
      return;
    }
    final unitPrice = double.tryParse(unitPriceCtrl.text.trim()) ?? 0;
    final quantity = int.tryParse(quantityCtrl.text.trim()) ?? 1;
    if (unitPrice <= 0 || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount or quantity')),
      );
      return;
    }
    final amount = unitPrice * quantity;
    try {
      await context.read<ApiClient>().sendPurchaseRequest(
        customerId: customer!['id'] as int,
        amount: amount,
        description: descriptionCtrl.text.trim(),
        productName: 'Product',
        quantity: quantity,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request sent')));
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
                      'Send purchase request',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Validate customer and issue request instantly.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.send_rounded,
                color: Color(0xFF89F5E7),
                size: 28,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 980;

            final lookupCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer lookup',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: lookupCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Customer code',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppSecondaryButton(
                          label: 'Validate customer',
                          onPressed: _lookup,
                        ),
                      ],
                    ),
                    if (customer != null) ...[
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
                              customer!['full_name']?.toString() ?? 'Customer',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Available ${formatSar(customer!['available_balance'])}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );

            final detailsCard = Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: unitPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Unit price',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppPrimaryButton(
                        label: 'Send purchase request',
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (compact) {
              return Column(
                children: [lookupCard, const SizedBox(height: 12), detailsCard],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: lookupCard),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: detailsCard),
              ],
            );
          },
        ),
      ],
    );
  }
}

class MerchantPurchaseRequestsPage extends StatefulWidget {
  const MerchantPurchaseRequestsPage({super.key});

  @override
  State<MerchantPurchaseRequestsPage> createState() =>
      _MerchantPurchaseRequestsPageState();
}

class _MerchantPurchaseRequestsPageState
    extends State<MerchantPurchaseRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchantRequestsProvider>().fetch(context.read<ApiClient>());
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<MerchantRequestsProvider>().state;
    if (state.loading) return const LoadingSkeletonList();
    if (state.error != null)
      return ErrorStateCard(
        message: state.error!,
        onRetry: () => context.read<MerchantRequestsProvider>().fetch(
          context.read<ApiClient>(),
        ),
      );
    final data = state.data ?? [];
    if (data.isEmpty) return const EmptyStateCard(message: 'No requests');
    return ListView(
      children: data
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
                            e['request_number']?.toString() ??
                                e['id'].toString(),
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
                              '${e['customer_name']} • ${formatSar(e['amount'])} • ${formatDate(e['created_at'])}',
                              style: Theme.of(context).textTheme.bodySmall,
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

class MerchantTransactionsPage extends StatefulWidget {
  const MerchantTransactionsPage({super.key});

  @override
  State<MerchantTransactionsPage> createState() =>
      _MerchantTransactionsPageState();
}

class _MerchantTransactionsPageState extends State<MerchantTransactionsPage> {
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
      rows = await context.read<ApiClient>().merchantTransactions();
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

    return PaginatedDataTableCard(
      columns: const [
        DataColumn(label: Text('Transaction')),
        DataColumn(label: Text('Customer')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Date')),
      ],
      rows: rows
          .map(
            (e) => DataRow(
              cells: [
                DataCell(Text(e['id'].toString())),
                DataCell(Text(e['customer_name']?.toString() ?? '-')),
                DataCell(Text(formatSar(e['amount']))),
                DataCell(StatusChip(e['status']?.toString() ?? '-')),
                DataCell(Text(formatDate(e['created_at']))),
              ],
            ),
          )
          .toList(),
    );
  }
}

class MerchantSettlementsPage extends StatefulWidget {
  const MerchantSettlementsPage({super.key});

  @override
  State<MerchantSettlementsPage> createState() =>
      _MerchantSettlementsPageState();
}

class _MerchantSettlementsPageState extends State<MerchantSettlementsPage> {
  final amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MerchantSettlementsProvider>().fetch(
        context.read<ApiClient>(),
      );
    });
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return;
    try {
      await context.read<ApiClient>().requestWithdrawal(amount);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal request submitted')),
      );
      context.read<MerchantSettlementsProvider>().fetch(
        context.read<ApiClient>(),
      );
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
    final state = context.watch<MerchantSettlementsProvider>().state;
    if (state.loading) return const LoadingSkeletonList();
    if (state.error != null)
      return ErrorStateCard(
        message: state.error!,
        onRetry: () => context.read<MerchantSettlementsProvider>().fetch(
          context.read<ApiClient>(),
        ),
      );
    final data = state.data ?? [];

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Withdrawal amount',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppPrimaryButton(
                          label: 'Request withdrawal',
                          onPressed: _withdraw,
                        ),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Withdrawal amount',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppPrimaryButton(
                      label: 'Request withdrawal',
                      onPressed: _withdraw,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (data.isEmpty)
          const EmptyStateCard(message: 'No settlements yet')
        else
          ...data.map(
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
                              style: Theme.of(context).textTheme.bodySmall,
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
          ),
      ],
    );
  }
}

class MerchantSettingsPage extends StatefulWidget {
  const MerchantSettingsPage({super.key});

  @override
  State<MerchantSettingsPage> createState() => _MerchantSettingsPageState();
}

class _MerchantSettingsPageState extends State<MerchantSettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _shopCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool branchAlerts = true;

  @override
  void initState() {
    super.initState();
    final user =
        context.read<AuthProvider>().session?.user ?? <String, dynamic>{};
    _shopCtrl = TextEditingController(
      text: (user['shop_name'] ?? '').toString(),
    );
    _emailCtrl = TextEditingController(text: (user['email'] ?? '').toString());
    _phoneCtrl = TextEditingController(text: (user['phone'] ?? '').toString());
  }

  @override
  void dispose() {
    _shopCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!(_profileFormKey.currentState?.validate() ?? false)) return;
    await context.read<AuthProvider>().updateProfileLocal({
      'shop_name': _shopCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = context.watch<LocaleProvider>().locale;
    final themeMode = context.watch<ThemeProvider>().themeMode;

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
                    'Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  AppFormField(
                    controller: _shopCtrl,
                    label: 'Shop name',
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? 'Shop name is required'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  AppFormField(
                    controller: _emailCtrl,
                    label: 'Business email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v ?? '').contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 8),
                  AppFormField(
                    controller: _phoneCtrl,
                    label: 'Business phone',
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
        const Card(
          child: ListTile(
            title: Text('Banking'),
            subtitle: Text('Bank name, account number, IBAN'),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Use real-time settlement status in the Settlements page to confirm payout state before requesting withdrawal.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
        Card(
          child: SwitchListTile(
            value: branchAlerts,
            onChanged: (value) => setState(() => branchAlerts = value),
            title: const Text('Branch alerts'),
            subtitle: const Text('Notify when a branch changes status'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(l10n.t('language')),
            subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
            trailing: const Icon(Icons.language),
            onTap: () async {
              await context.read<LocaleProvider>().toggle();
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
