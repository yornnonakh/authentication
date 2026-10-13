import 'package:intl/intl.dart';
import 'transaction.dart';
export 'money_input.dart';

// Compatibility for the first local expense schema; new UI uses Transaction.
enum ExpenseCategory {
  food('Food & drinks'),
  shopping('Shopping'),
  transport('Transport'),
  bills('Bills & utilities'),
  entertainment('Entertainment'),
  other('Other');

  const ExpenseCategory(this.label);
  final String label;
  String get transactionCategory => switch (this) {
    food => 'Food & Dining',
    shopping => 'Shopping',
    transport => 'Transportation',
    bills => 'Utilities & Bills',
    entertainment => 'Entertainment',
    other => 'Miscellaneous',
  };
}

class ExpenseEntry {
  const ExpenseEntry({
    required this.id,
    required this.title,
    required this.amountCents,
    required this.category,
    required this.date,
    this.isIncome = false,
  });
  final String id;
  final String title;
  final int amountCents;
  final ExpenseCategory category;
  final DateTime date;
  final bool isIncome;
  Transaction toTransaction() => Transaction(
    id: id,
    title: title,
    amount: amountCents / 100,
    date: date,
    type: isIncome ? TransactionType.income : TransactionType.expense,
    category: isIncome ? 'Other' : category.transactionCategory,
  );
  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'amountCents': amountCents,
    'category': category.name,
    'date': date.toIso8601String(),
    'isIncome': isIncome,
  };
  factory ExpenseEntry.fromJson(Map<String, dynamic> json) => ExpenseEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    amountCents: json['amountCents'] as int,
    category: ExpenseCategory.values.byName(json['category'] as String),
    date: DateTime.parse(json['date'] as String),
    isIncome: json['isIncome'] as bool,
  );
}

enum BudgetPace { notSet, onPace, approachingLimit, overBudget }

class ExpenseTracker {
  ExpenseTracker({
    List<ExpenseEntry> entries = const [],
    List<Transaction>? transactions,
    Map<String, int> budgets = const {},
  }) : transactions = List.unmodifiable(
         transactions ?? entries.map((entry) => entry.toTransaction()),
       ),
       budgets = Map.unmodifiable(budgets);

  final List<Transaction> transactions;
  final Map<String, int> budgets;
  // Retain the old API for local migration and existing integrations.
  List<ExpenseEntry> get entries => List.unmodifiable(
    transactions.map(
      (t) => ExpenseEntry(
        id: t.id,
        title: t.title,
        amountCents: t.amountCents,
        date: t.date,
        isIncome: t.isIncome,
        category: ExpenseCategory.values.firstWhere(
          (c) => c.transactionCategory == t.category,
          orElse: () => ExpenseCategory.other,
        ),
      ),
    ),
  );
  static String monthKey(DateTime month) => '${month.year}-${month.month}';
  List<Transaction> transactionsFor(DateTime month) =>
      transactions
          .where(
            (t) => t.date.year == month.year && t.date.month == month.month,
          )
          .toList()
        ..sort(compareTransactions);
  List<ExpenseEntry> entriesFor(DateTime month) =>
      entries
          .where(
            (t) => t.date.year == month.year && t.date.month == month.month,
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  int get totalIncome => transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amountCents);
  int get totalSpending => transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amountCents);
  int get availableBalance => totalIncome - totalSpending;
  int spentFor(DateTime month) => transactionsFor(
    month,
  ).where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amountCents);
  int incomeFor(DateTime month) => transactionsFor(
    month,
  ).where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amountCents);
  int budgetFor(DateTime month) => budgets[monthKey(month)] ?? 0;
  BudgetPace paceFor(DateTime month) {
    return budgetPaceFor(spentFor(month), budgetFor(month));
  }

  Map<String, int> categoriesFor(DateTime month) {
    final result = <String, int>{};
    for (final t in transactionsFor(month).where((t) => !t.isIncome)) {
      result.update(
        t.category,
        (v) => v + t.amountCents,
        ifAbsent: () => t.amountCents,
      );
    }
    final sorted = result.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }
}

int compareTransactions(Transaction a, Transaction b) {
  final date = b.date.compareTo(a.date);
  return date == 0 ? b.id.compareTo(a.id) : date;
}

String expenseMoney(int cents) => NumberFormat.currency(
  locale: 'en_US',
  symbol: '\$',
  decimalDigits: 2,
).format(cents / 100);

BudgetPace budgetPaceFor(int spent, int budget) {
  if (budget <= 0) return BudgetPace.notSet;
  final ratio = spent / budget;
  return ratio > 1
      ? BudgetPace.overBudget
      : ratio >= 0.8
      ? BudgetPace.approachingLimit
      : BudgetPace.onPace;
}
