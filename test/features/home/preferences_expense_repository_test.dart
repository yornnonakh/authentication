import 'dart:convert';
import 'package:authentication/features/home/data/repositories/preferences_expense_repository.dart';
import 'package:authentication/features/home/domain/models/expense_tracker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryPreferences implements SharedPreferencesAsync {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'legacy transactions migrate without losing budgets and reset removes backups',
    () async {
      final preferences = MemoryPreferences();
      final month = DateTime(2026, 10);
      preferences.values['finsight.expenses.v1.user-1'] = jsonEncode({
        'entries': [
          ExpenseEntry(
            id: 'old',
            title: 'Old lunch',
            amountCents: 475,
            category: ExpenseCategory.food,
            date: month,
          ).toJson(),
        ],
        'budgets': {ExpenseTracker.monthKey(month): 10000},
      });
      final repository = PreferencesExpenseRepository(preferences);
      final loaded = await repository.load('user-1');
      expect(loaded.transactions.single.category, 'Food & Dining');
      expect(loaded.transactions.single.amount, 4.75);
      expect(loaded.budgetFor(month), 10000);
      expect(
        preferences.values.containsKey('finsight.finance.v2.user-1'),
        isTrue,
      );
      await repository.save('user-1', ExpenseTracker());
      expect(
        preferences.values.containsKey('finsight.expenses.v1.user-1'),
        isFalse,
      );
      expect((await repository.load('user-1')).transactions, isEmpty);
    },
  );

  test(
    'stored transactions and monthly budgets round trip by account',
    () async {
      final preferences = MemoryPreferences();
      final repository = PreferencesExpenseRepository(preferences);
      final month = DateTime(2026, 10);
      expect((await repository.load('new-user')).entries, isEmpty);
      await repository.save(
        'user-1',
        ExpenseTracker(
          entries: [
            ExpenseEntry(
              id: '1',
              title: 'Groceries',
              amountCents: 4599,
              category: ExpenseCategory.shopping,
              date: DateTime(2026, 10, 13),
            ),
          ],
          budgets: {ExpenseTracker.monthKey(month): 100000},
        ),
      );
      final reopened = PreferencesExpenseRepository(preferences);
      final data = await reopened.load('user-1');
      expect(data.entries.single.title, 'Groceries');
      expect(data.entries.single.category, ExpenseCategory.shopping);
      expect(data.entries.single.date, DateTime(2026, 10, 13));
      expect(data.spentFor(month), 4599);
      expect(data.budgetFor(month), 100000);
      expect((await reopened.load('user-2')).entries, isEmpty);
    },
  );

  test(
    'corrupt storage reports a load error without erasing records',
    () async {
      final preferences = MemoryPreferences();
      final repository = PreferencesExpenseRepository(preferences);
      await repository.save('user-1', ExpenseTracker());
      final key = preferences.values.keys.single;
      preferences.values[key] = 'broken JSON';
      await expectLater(repository.load('user-1'), throwsFormatException);
      expect(preferences.values[key], 'broken JSON');
    },
  );
}
