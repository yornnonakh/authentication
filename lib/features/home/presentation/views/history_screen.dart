import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/transaction.dart';
import '../utils/finance_format.dart';
import '../view_models/expense_view_model.dart';
import '../view_models/ledger_view_model.dart';
import '../widgets/expense_entry_sheet.dart';
import '../widgets/finance_widgets.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final TextEditingController _search;
  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(ledgerFiltersProvider).query,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(Transaction transaction) async {
    final confirmation = Completer<bool>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final snackbar = messenger.showSnackBar(
      SnackBar(
        content: Text('Delete “${transaction.title}”?'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Delete',
          onPressed: () {
            if (!confirmation.isCompleted) confirmation.complete(true);
          },
        ),
      ),
    );
    snackbar.closed.then((_) {
      if (!confirmation.isCompleted) confirmation.complete(false);
    });
    final confirmed = await confirmation.future;
    if (confirmed && mounted) {
      final saved = await ref
          .read(expenseViewModelProvider.notifier)
          .deleteTransaction(transaction.id);
      if (mounted && !saved) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Unable to delete. Your transaction has been kept.'),
          ),
        );
      }
    }
    // The repository-backed state removes the row only after a confirmed save.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(expenseViewModelProvider);
    final filters = ref.watch(ledgerFiltersProvider);
    final model = ref.read(ledgerFiltersProvider.notifier);
    final groups = ref.watch(ledgerGroupsProvider);
    final count = ref.watch(ledgerTransactionsProvider).length;
    final colors = Theme.of(context).colorScheme;
    ref.listen(ledgerFiltersProvider, (_, next) {
      if (_search.text != next.query) _search.text = next.query;
    });
    return CustomScrollView(
      key: const PageStorageKey('history-scroll'),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: Navigator.of(context).canPop(),
          title: const Text('Transactions'),
          actions: [
            IconButton(
              tooltip: 'Add transaction',
              icon: const Icon(Icons.add_rounded),
              onPressed: data.hasValue
                  ? () => showExpenseEntrySheet(
                      context,
                      ref.read(financeMonthProvider),
                    )
                  : null,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SearchBar(
                controller: _search,
                hintText: 'Search merchants or titles',
                leading: const Icon(Icons.search_rounded, size: 20),
                trailing: filters.query.isEmpty
                    ? null
                    : [
                        IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => model.search(''),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                onChanged: model.search,
                elevation: const WidgetStatePropertyAll(0),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: FinanceCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Expense only'),
                        selected: filters.type == TransactionType.expense,
                        onSelected: (selected) => model.setType(
                          selected ? TransactionType.expense : null,
                        ),
                      ),
                      FilterChip(
                        label: const Text('Income only'),
                        selected: filters.type == TransactionType.income,
                        onSelected: (selected) => model.setType(
                          selected ? TransactionType.income : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey('${filters.type}-${filters.category}'),
                    initialValue: filters.category ?? 'All categories',
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem(
                        value: 'All categories',
                        child: Text('All categories'),
                      ),
                      for (final category
                          in filters.type == null
                              ? [
                                  ...TransactionCategories.expenses,
                                  ...TransactionCategories.income,
                                ]
                              : TransactionCategories.forType(filters.type!))
                        DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                    onChanged: (value) => model.setCategory(
                      value == 'All categories' ? null : value,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$count ${count == 1 ? 'transaction' : 'transactions'} · Newest first',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (data.isLoading)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (data.hasError)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FinanceCard(
                child: FinanceEmptyState(
                  title: 'Unable to load transactions',
                  message: 'Try again to load your saved records.',
                  action: TextButton(
                    onPressed: () => ref.invalidate(expenseViewModelProvider),
                    child: const Text('Try again'),
                  ),
                ),
              ),
            ),
          )
        else if (groups.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FinanceCard(
                child: FinanceEmptyState(
                  title:
                      filters.query.isNotEmpty ||
                          filters.type != null ||
                          filters.category != null
                      ? 'No matching transactions'
                      : 'Your ledger is ready',
                  message:
                      'Add a transaction or adjust your filters to see your records.',
                  action: TextButton(
                    onPressed: model.clear,
                    child: const Text('Clear filters'),
                  ),
                ),
              ),
            ),
          )
        else
          for (final group in groups) ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _MonthHeader(
                month: group.month,
                color: colors.surface,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              sliver: SliverList.builder(
                itemCount: group.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = group.transactions[index];
                  return Dismissible(
                    key: ValueKey(transaction.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) => _confirmDelete(transaction),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: colors.onErrorContainer,
                      ),
                    ),
                    child: FinanceTransactionTile(
                      transaction: transaction,
                      heroTag: 'ledger-${transaction.id}',
                      onTap: () => openTransactionDetail(
                        context,
                        transaction,
                        'ledger-${transaction.id}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _MonthHeader extends SliverPersistentHeaderDelegate {
  const _MonthHeader({
    required this.month,
    required this.color,
    required this.style,
  });
  final DateTime month;
  final Color color;
  final TextStyle style;
  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: color,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    alignment: Alignment.centerLeft,
    child: Text(financeMonthLabel(month), style: style),
  );
  @override
  bool shouldRebuild(covariant _MonthHeader oldDelegate) =>
      oldDelegate.month != month ||
      oldDelegate.color != color ||
      oldDelegate.style != style;
}
