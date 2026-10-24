import '../../../../core/widgets/ios_scroll_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/tracker_palette.dart';
import '../../../profile/presentation/view_models/profile_view_model.dart';
import '../../domain/models/transaction.dart';
import '../utils/finance_format.dart';
import '../view_models/expense_view_model.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import '../view_models/ledger_view_model.dart';
import '../widgets/expense_entry_sheet.dart';
import '../widgets/finance_page_header.dart';
import '../widgets/finance_widgets.dart';
import 'history_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  void _ledger(BuildContext context, WidgetRef ref, {String? category}) {
    final filters = ref.read(ledgerFiltersProvider.notifier);
    filters.clear();
    filters.setType(TransactionType.expense);
    if (category != null) filters.setCategory(category);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: SafeArea(child: HistoryScreen())),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retain the selected filters while the transaction route is opening.
    ref.listen(ledgerFiltersProvider, (_, _) {});
    final data = ref.watch(expenseViewModelProvider);
    final month = ref.watch(financeMonthProvider);
    final colors = Theme.of(context).colorScheme;
    final canEdit =
        data.hasValue && ref.watch(currentUserProfileProvider) != null;
    return IosScrollPage(
      key: const PageStorageKey('plan-scroll'),
      title: 'My Plan',
      onBack: ref.read(dashboardNavigationViewModelProvider.notifier).showHome,
      backLabel: 'Home',
      trailing: IconButton.filled(
        tooltip: 'Set budget',
        style: IconButton.styleFrom(
          backgroundColor: colors.onSurface,
          foregroundColor: colors.surface,
        ),
        onPressed: canEdit
            ? () => showExpenseEntrySheet(context, month, budget: true)
            : null,
        icon: const Icon(Icons.add_rounded),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: FinanceMonthPicker(),
          ),
          const SizedBox(height: 20),
          data.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => FinanceEmptyState(
              title: 'Unable to load your plan',
              message: 'Try again to load your saved budget.',
              action: TextButton(
                onPressed: () => ref.invalidate(expenseViewModelProvider),
                child: const Text('Try again'),
              ),
            ),
            data: (tracker) {
              final budget = tracker.budgetFor(month);
              final spent = tracker.spentFor(month);
              final categories = tracker.categoriesFor(month);
              final progress = budget == 0 ? 0.0 : spent / budget;
              final over = budget > 0 && spent > budget;
              final color = over || progress >= 0.8
                  ? TrackerPalette.coral
                  : TrackerPalette.purple;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FinanceSectionHeading(
                    title: 'Goals',
                    action: TextButton(
                      onPressed: canEdit
                          ? () => showExpenseEntrySheet(
                              context,
                              month,
                              budget: true,
                            )
                          : null,
                      child: Text(budget == 0 ? 'Set budget' : 'Edit budget'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.flag_rounded,
                                      color: color,
                                      size: 23,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Monthly spending goal',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          financeMonthLabel(month),
                                          style: TextStyle(
                                            color: colors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  Text(
                                    expenseMoney(spent),
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  Text(
                                    budget == 0
                                        ? 'spent this month'
                                        : 'of ${expenseMoney(budget)}',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(20),
                                color: color,
                                backgroundColor: color.withValues(alpha: 0.09),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      budget == 0
                                          ? 'Your Progress'
                                          : '${(progress * 100).round()}% of budget used',
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    budget == 0
                                        ? 'No limit set'
                                        : '${expenseMoney((budget - spent).abs())} ${over ? 'Over' : 'Left'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: color,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  budget == 0
                                      ? 'Set a monthly limit to give your money a plan.'
                                      : over
                                      ? 'You’ve exceeded your monthly spending goal.'
                                      : progress >= 0.8
                                      ? 'You’re getting close to your monthly limit.'
                                      : 'Your spending is within your monthly goal.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FinanceSectionHeading(
                    title: 'Budgets',
                    action: TextButton(
                      onPressed: () => _ledger(context, ref),
                      child: const Text('View All'),
                    ),
                  ),
                  Text(
                    budget > 0
                        ? 'Each category’s share of your monthly limit'
                        : 'Each category’s share of your spending',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (categories.isEmpty)
                    const FinanceCard(
                      child: FinanceEmptyState(
                        title: 'Make room for what matters',
                        message:
                            'Your expense categories will appear here when you add a transaction.',
                        icon: Icons.savings_outlined,
                      ),
                    )
                  else
                    for (final category in categories.entries) ...[
                      _BudgetCategory(
                        category: category.key,
                        cents: category.value,
                        limit: budget > 0 ? budget : spent,
                        onTap: () =>
                            _ledger(context, ref, category: category.key),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BudgetCategory extends StatelessWidget {
  const _BudgetCategory({
    required this.category,
    required this.cents,
    required this.limit,
    required this.onTap,
  });
  final String category;
  final int cents, limit;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = FinanceStyle.categoryColor(category);
    final progress = limit > 0 ? cents / limit : 0.0;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  FinanceStyle.categoryIcon(category),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      expenseMoney(cents),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 2,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.09),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.09),
                      ),
                      child: FittedBox(
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
