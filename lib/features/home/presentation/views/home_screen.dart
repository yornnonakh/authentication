import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/tracker_palette.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../profile/presentation/view_models/profile_view_model.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../../domain/models/expense_tracker.dart';
import '../../domain/models/transaction.dart';
import '../utils/finance_format.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import '../view_models/expense_view_model.dart';
import '../view_models/budget_limit_view_model.dart';
import '../view_models/ledger_view_model.dart';
import '../view_models/spending_activity_provider.dart';
import '../widgets/expense_entry_sheet.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/spending_chart.dart';
import '../widgets/spending_activity_card.dart';
import 'history_screen.dart';
import 'transaction_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  void _ledger(BuildContext context, WidgetRef ref, {String? category}) {
    final filters = ref.read(ledgerFiltersProvider.notifier);
    filters.clear();
    if (category != null) {
      filters.setType(TransactionType.expense);
      filters.setCategory(category);
    }
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
    return ColoredBox(
      color: TrackerPalette.backdrop(context),
      child: SingleChildScrollView(
        key: const PageStorageKey('home-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -18,
              left: -20,
              right: -20,
              height:
                  220 +
                  math.max(0, MediaQuery.textScalerOf(context).scale(18) - 18) *
                      5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: TrackerPalette.header(context),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Tooltip(
                      message: 'Open profile',
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: ref
                            .read(dashboardNavigationViewModelProvider.notifier)
                            .showProfile,
                        child: ProfileAvatar(profile: profile, size: 36),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Expense Tracker',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?.displayName ?? 'Your account',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dashboard settings',
                      onPressed: () => ref
                          .read(dashboardNavigationViewModelProvider.notifier)
                          .select(2),
                      icon: const Icon(Icons.sort_rounded, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                data.when(
                  loading: () => const FinanceCard(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, stack) => FinanceCard(
                    child: FinanceEmptyState(
                      title: 'Unable to load your expenses',
                      message: 'Try again to load your saved records.',
                      action: TextButton.icon(
                        onPressed: () =>
                            ref.invalidate(expenseViewModelProvider),
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
          ],
        ),
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
    final expenseCount = entries.where((t) => !t.isIncome).length;
    final spent = data.spentFor(month);
    final limit = ref.watch(budgetLimitProvider(month));
    final budget = limit.cents;
    final sliderMaximum = math
        .max(50000, math.max(data.budgetFor(month), spent) * 2)
        .toDouble();
    final pace = budgetPaceFor(spent, budget);
    final paceColor = switch (pace) {
      BudgetPace.overBudget => FinanceStyle.expense(context),
      BudgetPace.approachingLimit => TrackerPalette.coral,
      _ => FinanceStyle.income(context),
    };
    final now = DateTime.now();
    final isCurrent = month.year == now.year && month.month == now.month;
    final categories = data.categoriesFor(month);
    final topCategories = categories.entries.take(4).toList();
    final onSlate = TrackerPalette.onBackdrop(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: month.year > 2000 || month.month > 1
                  ? () => ref.read(financeMonthProvider.notifier).step(-1)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
            ),
            Expanded(
              child: Column(
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Top Expenses',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Month of ${financeMonthLabel(month)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: isCurrent
                  ? null
                  : () => ref.read(financeMonthProvider.notifier).step(1),
              icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
        const SizedBox(height: 20),

        FinanceCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 14) / 2;
                  final defaultCats = topCategories.isNotEmpty
                      ? topCategories
                      : [
                          const MapEntry('Lifestyle', 149254),
                          const MapEntry('Travel', 267494),
                          const MapEntry('Coffee & Tea', 54285),
                          const MapEntry('Food Order', 79412),
                        ];
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (final category in defaultCats.take(4))
                        SizedBox(
                          width: itemWidth,
                          height: 135,
                          child: _CategoryTile(
                            category: category.key,
                            cents: category.value,
                            percentage: spent > 0
                                ? (category.value / spent * 100).round()
                                : 25,
                            onTap: () => _ledger(context, ref, category: category.key),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Total Expense',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            expenseMoney(spent),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 36, color: colors.outlineVariant),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Remaining Budget',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            expenseMoney(budget > 0 ? (budget - spent).abs() : budget),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: colors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 46,
                child: PrimaryButton(
                  label: 'VIEW ALL',
                  onPressed: () => _ledger(context, ref),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Monthly budget',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: canAdd
                        ? () => showExpenseEntrySheet(context, month, budget: true)
                        : null,
                    child: Text(
                      budget == 0 ? 'Set budget' : 'Edit budget',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (budget > 0) ...[
                Slider(
                  key: const Key('monthly-budget-slider'),
                  label: expenseMoney(budget),
                  min: 1,
                  max: sliderMaximum,
                  value: budget.toDouble().clamp(1, sliderMaximum),
                  onChanged: canAdd && !limit.isSaving
                      ? (value) => ref.read(budgetLimitProvider(month).notifier).adjust(value.round())
                      : null,
                  onChangeEnd: canAdd && !limit.isSaving
                      ? (_) => ref.read(budgetLimitProvider(month).notifier).commit()
                      : null,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (spent / budget).clamp(0.0, 1.0),
                    minHeight: 6,
                    color: paceColor,
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  spent > budget
                      ? '${expenseMoney(spent - budget)} over budget'
                      : '${expenseMoney(budget - spent)} left to spend',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: canAdd
              ? () => showExpenseEntrySheet(context, month)
              : null,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add transaction'),
        ),
        const SizedBox(height: 16),
        SpendingActivityCard(
          days: ref.watch(spendingActivityProvider(month)),
          isCurrentMonth: isCurrent,
        ),
        const SizedBox(height: 12),
        Text(
          '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'} recorded · USD',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onSlate.withValues(alpha: 0.75),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 28),
        _SectionTitle(
          title: 'Account overview',
          subtitle: 'All-time earnings and expenses',
        ),
        const SizedBox(height: 16),
        FinanceCard(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 580;
              final width = wide
                  ? (constraints.maxWidth - 20) / 3
                  : (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: width,
                    child: _SummaryCard(
                      title: 'Total Earnings',
                      cents: data.totalIncome,
                      icon: Icons.south_west_rounded,
                      color: FinanceStyle.income(context),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _SummaryCard(
                      title: 'Total Spending',
                      cents: data.totalSpending,
                      icon: Icons.north_east_rounded,
                      color: FinanceStyle.expense(context),
                    ),
                  ),
                  SizedBox(
                    width: wide ? width : constraints.maxWidth,
                    child: _SummaryCard(
                      title: 'Available Balance',
                      cents: data.availableBalance,
                      icon: Icons.account_balance_wallet_outlined,
                      color: data.availableBalance >= 0
                          ? FinanceStyle.income(context)
                          : FinanceStyle.expense(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        _SectionTitle(
          title: 'Top Categories',
          subtitle: '${financeMonthLabel(month)}’s expenses',
        ),
        const SizedBox(height: 16),
        FinanceCard(
          padding: const EdgeInsets.all(12),
          child: topCategories.isEmpty
              ? const FinanceEmptyState(
                  title: 'Your categories start here',
                  message: 'Add an expense to see your top categories.',
                  icon: Icons.category_outlined,
                )
              : Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final category in topCategories)
                            SizedBox(
                              width: (constraints.maxWidth - 12) / 2,
                              child: _CategoryTile(
                                category: category.key,
                                cents: category.value,
                                percentage: (category.value / spent * 100)
                                    .round(),
                                onTap: () => _ledger(
                                  context,
                                  ref,
                                  category: category.key,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _ledger(context, ref),
                      child: const Text('All categories'),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle(
          title: 'Statistics',
          subtitle: 'Your monthly spending distribution',
        ),
        const SizedBox(height: 16),
        FinanceCard(child: SpendingChart(categories: categories)),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: onSlate,
                ),
              ),
            ),
            if (entries.isNotEmpty)
              TextButton(
                onPressed: () => _ledger(context, ref),
                child: const Text(
                  'See all',
                  style: TextStyle(color: TrackerPalette.peach),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FinanceCard(
          padding: const EdgeInsets.all(12),
          child: entries.isEmpty
              ? const FinanceEmptyState(
                  title: 'A fresh start for your finances',
                  message:
                      'Add your first transaction to see your month take shape.\nSaved on this device, for your account.',
                )
              : Column(
                  children: [
                    for (final transaction in entries.take(4))
                      FinanceTransactionTile(
                        transaction: transaction,
                        heroTag: 'home-${transaction.id}',
                        onTap: () => openTransactionDetail(
                          context,
                          transaction,
                          'home-${transaction.id}',
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TrackerPalette.onBackdrop(context),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: TrackerPalette.onBackdrop(context).withValues(alpha: 0.65),
        ),
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.cents,
    required this.icon,
    required this.color,
  });
  final String title;
  final int cents;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            expenseMoney(cents),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.cents,
    required this.percentage,
    required this.onTap,
  });
  final String category;
  final int cents, percentage;
  final VoidCallback onTap;

  Color _cardColor(String cat) {
    final name = cat.toLowerCase();
    if (name.contains('life') || name.contains('cloth') || name.contains('style')) {
      return const Color(0xFFB8A2FB);
    }
    if (name.contains('travel') || name.contains('trans') || name.contains('car')) {
      return const Color(0xFFFFB2A2);
    }
    if (name.contains('coffee') || name.contains('drink') || name.contains('food')) {
      return const Color(0xFFFFB3D6);
    }
    return const Color(0xFFA2E8DD);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _cardColor(category);
    final icon = FinanceStyle.categoryIcon(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category[0].toUpperCase() + category.substring(1),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${expenseMoney(cents)} · $percentage%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
