import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.primaryAction,
  });

  final String title;
  final String subtitle;
  final Widget? primaryAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (primaryAction != null) primaryAction!,
      ],
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final successStripe = Theme.of(context).brightness == Brightness.dark
        ? scheme.tertiary.withValues(alpha: 0.7)
        : const Color(0xFF89F5E7);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.surfaceContainerLowest, scheme.surfaceContainerLow],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: Directionality.of(context) == TextDirection.rtl ? null : 0,
            right: Directionality.of(context) == TextDirection.rtl ? 0 : null,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: successStripe,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(
                    Directionality.of(context) == TextDirection.rtl ? 0 : 14,
                  ),
                  right: Radius.circular(
                    Directionality.of(context) == TextDirection.rtl ? 14 : 0,
                  ),
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxHeight < 105 || constraints.maxWidth < 170;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 16,
                  compact ? 12 : 14,
                  compact ? 12 : 16,
                  compact ? 10 : 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (icon != null)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              size: compact ? 15 : 17,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        if (icon != null) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  letterSpacing: 1.1,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                  letterSpacing: -0.2,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    Color fg;
    Color bg;
    if (normalized.contains('complete') ||
        normalized.contains('paid') ||
        normalized.contains('active')) {
      fg = scheme.onTertiaryContainer;
      bg = scheme.tertiaryContainer;
    } else if (normalized.contains('pending') ||
        normalized.contains('processing')) {
      fg = scheme.onSecondaryContainer;
      bg = scheme.secondaryContainer;
    } else {
      fg = scheme.onErrorContainer;
      bg = scheme.errorContainer;
    }

    return Chip(
      backgroundColor: bg,
      label: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
      ),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 28,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 12),
              AppPrimaryButton(label: actionLabel!, onPressed: onAction!),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.error_outline,
                color: scheme.onErrorContainer,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            AppSecondaryButton(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class LoadingSkeletonList extends StatelessWidget {
  const LoadingSkeletonList({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget itemBuilder(int index) {
          return Card(
            child: Container(
              margin: const EdgeInsets.all(10),
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surfaceContainer,
                    scheme.surfaceContainerHigh,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        if (!constraints.maxHeight.isFinite) {
          return Column(children: List.generate(count, itemBuilder));
        }

        return ListView.builder(
          itemCount: count,
          itemBuilder: (context, index) => itemBuilder(index),
        );
      },
    );
  }
}

class PaginatedDataTableCard extends StatelessWidget {
  const PaginatedDataTableCard({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
            dataRowColor: WidgetStateProperty.resolveWith(
              (_) => scheme.surfaceContainerLowest,
            ),
            dividerThickness: 0,
            horizontalMargin: 18,
            columnSpacing: 24,
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }
}

class ConfirmActionDialog extends StatelessWidget {
  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

class DetailDrawerOrModal extends StatelessWidget {
  const DetailDrawerOrModal({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size(132, 46)),
      child: Text(label),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size(132, 46)),
      child: Text(label),
    );
  }
}

class RoleMenuItem {
  const RoleMenuItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.roleMenuItems,
    required this.currentRoute,
    required this.body,
    this.subtitle = '',
    this.primaryAction,
    this.breadcrumb,
    this.footer,
    required this.onLogout,
    required this.onToggleTheme,
    required this.onSetLanguage,
    required this.onOpenProfile,
  });

  final String title;
  final String subtitle;
  final List<RoleMenuItem> roleMenuItems;
  final String currentRoute;
  final Widget body;
  final Widget? primaryAction;
  final String? breadcrumb;
  final Widget? footer;
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final ValueChanged<Locale> onSetLanguage;
  final VoidCallback onOpenProfile;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshNotificationCount();
  }

  bool get _isCustomer => widget.currentRoute.startsWith('/customer/');
  bool get _isMerchant => widget.currentRoute.startsWith('/merchant/');

  Future<void> _refreshNotificationCount() async {
    try {
      final api = context.read<ApiClient>();
      int count = 0;
      if (_isCustomer) {
        final data = await api.customerPendingRequests();
        count = data.length;
      } else if (_isMerchant) {
        final data = await api.merchantRequests();
        count = data
            .where(
              (e) => (e['status']?.toString().toLowerCase() ?? '').contains(
                'pending',
              ),
            )
            .length;
      } else {
        final stats = await api.adminStats();
        count = (stats['pending_settlements'] as num?)?.toInt() ?? 0;
      }
      if (!mounted) return;
      setState(() => _notificationCount = count);
    } catch (_) {
      if (!mounted) return;
      setState(() => _notificationCount = 0);
    }
  }

  Future<void> _openNotifications() async {
    final api = context.read<ApiClient>();
    List<String> items;
    try {
      if (_isCustomer) {
        final requests = await api.customerPendingRequests();
        items = requests
            .take(10)
            .map(
              (e) =>
                  'Pending request • ${(e['merchant_name'] ?? 'Merchant')} • ${(e['amount'] ?? '-')}'
                      .toString(),
            )
            .toList();
      } else if (_isMerchant) {
        final requests = await api.merchantRequests();
        items = requests
            .where(
              (e) => (e['status']?.toString().toLowerCase() ?? '').contains(
                'pending',
              ),
            )
            .take(10)
            .map(
              (e) =>
                  'Pending purchase • ${(e['customer_name'] ?? 'Customer')} • ${(e['amount'] ?? '-')}'
                      .toString(),
            )
            .toList();
      } else {
        final stats = await api.adminStats();
        final pending = (stats['pending_settlements'] as num?)?.toInt() ?? 0;
        items = ['Pending settlements: $pending'];
      }
    } catch (_) {
      items = ['Could not load notifications.'];
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const EmptyStateCard(message: 'No notifications right now')
            else
              ...items.map(
                (item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(item),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    _refreshNotificationCount();
  }

  String _homeRoute() {
    if (widget.roleMenuItems.isEmpty) return widget.currentRoute;
    return widget.roleMenuItems.first.route;
  }

  Widget _topNavItem(BuildContext context, RoleMenuItem item, bool selected) {
    return _TopNavItem(
      item: item,
      selected: selected,
      currentRoute: widget.currentRoute,
    );
  }

  Widget _compactUtilityMenu(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'lang_en') {
          widget.onSetLanguage(const Locale('en'));
          return;
        }
        if (value == 'lang_ar') {
          widget.onSetLanguage(const Locale('ar'));
          return;
        }
        if (value == 'theme') {
          widget.onToggleTheme();
          return;
        }
        if (value == 'profile') {
          widget.onOpenProfile();
          return;
        }
        if (value == 'logout') {
          widget.onLogout();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
        PopupMenuDivider(),
        PopupMenuItem<String>(value: 'lang_en', child: Text('English')),
        PopupMenuItem<String>(value: 'lang_ar', child: Text('العربية')),
        PopupMenuItem<String>(value: 'theme', child: Text('Toggle theme')),
        PopupMenuDivider(),
        PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.of(context).size.width < 980;

    final mobileGradient = isDark
        ? [const Color(0xFF071219), const Color(0xFF0A161E), scheme.surface]
        : [
            const Color(0xFFF5F7FA),
            const Color(0xFFFAFBFC),
            const Color(0xFFFFFFFF),
          ];

    final desktopGradient = isDark
        ? [const Color(0xFF061018), const Color(0xFF0A161E), scheme.surface]
        : [
            const Color(0xFFF7F9FB),
            const Color(0xFFFBFCFD),
            const Color(0xFFFFFFFF),
          ];

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: PageHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            primaryAction: widget.primaryAction,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: widget.body,
          ),
        ),
        if (widget.footer != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DefaultTextStyle(
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ) ??
                  const TextStyle(),
              child: widget.footer!,
            ),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: 10,
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                final homeRoute = _homeRoute();
                if (widget.currentRoute != homeRoute) {
                  Navigator.pushReplacementNamed(context, homeRoute);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isCompact ? 140 : 220),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [const Color(0xFF000000), const Color(0xFF131B2E)]
                                : [scheme.primary, scheme.primaryContainer],
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 18,
                          color: isDark ? Colors.white : scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bareeq Alysr',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isCompact) ...[
              const SizedBox(width: 14),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final item in widget.roleMenuItems)
                        _topNavItem(
                          context,
                          item,
                          widget.currentRoute == item.route,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        bottom: isCompact
            ? PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final item in widget.roleMenuItems)
                          _topNavItem(
                            context,
                            item,
                            widget.currentRoute == item.route,
                          ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        actions: [
          if (!isCompact)
            PopupMenuButton<String>(
              tooltip: 'Language',
              onSelected: (value) {
                widget.onSetLanguage(
                  value == 'ar' ? const Locale('ar') : const Locale('en'),
                );
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'en', child: Text('English')),
                PopupMenuItem(value: 'ar', child: Text('العربية')),
              ],
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.language),
              ),
            ),
          if (!isCompact)
            IconButton(
              onPressed: widget.onToggleTheme,
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          IconButton(
            onPressed: _openNotifications,
            icon: Badge(
              isLabelVisible: _notificationCount > 0,
              label: Text('$_notificationCount'),
              child: const Icon(Icons.notifications_none),
            ),
          ),
          if (isCompact)
            _compactUtilityMenu(context)
          else
            InkWell(
              onTap: widget.onOpenProfile,
              borderRadius: BorderRadius.circular(24),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: CircleAvatar(child: Icon(Icons.person)),
              ),
            ),
        ],
      ),
      body: isCompact
          ? Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: mobileGradient,
                      ),
                    ),
                  ),
                ),
                content,
              ],
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: desktopGradient,
                      ),
                    ),
                  ),
                ),
                content,
              ],
            ),
      bottomNavigationBar: null,
    );
  }
}

// Optimized navigation item widget to prevent unnecessary rebuilds
class _TopNavItem extends StatelessWidget {
  final RoleMenuItem item;
  final bool selected;
  final String currentRoute;

  const _TopNavItem({
    required this.item,
    required this.selected,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (currentRoute != item.route) {
          Navigator.pushReplacementNamed(context, item.route);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? (isDark ? scheme.tertiary : scheme.primary)
                    : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 2,
              width: selected ? 28 : 0,
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? scheme.tertiary : scheme.primary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
