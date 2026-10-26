import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/transaction.dart';
import '../utils/finance_format.dart';
import '../view_models/expense_view_model.dart';
import '../widgets/expense_entry_sheet.dart';
import '../widgets/finance_widgets.dart';
import '../../../../core/widgets/ios_scroll_page.dart';

void openTransactionDetail(
  BuildContext context,
  Transaction transaction,
  String heroTag,
) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) =>
        TransactionDetailScreen(transaction: transaction, heroTag: heroTag),
  ),
);

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.heroTag,
  });
  final Transaction transaction;
  final String heroTag;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref
        .watch(expenseViewModelProvider)
        .value
        ?.transactions;
    final current =
        transactions?.where((t) => t.id == transaction.id).firstOrNull ??
        transaction;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: IosScrollPage(
          title: 'Transaction details',
          maxContentWidth: 640,
          padding: const EdgeInsets.all(24),
          child: FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: TransactionIcon(
                    transaction: current,
                    size: 88,
                    heroTag: heroTag,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  current.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${current.isIncome ? '+' : '-'}${expenseMoney(current.amountCents)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: current.isIncome
                        ? FinanceStyle.income(context)
                        : FinanceStyle.expense(context),
                  ),
                ),
                const SizedBox(height: 28),
                FinanceCard(
                  child: Column(
                    children: [
                      _Detail(
                        label: 'Type',
                        value: current.isIncome ? 'Income' : 'Expense',
                      ),
                      const Divider(height: 28),
                      _Detail(label: 'Category', value: current.category),
                      const Divider(height: 28),
                      _Detail(
                        label: 'Date',
                        value: financeDateLabel(current.date),
                      ),
                      const Divider(height: 28),
                      const _Detail(label: 'Currency', value: 'USD'),
                    ],
                  ),
                ),
                if (current.notes != null) ...[
                  const SizedBox(height: 20),
                  FinanceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(current.notes!),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => showExpenseEntrySheet(
                    context,
                    DateTime(current.date.year, current.date.month),
                    transaction: current,
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit transaction'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Saved locally on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
