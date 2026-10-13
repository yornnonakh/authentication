import 'package:authentication/features/home/presentation/view_models/budget_limit_view_model.dart';
import 'dart:ui';
import 'package:authentication/features/home/data/repositories/preferences_expense_repository.dart';
import 'package:authentication/features/home/data/services/csv_export_service.dart';
import 'package:authentication/features/home/domain/models/expense_tracker.dart';
import 'package:authentication/features/home/domain/models/transaction.dart';
import 'package:authentication/features/home/presentation/view_models/data_controls_view_model.dart';
import 'package:authentication/features/home/presentation/view_models/expense_view_model.dart';
import 'package:authentication/features/home/presentation/view_models/ledger_view_model.dart';
import 'package:authentication/features/home/presentation/view_models/transaction_form_view_model.dart';
import 'package:authentication/features/profile/domain/models/user_profile.dart';
import 'package:authentication/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/expense_fakes.dart';

class FakeCsvShare implements CsvShareService {
  String? contents;
  @override
  Future<void> share(String contents, {required Rect origin}) async {
    this.contents = contents;
  }
}

void main() {
  final month = DateTime(2026, 10);
  Transaction transaction(
    String id,
    double amount, {
    TransactionType type = TransactionType.expense,
    String? category,
    String? title,
    String? notes,
    DateTime? date,
  }) => Transaction(
    id: id,
    title: title ?? id,
    amount: amount,
    date: date ?? month,
    type: type,
    category: category ?? TransactionCategories.forType(type).first,
    notes: notes,
  );
  ProviderContainer mount(
    FakeExpenseRepository repository, {
    FakeCsvShare? sharing,
  }) {
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
        currentUserProfileProvider.overrideWithValue(
          const UserProfile(id: 'user-1', email: '', fullName: 'User'),
        ),
        if (sharing != null) csvShareServiceProvider.overrideWithValue(sharing),
      ],
    );
    container.listen(expenseViewModelProvider, (_, next) {});
    addTearDown(container.dispose);
    return container;
  }

  test(
    'strict immutable transaction rejects nonfinite amounts and invalid categories',
    () {
      for (final amount in [0.0, -1.0, double.nan, double.infinity]) {
        expect(() => transaction('1', amount), throwsArgumentError);
      }
      expect(
        () => transaction('1', 1, category: 'Salary'),
        throwsArgumentError,
      );
      expect(() => transaction('1', 1, title: ' '), throwsArgumentError);
      final original = transaction('1', 12.34, notes: 'A note');
      final loaded = Transaction.fromJson(original.toJson());
      expect(loaded.amountCents, 1234);
      expect(loaded.notes, 'A note');
      expect(loaded.type, TransactionType.expense);
    },
  );
  test('budget thresholds and all-time balances use exact cents', () {
    final tracker = ExpenseTracker(
      transactions: [
        transaction('a', 0.1),
        transaction('b', 0.2),
        transaction('c', 1, type: TransactionType.income),
      ],
      budgets: {ExpenseTracker.monthKey(month): 100},
    );
    expect(tracker.totalSpending, 30);
    expect(tracker.availableBalance, 70);
    expect(tracker.paceFor(month), BudgetPace.onPace);
    for (final spending in [80, 100, 101]) {
      final data = ExpenseTracker(
        transactions: [transaction('x', spending / 100)],
        budgets: {ExpenseTracker.monthKey(month): 100},
      );
      expect(
        data.paceFor(month),
        spending > 100 ? BudgetPace.overBudget : BudgetPace.approachingLimit,
      );
    }
    expect(tracker.paceFor(DateTime(2026, 9)), BudgetPace.notSet);
  });
  test(
    'fuzzy title matching supports substrings, missing letters and typos',
    () {
      for (final query in ['STAR', 'strbcks', 'Starbuks', 'starbucks coffe']) {
        expect(
          fuzzyTitleMatches('Starbucks Coffee', query),
          isTrue,
          reason: query,
        );
      }
      expect(fuzzyTitleMatches('Starbucks Coffee', 'Hospital'), isFalse);
    },
  );
  test(
    'budget slider drafts update live and failed writes restore the saved limit',
    () async {
      final repository = FakeExpenseRepository();
      final container = mount(repository);
      await container.read(expenseViewModelProvider.future);
      await container
          .read(expenseViewModelProvider.notifier)
          .setBudget(month, 10000);
      final provider = budgetLimitProvider(month);
      container.listen(provider, (_, next) {});
      final limit = container.read(provider.notifier);
      limit.adjust(15000);
      expect(container.read(provider).cents, 15000);
      expect(
        container.read(expenseViewModelProvider).value!.budgetFor(month),
        10000,
      );
      await limit.commit();
      expect((await repository.load('user-1')).budgetFor(month), 15000);
      repository.failSave = true;
      limit.adjust(20000);
      await limit.commit();
      expect(container.read(provider).cents, 15000);
      expect(container.read(provider).error, isNotNull);
    },
  );

  test(
    'ledger combines query, type and category and sorts groups newest first',
    () async {
      final repository = FakeExpenseRepository();
      await repository.save(
        'user-1',
        ExpenseTracker(
          transactions: [
            transaction(
              '1',
              4.75,
              title: 'Starbucks',
              date: DateTime(2026, 10, 12),
            ),
            transaction(
              '2',
              100,
              type: TransactionType.income,
              title: 'Salary',
            ),
            transaction(
              '3',
              20,
              title: 'Bus pass',
              category: 'Transportation',
              date: DateTime(2026, 9, 3),
            ),
          ],
        ),
      );
      final container = mount(repository);
      await container.read(expenseViewModelProvider.future);
      final filters = container.read(ledgerFiltersProvider.notifier);
      expect(container.read(ledgerGroupsProvider).first.month, month);
      filters.setType(TransactionType.expense);
      filters.setCategory('Food & Dining');
      filters.search('strbcks');
      expect(
        container.read(ledgerTransactionsProvider).single.title,
        'Starbucks',
      );
      filters.setType(TransactionType.income);
      expect(container.read(ledgerFiltersProvider).category, isNull);
      filters.search('');
      expect(container.read(ledgerTransactionsProvider).single.title, 'Salary');
    },
  );
  test(
    'edit preserves ID, notes and category; delete and reset persist',
    () async {
      final repository = FakeExpenseRepository();
      final container = mount(repository);
      await container.read(expenseViewModelProvider.future);
      final model = container.read(expenseViewModelProvider.notifier);
      await model.saveTransaction(transaction('1', 4.75));
      await model.saveTransaction(
        transaction('1', 9.5, category: 'Healthcare', notes: 'Medicine'),
      );
      expect(
        container.read(expenseViewModelProvider).value!.transactions,
        hasLength(1),
      );
      final reopened = await repository.load('user-1');
      expect(reopened.transactions.single.notes, 'Medicine');
      expect(reopened.transactions.single.category, 'Healthcare');
      await model.deleteTransaction('1');
      expect((await repository.load('user-1')).transactions, isEmpty);
      await model.saveTransaction(transaction('2', 10));
      await model.setBudget(month, 10000);
      await model.reset();
      expect((await repository.load('user-1')).budgets, isEmpty);
    },
  );
  test(
    'form validation prevents future dates and mismatched income categories',
    () async {
      final container = mount(FakeExpenseRepository());
      await container.read(expenseViewModelProvider.future);
      container.listen(transactionFormProvider(null), (_, next) {});
      final form = container.read(transactionFormProvider(null).notifier);
      form.setType(TransactionType.income);
      form.setCategory('Food & Dining');
      expect(container.read(transactionFormProvider(null)).category, 'Salary');
      final before = container.read(transactionFormProvider(null)).date;
      form.setDate(DateTime.now().add(const Duration(days: 1)));
      expect(container.read(transactionFormProvider(null)).date, before);
      form.setTitle('Salary');
      form.setAmount('-1');
      expect(await form.save(), isNull);
      form.setAmount('2000');
      form.setNotes('Monthly payment');
      expect((await form.save())!.type, TransactionType.income);
      expect(
        container.read(expenseViewModelProvider).value!.totalIncome,
        200000,
      );
    },
  );
  test('CSV escapes quotes, commas, newlines and spreadsheet formulas', () {
    final encoded = FinanceCsv.encode(
      ExpenseTracker(
        transactions: [
          transaction(
            '1',
            4.75,
            title: 'Coffee, "large"',
            notes: '=SUM(A1:A2)\nSecond line',
          ),
        ],
      ),
    );
    final decoded = csv.decode(encoded);
    expect(decoded.first, [
      'ID',
      'Title',
      'Amount',
      'Currency',
      'Date',
      'Type',
      'Category',
      'Notes',
    ]);
    expect(decoded[1][1], 'Coffee, "large"');
    expect(decoded[1][2], '4.75');
    expect(decoded[1][7], "'=SUM(A1:A2)\nSecond line");
  });
  test(
    'data controls export through service and require exact reset confirmation',
    () async {
      final sharing = FakeCsvShare();
      final repository = FakeExpenseRepository();
      final container = mount(repository, sharing: sharing);
      await container.read(expenseViewModelProvider.future);
      await container
          .read(expenseViewModelProvider.notifier)
          .saveTransaction(transaction('1', 12.34));
      container.listen(dataControlsProvider, (_, next) {});
      final controls = container.read(dataControlsProvider.notifier);
      await controls.export(const Rect.fromLTWH(0, 0, 100, 40));
      expect(sharing.contents, contains('12.34'));
      expect(await controls.reset('reset'), isFalse);
      expect((await repository.load('user-1')).transactions, hasLength(1));
      expect(await controls.reset('RESET'), isTrue);
      expect((await repository.load('user-1')).transactions, isEmpty);
    },
  );
}
