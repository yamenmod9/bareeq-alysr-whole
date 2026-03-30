import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/app_components.dart';
import '../../l10n/app_localizations.dart';
import '../../models/installment_plan.dart';
import '../../services/api_client.dart';
import '../../services/notification_service.dart';
import '../../state/auth_provider.dart';
import '../../state/feature_providers.dart';
import '../../state/locale_provider.dart';
import '../../state/notification_provider.dart';
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
    final l10n = AppLocalizations.of(context);

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF000000), const Color(0xFF131B2E)]
                  : [scheme.primary, scheme.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('availableBalance'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
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
                      '${l10n.t('outstanding')} ${formatSar(d['outstanding_balance'])}',
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
                    side: BorderSide.none,
                  ),
                  Chip(
                    label: Text('${l10n.t('creditLimit')} ${formatSar(d['credit_limit'])}'),
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
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
              label: l10n.t('creditLimit'),
              value: formatSar(d['credit_limit']),
              icon: Icons.speed_outlined,
            ),
            KpiCard(
              label: l10n.t('availableBalance'),
              value: formatSar(d['available_balance']),
              icon: Icons.account_balance_wallet_outlined,
            ),
            KpiCard(
              label: l10n.t('outstanding'),
              value: formatSar(d['outstanding_balance']),
              icon: Icons.payments_outlined,
            ),
            KpiCard(
              label: l10n.t('activeTransactions'),
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
                        l10n.t('upcomingPayments'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (tx.loading)
                        const LoadingSkeletonList(count: 2)
                      else if ((tx.data ?? []).isEmpty)
                        EmptyStateCard(message: l10n.t('noUpcomingPayments'))
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
                                        l10n.t('merchant'),
                                  ),
                                  subtitle: Text(
                                    '${l10n.t('remaining')} ${formatSar(e['remaining_amount'])}',
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
                        l10n.t('pendingRequests'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (requests.loading)
                        const LoadingSkeletonList(count: 2)
                      else if ((requests.data ?? []).isEmpty)
                        EmptyStateCard(message: l10n.t('noPendingRequests'))
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

  Future<void> _accept(int id, double amount) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AcceptPurchaseDialog(amount: amount),
    );
    if (result == null || !mounted) return;
    
    final installmentMonths = result['installmentMonths'] as int;
    await context.read<ApiClient>().acceptPurchaseRequest(
      id,
      installmentMonths: installmentMonths,
    );
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('requestAccepted'))));
    context.read<CustomerRequestsProvider>().fetch(context.read<ApiClient>());
  }

  Future<void> _reject(int id) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: l10n.t('rejectRequestTitle'),
        message: l10n.t('rejectRequestQuestion'),
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<ApiClient>().rejectPurchaseRequest(id);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('requestRejected'))));
    context.read<CustomerRequestsProvider>().fetch(context.read<ApiClient>());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
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
      return Center(
        child: SizedBox(
          width: 420,
          child: EmptyStateCard(message: l10n.t('noPendingRequests')),
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
                            e['merchant_name']?.toString() ?? l10n.t('merchantId'),
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
                                ? l10n.t('noDescriptionProvided')
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
                          label: l10n.t('accept'),
                          onPressed: () => _accept(
                            e['id'] as int,
                            (e['amount'] as num).toDouble(),
                          ),
                        ),
                        AppSecondaryButton(
                          label: l10n.t('reject'),
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
    final l10n = AppLocalizations.of(context);
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
          EmptyStateCard(message: l10n.t('noTransactions'))
        else
          PaginatedDataTableCard(
            columns: [
              DataColumn(label: Text(l10n.t('transaction'))),
              DataColumn(label: Text(l10n.t('merchantId'))),
              DataColumn(label: Text(l10n.t('amount'))),
              DataColumn(label: Text(l10n.t('remaining'))),
              DataColumn(label: Text(l10n.t('installmentPlan'))),
              DataColumn(label: Text(l10n.t('status'))),
              DataColumn(label: Text(l10n.t('date'))),
            ],
            rows: filtered
                .map(
                  (e) {
                    // Check multiple possible field names for installment data
                    final installmentMonths = e['installment_months'] ?? 
                                            e['plan_months'] ?? 
                                            e['installments'] ??
                                            e['payment_plan'] ??
                                            0;
                    
                    String installmentText;
                    if (installmentMonths == 0 || installmentMonths == null) {
                      installmentText = l10n.t('payInFull');
                    } else {
                      installmentText = '$installmentMonths ${l10n.t('months')}';
                    }
                    
                    // Debug: Print transaction data to see what fields exist
                    if (e['id'] != null) {
                      print('Transaction ${e['id']}: installment_months=${e['installment_months']}, plan_months=${e['plan_months']}, installments=${e['installments']}');
                    }
                    
                    return DataRow(
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
                        DataCell(Text(installmentText)),
                        DataCell(StatusChip(e['status']?.toString() ?? '-')),
                        DataCell(Text(formatDate(e['created_at']))),
                      ],
                    );
                  },
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
  Map<String, dynamic>? selectedPlan;

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
      // Check for upcoming payments and create notifications
      if (mounted && plans.isNotEmpty) {
        _checkUpcomingPayments();
      }
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _checkUpcomingPayments() async {
    final notificationProvider = context.read<InAppNotificationProvider>();
    final l10n = AppLocalizations.of(context);
    
    for (final plan in plans) {
      final status = plan['status']?.toString().toLowerCase();
      if (status != 'active' && status != 'pending') continue;
      
      final totalMonths = plan['plan_months'] ?? plan['installment_months'] ?? 0;
      final totalAmount = double.tryParse(plan['total_amount']?.toString() ?? '0') ?? 0;
      final remainingAmount = double.tryParse(plan['remaining_amount']?.toString() ?? '0') ?? 0;
      final paidAmount = totalAmount - remainingAmount;
      final monthlyPayment = totalMonths > 0 ? totalAmount / totalMonths : totalAmount;
      final paidMonths = monthlyPayment > 0 ? (paidAmount / monthlyPayment).floor() : 0;
      
      final createdAt = plan['created_at'] ?? plan['transaction_date'];
      if (createdAt == null) continue;
      
      final startDate = DateTime.tryParse(createdAt.toString());
      if (startDate == null) continue;
      
      // Calculate next payment date
      if (paidMonths < totalMonths) {
        final nextPaymentDate = DateTime(
          startDate.year,
          startDate.month + paidMonths + 1,
          startDate.day,
        );
        
        final now = DateTime.now();
        final daysUntilDue = nextPaymentDate.difference(now).inDays;
        
        // Create reminder if payment is due within 3 days or overdue
        if (daysUntilDue <= 3) {
          String message;
          if (daysUntilDue < 0) {
            message = l10n.t('overduePayment');
          } else if (daysUntilDue == 0) {
            message = '${l10n.t('paymentDueMessage')} ${l10n.t('today')}';
          } else {
            message = '${l10n.t('paymentDueMessage')} (${daysUntilDue} ${l10n.t('days')})';
          }
          
          await notificationProvider.addPaymentReminder(
            title: l10n.t('paymentReminder'),
            body: '$message - ${formatSar(monthlyPayment)}',
            planId: plan['id'] as int?,
            dueDate: nextPaymentDate,
          );
          
          // Also show push notification
          await NotificationService().showPaymentReminder(
            title: l10n.t('paymentReminder'),
            body: '$message - ${formatSar(monthlyPayment)}',
            planId: plan['id'] as int?,
          );
        }
      }
    }
  }

  void _openDetails(Map<String, dynamic> plan) {
    setState(() => selectedPlan = plan);
  }

  void _closeDetails() {
    setState(() => selectedPlan = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);
    
    // Show detail view if a plan is selected
    if (selectedPlan != null) {
      return _InstallmentDetailView(
        plan: selectedPlan!,
        onBack: _closeDetails,
      );
    }
    
    if (plans.isEmpty) {
      return Center(
        child: SizedBox(
          width: 420,
          child: EmptyStateCard(message: l10n.t('noRepaymentPlans')),
        ),
      );
    }

    // Filter to show only active plans with installments
    final activePlans = plans.where((p) {
      final status = p['status']?.toString().toLowerCase();
      return status == 'active' || status == 'pending';
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Summary card
        _buildSummaryCard(context, plans),
        const SizedBox(height: 16),
        // Active installments section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            l10n.t('activeInstallments'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (activePlans.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  l10n.t('noActiveInstallments'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...activePlans.map((p) => _buildPlanCard(context, p)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, List<dynamic> allPlans) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    
    double totalAmount = 0;
    double totalPaid = 0;
    double totalRemaining = 0;
    
    for (final p in allPlans) {
      final total = double.tryParse(p['total_amount']?.toString() ?? '0') ?? 0;
      final remaining = double.tryParse(p['remaining_amount']?.toString() ?? '0') ?? 0;
      totalAmount += total;
      totalRemaining += remaining;
      totalPaid += (total - remaining);
    }

    final progressPercent = totalAmount > 0 ? (totalPaid / totalAmount) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('installmentPlan'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: l10n.t('totalPaid'),
                    value: formatSar(totalPaid),
                    color: scheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryItem(
                    label: l10n.t('totalRemaining'),
                    value: formatSar(totalRemaining),
                    color: scheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.t('progress'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(scheme.tertiary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(progressPercent * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, Map<String, dynamic> plan) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    
    final totalMonths = plan['plan_months'] ?? plan['installment_months'] ?? 0;
    final totalAmount = double.tryParse(plan['total_amount']?.toString() ?? '0') ?? 0;
    final remainingAmount = double.tryParse(plan['remaining_amount']?.toString() ?? '0') ?? 0;
    final paidAmount = totalAmount - remainingAmount;
    final monthlyPayment = totalMonths > 0 ? totalAmount / totalMonths : totalAmount;
    
    // Calculate paid months
    final paidMonths = monthlyPayment > 0 ? (paidAmount / monthlyPayment).floor() : 0;
    final remainingMonths = totalMonths - paidMonths;
    
    // Calculate next payment date (assume monthly from transaction date)
    final createdAt = plan['created_at'] ?? plan['transaction_date'];
    DateTime? nextPaymentDate;
    if (createdAt != null) {
      final startDate = DateTime.tryParse(createdAt.toString());
      if (startDate != null && remainingMonths > 0) {
        nextPaymentDate = DateTime(
          startDate.year,
          startDate.month + paidMonths + 1,
          startDate.day,
        );
      }
    }
    
    final merchantName = plan['merchant_name']?.toString() ?? 
                         plan['description']?.toString() ?? 
                         'Transaction #${plan['id']}';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDetails(plan),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchantName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalMonths ${l10n.t('monthsPlan')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(plan['status']?.toString() ?? '-'),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalMonths > 0 ? paidMonths / totalMonths : 0,
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(scheme.tertiary),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$paidMonths / $totalMonths ${l10n.t('paidInstallments')}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    formatSar(monthlyPayment) + ' / ${l10n.t('months')}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (nextPaymentDate != null && remainingMonths > 0) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isOverdue(nextPaymentDate) 
                        ? scheme.errorContainer 
                        : scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isOverdue(nextPaymentDate)
                            ? Icons.warning_amber_rounded
                            : Icons.calendar_today_outlined,
                        size: 16,
                        color: _isOverdue(nextPaymentDate)
                            ? scheme.onErrorContainer
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOverdue(nextPaymentDate)
                            ? l10n.t('overduePayment')
                            : '${l10n.t('nextPayment')}: ${_formatDate(nextPaymentDate)}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _isOverdue(nextPaymentDate)
                              ? scheme.onErrorContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _openDetails(plan),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(l10n.t('viewDetails')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstallmentDetailView extends StatelessWidget {
  const _InstallmentDetailView({
    required this.plan,
    required this.onBack,
  });

  final Map<String, dynamic> plan;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    
    final totalMonths = plan['plan_months'] ?? plan['installment_months'] ?? 0;
    final totalAmount = double.tryParse(plan['total_amount']?.toString() ?? '0') ?? 0;
    final remainingAmount = double.tryParse(plan['remaining_amount']?.toString() ?? '0') ?? 0;
    final paidAmount = totalAmount - remainingAmount;
    final monthlyPayment = totalMonths > 0 ? totalAmount / totalMonths : totalAmount;
    final paidMonths = monthlyPayment > 0 ? (paidAmount / monthlyPayment).floor() : 0;
    
    // Parse start date
    final createdAt = plan['created_at'] ?? plan['transaction_date'];
    DateTime startDate = DateTime.now();
    if (createdAt != null) {
      startDate = DateTime.tryParse(createdAt.toString()) ?? DateTime.now();
    }
    
    final merchantName = plan['merchant_name']?.toString() ?? 
                         plan['description']?.toString() ?? 
                         'Transaction #${plan['id']}';

    // Generate installment schedule
    final installments = List.generate(totalMonths, (index) {
      final dueDate = DateTime(startDate.year, startDate.month + index + 1, startDate.day);
      final isPaid = index < paidMonths;
      final isOverdue = !isPaid && dueDate.isBefore(DateTime.now());
      return {
        'number': index + 1,
        'amount': monthlyPayment,
        'dueDate': dueDate,
        'isPaid': isPaid,
        'isOverdue': isOverdue,
      };
    });

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Back button and title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.t('back'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.t('installmentDetails'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
        
        // Transaction info card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: l10n.t('totalAmount'),
                  value: formatSar(totalAmount),
                ),
                _DetailRow(
                  label: l10n.t('monthlyPayment'),
                  value: formatSar(monthlyPayment),
                ),
                _DetailRow(
                  label: l10n.t('numberOfInstallments'),
                  value: '$totalMonths ${l10n.t('months')}',
                ),
                _DetailRow(
                  label: l10n.t('paidInstallments'),
                  value: '$paidMonths / $totalMonths',
                ),
                _DetailRow(
                  label: l10n.t('remainingInstallments'),
                  value: '${totalMonths - paidMonths}',
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalMonths > 0 ? paidMonths / totalMonths : 0,
                    minHeight: 10,
                    backgroundColor: scheme.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation(scheme.tertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Installment schedule header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            l10n.t('installmentSchedule'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        
        // Installment list
        ...installments.map((inst) => _InstallmentTile(
          number: inst['number'] as int,
          amount: inst['amount'] as double,
          dueDate: inst['dueDate'] as DateTime,
          isPaid: inst['isPaid'] as bool,
          isOverdue: inst['isOverdue'] as bool,
        )),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  const _InstallmentTile({
    required this.number,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.isOverdue,
  });

  final int number;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    
    final dateStr = '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';

    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String statusText;

    if (isPaid) {
      backgroundColor = scheme.tertiaryContainer.withValues(alpha: 0.3);
      iconColor = scheme.tertiary;
      icon = Icons.check_circle;
      statusText = l10n.t('paid');
    } else if (isOverdue) {
      backgroundColor = scheme.errorContainer;
      iconColor = scheme.onErrorContainer;
      icon = Icons.warning_amber_rounded;
      statusText = l10n.t('overduePayment');
    } else {
      backgroundColor = scheme.surfaceContainerLow;
      iconColor = scheme.onSurfaceVariant;
      icon = Icons.schedule;
      statusText = l10n.t('pending');
    }

    return Card(
      color: backgroundColor,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '#$number',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        title: Text(
          formatSar(amount),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${l10n.t('dueDateLabel')}: $dateStr',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('invalidValue'))));
      return;
    }
    try {
      await context.read<ApiClient>().payTransaction(
        transactionId: selectedTransactionId!,
        amount: amount,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('paymentSuccessful'))));
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
    final l10n = AppLocalizations.of(context);
    if (loading) return const LoadingSkeletonList();
    if (error != null) return ErrorStateCard(message: error!, onRetry: _load);

    final active = transactions.where((e) => e['status'] == 'active').toList();
    if (active.isEmpty) {
      return Center(
        child: SizedBox(
          width: 420,
          child: EmptyStateCard(message: l10n.t('noActiveTransactions')),
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
                  l10n.t('paymentForm'),
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
                  decoration: InputDecoration(labelText: l10n.t('transaction')),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountCtrl,
                  decoration: InputDecoration(labelText: l10n.t('amount')),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppPrimaryButton(label: l10n.t('payNow'), onPressed: _pay),
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
                Text(l10n.t('summary'), style: Theme.of(context).textTheme.titleMedium),
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
                        l10n.t('remainingBefore'),
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
                        l10n.t('remainingAfterPayment'),
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
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('profileSaved'))));
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.t('codeRefreshed')}: ${customerCode ?? '-'}')),
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('noDataAvailable'))),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('codeCopied'))));
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
                  l10n.t('yourCustomerCode'),
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
                    codeBusy ? l10n.t('loading') : (customerCode ?? l10n.t('unavailable')),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppSecondaryButton(
                      label: codeBusy ? l10n.t('pleaseWait') : l10n.t('regenerateCode'),
                      onPressed: codeBusy ? () {} : _regenerateCode,
                    ),
                    AppPrimaryButton(
                      label: l10n.t('copyCode'),
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
                    l10n.t('profile'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  AppFormField(
                    controller: _nameCtrl,
                    label: l10n.t('fullName'),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.t('nameRequired') : null,
                  ),
                  const SizedBox(height: 8),
                  AppFormField(
                    controller: _emailCtrl,
                    label: l10n.t('email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v ?? '').contains('@') ? null : l10n.t('enterValidEmail'),
                  ),
                  const SizedBox(height: 8),
                  AppFormField(
                    controller: _phoneCtrl,
                    label: l10n.t('phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppPrimaryButton(
                      label: l10n.t('saveProfile'),
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
            title: Text(l10n.t('notificationsLabel')),
            subtitle: Text(l10n.t('notificationsDesc')),
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

// Dialog for accepting purchase request with installment plan selection
class AcceptPurchaseDialog extends StatefulWidget {
  const AcceptPurchaseDialog({super.key, required this.amount});

  final double amount;

  @override
  State<AcceptPurchaseDialog> createState() => _AcceptPurchaseDialogState();
}

class _AcceptPurchaseDialogState extends State<AcceptPurchaseDialog> {
  int selectedInstallmentMonths = 0; // 0 = Pay in Full

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    
    final selectedPlan = InstallmentPlan(
      months: selectedInstallmentMonths,
      totalAmount: widget.amount,
    );

    return AlertDialog(
      title: Text(l10n.t('acceptRequestTitle')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('totalAmount'),
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              formatSar(widget.amount),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.t('selectInstallmentPlan'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InstallmentPlan.availablePlans.map((months) {
                final isSelected = selectedInstallmentMonths == months;
                final label = months == 0 
                    ? l10n.t('payInFull')
                    : '$months ${l10n.t('months')}';
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedInstallmentMonths = months;
                    });
                  },
                );
              }).toList(),
            ),
            if (selectedInstallmentMonths > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.t('monthlyPayment'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          formatSar(selectedPlan.monthlyPayment),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${selectedPlan.months} ${l10n.t('months')} × ${formatSar(selectedPlan.monthlyPayment)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.t('cancel')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'installmentMonths': selectedInstallmentMonths,
            });
          },
          child: Text(l10n.t('accept')),
        ),
      ],
    );
  }
}
