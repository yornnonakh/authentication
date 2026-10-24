import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/ai_dot_indicator.dart';
import '../../../../core/widgets/ios_scroll_page.dart';
import '../../../profile/presentation/view_models/profile_view_model.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../../domain/models/expense_tracker.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import '../view_models/expense_view_model.dart';
import '../view_models/budget_limit_view_model.dart';
import '../view_models/ledger_view_model.dart';
import '../view_models/spending_activity_provider.dart';
import '../widgets/expense_entry_sheet.dart';
import '../widgets/finance_page_header.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/spending_chart.dart';
import '../widgets/spending_activity_card.dart';
import 'history_screen.dart';
import 'transaction_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _ledger(BuildContext context, WidgetRef ref) {
    ref.read(ledgerFiltersProvider.notifier).clear();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: SafeArea(child: HistoryScreen())),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider);
    final data = ref.watch(expenseViewModelProvider);
    final month = ref.watch(financeMonthProvider);
    final colors = Theme.of(context).colorScheme;
    final navigation = ref.read(dashboardNavigationViewModelProvider.notifier);
    return IosScrollPage(
      key: const PageStorageKey('home-scroll'),
      title: 'Home',
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Dashboard settings',
            onPressed: () => navigation.select(DashboardTab.settings.index),
            icon: Icon(Icons.tune_rounded, color: colors.primary, size: 22),
          ),
          Tooltip(
            message: 'Open profile',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: navigation.showProfile,
              child: ProfileAvatar(profile: profile, size: 36),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile?.displayName ?? 'Your overview',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FinanceMonthPicker(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _BalanceSummary(
            balance: data.value?.availableBalance,
            income: data.value?.incomeFor(month),
            expenses: data.value?.spentFor(month),
          ),
          const SizedBox(height: 24),
          data.when(
            loading: () => FinanceCard(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Center(
                  child: Semantics(
                    label: 'Loading your expenses',
                    child: const AiDotIndicator(loop: true),
                  ),
                ),
              ),
            ),
            error: (_, _) => FinanceCard(
              child: FinanceEmptyState(
                title: 'Unable to load your expenses',
                message: 'Try again to load your saved records.',
                action: TextButton.icon(
                  onPressed: () => ref.invalidate(expenseViewModelProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ),
            ),
            data: (tracker) =>
                _content(context, ref, tracker, month, profile != null),
          ),
        ],
      ),
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    ExpenseTracker data,
    DateTime month,
    bool canAdd,
  ) {
    final colors = Theme.of(context).colorScheme;
    final entries = data.transactionsFor(month);
    final count = entries.where((t) => !t.isIncome).length;
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinanceSectionHeading(
          title: 'Recent transactions',
          action: TextButton(
            onPressed: () => _ledger(context, ref),
            child: const Text('See all'),
          ),
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          const FinanceCard(
            padding: EdgeInsets.all(12),
            child: FinanceEmptyState(
              title: 'A fresh start for your finances',
              message:
                  'Add your first transaction to see your month take shape.',
            ),
          )
        else
          Material(
            color: colors.surfaceContainerLow,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                for (final transaction in entries.take(4)) ...[
                  if (transaction.id != entries.first.id)
                    Divider(
                      height: 1,
                      indent: 66,
                      endIndent: 16,
                      color: colors.outline.withValues(alpha: 0.5),
                    ),
                  FinanceTransactionTile(
                    grouped: true,
                    transaction: transaction,
                    heroTag: 'home-${transaction.id}',
                    onTap: () => openTransactionDetail(
                      context,
                      transaction,
                      'home-${transaction.id}',
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: canAdd
              ? () => showExpenseEntrySheet(context, month)
              : null,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add transaction'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: month.year > 2000 || month.month > 1
                  ? () => ref.read(financeMonthProvider.notifier).step(-1)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                '$count ${count == 1 ? 'expense' : 'expenses'} recorded · USD',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: isCurrent
                  ? null
                  : () => ref.read(financeMonthProvider.notifier).step(1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _budget(context, ref, data, month, canAdd),
        const SizedBox(height: 20),
        SpendingActivityCard(
          days: ref.watch(spendingActivityProvider(month)),
          isCurrentMonth: isCurrent,
        ),
        const SizedBox(height: 20),
        FinanceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FinanceSectionHeading(
                title: 'Spending overview',
                action: TextButton(
                  onPressed: () => ref
                      .read(dashboardNavigationViewModelProvider.notifier)
                      .select(DashboardTab.report.index),
                  child: const Text('View report'),
                ),
              ),
              const SizedBox(height: 8),
              SpendingChart(
                categories: data.categoriesFor(month),
                large: true,
                maxDiameter: 240,
                showHint: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _budget(
    BuildContext context,
    WidgetRef ref,
    ExpenseTracker data,
    DateTime month,
    bool canAdd,
  ) {
    final colors = Theme.of(context).colorScheme;
    final spent = data.spentFor(month);
    final limit = ref.watch(budgetLimitProvider(month));
    final budget = limit.cents;
    final sliderMaximum = math
        .max(50000, math.max(data.budgetFor(month), spent) * 2)
        .toDouble();
    final over = budget > 0 && spent > budget;
    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FinanceSectionHeading(
            title: 'Monthly budget',
            action: TextButton(
              onPressed: canAdd
                  ? () => showExpenseEntrySheet(context, month, budget: true)
                  : null,
              child: Text(budget == 0 ? 'Set budget' : 'Edit budget'),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                expenseMoney(spent),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                budget > 0 ? 'of ${expenseMoney(budget)}' : 'spent this month',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0,
            minHeight: 6,
            borderRadius: BorderRadius.circular(8),
            color: over ? colors.error : colors.primary,
            backgroundColor: colors.primary.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 12),
          Text(
            budget == 0
                ? 'Set a budget to stay on track.'
                : over
                ? '${expenseMoney(spent - budget)} over budget'
                : '${expenseMoney(budget - spent)} left to spend',
            style: TextStyle(
              color: over ? colors.error : colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          if (budget > 0)
            Slider(
              key: const Key('monthly-budget-slider'),
              label: expenseMoney(budget),
              min: 1,
              max: sliderMaximum,
              value: budget.toDouble().clamp(1, sliderMaximum),
              onChanged: canAdd && !limit.isSaving
                  ? (value) => ref
                        .read(budgetLimitProvider(month).notifier)
                        .adjust(value.round())
                  : null,
              onChangeEnd: canAdd && !limit.isSaving
                  ? (_) =>
                        ref.read(budgetLimitProvider(month).notifier).commit()
                  : null,
            ),
          if (limit.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                limit.error!,
                style: TextStyle(color: colors.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary({
    required this.balance,
    required this.income,
    required this.expenses,
  });
  final int? balance, income, expenses;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9160DE), Color(0xFF7550C9)],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Current Balance',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            AiDotIndicator(key: ValueKey(balance), color: Colors.white),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              balance == null ? '—' : expenseMoney(balance!),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: Colors.white.withValues(alpha: 0.18)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _BalanceMetric(
                label: 'Income',
                cents: income,
                icon: Icons.south_west_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BalanceMetric(
                label: 'Expenses',
                cents: expenses,
                icon: Icons.north_east_rounded,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    required this.label,
    required this.cents,
    required this.icon,
  });
  final String label;
  final int? cents;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          cents == null ? '—' : expenseMoney(cents!),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
