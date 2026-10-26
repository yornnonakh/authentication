import '../../../../core/widgets/ios_scroll_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/expense_tracker.dart';
import '../../domain/models/transaction.dart';
import '../view_models/expense_view_model.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import '../view_models/ledger_view_model.dart';
import '../widgets/finance_page_header.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/spending_chart.dart';
import 'history_screen.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  bool _income = false;
  double _swipeDistance = 0;

  void _selectType(bool income) {
    if (_income != income) setState(() => _income = income);
  }

  void _finishSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (_swipeDistance.abs() >= 50 || velocity.abs() >= 200) {
      _selectType(velocity.abs() >= 200 ? velocity < 0 : _swipeDistance < 0);
    }
    _swipeDistance = 0;
  }

  Map<String, int> _categories(ExpenseTracker data, DateTime month) {
    final result = <String, int>{};
    for (final transaction
        in data.transactionsFor(month).where((t) => t.isIncome == _income)) {
      result.update(
        transaction.category,
        (value) => value + transaction.amountCents,
        ifAbsent: () => transaction.amountCents,
      );
    }
    final entries = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  @override
  Widget build(BuildContext context) {
    // Retain the selected filters while the transaction route is opening.
    ref.listen(ledgerFiltersProvider, (_, _) {});
    final data = ref.watch(expenseViewModelProvider);
    final month = ref.watch(financeMonthProvider);
    final colors = Theme.of(context).colorScheme;
    return IosScrollPage(
      key: const PageStorageKey('report-scroll'),
      title: 'Report',
      onBack: ref.read(dashboardNavigationViewModelProvider.notifier).showHome,
      backLabel: 'Home',
      bottomMode: NavigationBarBottomMode.always,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          64 +
              (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(
                0.0,
                double.infinity,
              ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
          child: SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<bool>(
              groupValue: _income,
              backgroundColor: colors.surfaceContainer.withValues(alpha: 0.75),
              thumbColor: colors.surfaceContainerLow,
              padding: const EdgeInsets.all(4),
              onValueChanged: (value) {
                if (value != null) _selectType(value);
              },
              children: {
                for (final income in [false, true])
                  income: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      income ? 'Income' : 'Expenses',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _income == income
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _income == income
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ),
              },
            ),
          ),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => _swipeDistance = 0,
        onHorizontalDragUpdate: (details) =>
            _swipeDistance += details.primaryDelta ?? 0,
        onHorizontalDragEnd: _finishSwipe,
        onHorizontalDragCancel: () => _swipeDistance = 0,
        child: data.when(
          loading: () => const FinanceCard(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (_, _) => FinanceCard(
            child: FinanceEmptyState(
              title: 'Unable to load your report',
              message: 'Try again to load your transactions.',
              action: TextButton(
                onPressed: () => ref.invalidate(expenseViewModelProvider),
                child: const Text('Try again'),
              ),
            ),
          ),
          data: (tracker) => _report(context, tracker, month),
        ),
      ),
    );
  }

  Widget _report(BuildContext context, ExpenseTracker tracker, DateTime month) {
    final colors = Theme.of(context).colorScheme;
    final categories = _categories(tracker, month);
    final previous = _categories(
      tracker,
      DateTime(month.year, month.month - 1),
    );
    final total = categories.values.fold(0, (sum, value) => sum + value);
    final count = tracker
        .transactionsFor(month)
        .where((t) => t.isIncome == _income)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        FinanceCard(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const Flexible(child: FinanceMonthPicker()),
                ],
              ),
              const SizedBox(height: 8),
              if (total == 0)
                FinanceEmptyState(
                  title: _income
                      ? 'Your income story starts here'
                      : 'Your spending story starts here',
                  message:
                      'Add ${_income ? 'income' : 'expenses'} to see your monthly report.',
                  icon: Icons.donut_large_rounded,
                )
              else ...[
                SpendingChart(
                  categories: categories,
                  large: true,
                  maxDiameter: 240,
                  showLegend: false,
                  showHint: false,
                  isIncome: _income,
                ),
                const SizedBox(height: 8),
                Text(
                  '$count ${count == 1 ? 'transaction' : 'transactions'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 24),
          FinanceSectionHeading(
            title: 'Categories',
            action: Text(
              '${categories.length} total',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          Material(
            color: colors.surfaceContainerLow,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                for (final category in categories.entries) ...[
                  if (category.key != categories.keys.first)
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: colors.outline.withValues(alpha: 0.5),
                    ),
                  _ReportCategory(
                    category: category.key,
                    cents: category.value,
                    total: total,
                    previous: previous[category.key] ?? 0,
                    onTap: () => _openCategory(context, category.key),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _openCategory(BuildContext context, String category) {
    final filters = ref.read(ledgerFiltersProvider.notifier);
    filters.clear();
    filters.setType(_income ? TransactionType.income : TransactionType.expense);
    filters.setCategory(category);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: SafeArea(child: HistoryScreen())),
      ),
    );
  }
}

class _ReportCategory extends StatelessWidget {
  const _ReportCategory({
    required this.category,
    required this.cents,
    required this.total,
    required this.previous,
    required this.onTap,
  });
  final String category;
  final int cents, total, previous;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = FinanceStyle.categoryColor(category);
    final change = previous == 0
        ? null
        : ((cents - previous) / previous * 100).round();
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                FinanceStyle.categoryIcon(category),
                color: color,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              expenseMoney(cents),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        '${(cents / total * 100).toStringAsFixed(1)}% of total',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        change == null
                            ? 'New this month'
                            : '${change >= 0 ? '+' : ''}$change% vs last month',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
