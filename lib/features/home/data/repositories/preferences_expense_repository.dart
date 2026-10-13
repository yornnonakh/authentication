import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/expense_tracker.dart';
import '../../domain/models/transaction.dart';

abstract interface class ExpenseRepository {
  Future<ExpenseTracker> load(String userId);
  Future<void> save(String userId, ExpenseTracker tracker);
}

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => PreferencesExpenseRepository(SharedPreferencesAsync()),
);

class PreferencesExpenseRepository implements ExpenseRepository {
  PreferencesExpenseRepository(this.preferences);
  final SharedPreferencesAsync preferences;
  String _key(String userId) => 'finsight.finance.v2.$userId';
  String _legacyKey(String userId) => 'finsight.expenses.v1.$userId';

  @override
  Future<ExpenseTracker> load(String userId) async {
    final stored = await preferences.getString(_key(userId));
    if (stored != null) {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      return ExpenseTracker(
        transactions: (json['transactions'] as List<dynamic>)
            .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
            .toList(),
        budgets: (json['budgets'] as Map<String, dynamic>).cast<String, int>(),
      );
    }
    final legacy = await preferences.getString(_legacyKey(userId));
    if (legacy == null) return ExpenseTracker();
    final json = jsonDecode(legacy) as Map<String, dynamic>;
    final migrated = ExpenseTracker(
      entries: (json['entries'] as List<dynamic>)
          .map((t) => ExpenseEntry.fromJson(t as Map<String, dynamic>))
          .toList(),
      budgets: (json['budgets'] as Map<String, dynamic>).cast<String, int>(),
    );
    await save(userId, migrated);
    // Keep the original record as a migration backup. v2 always takes precedence.
    return migrated;
  }

  @override
  Future<void> save(String userId, ExpenseTracker tracker) async {
    if (tracker.transactions.isEmpty && tracker.budgets.isEmpty) {
      await preferences.remove(_legacyKey(userId));
    }
    await preferences.setString(
      _key(userId),
      jsonEncode({
        'transactions': tracker.transactions.map((t) => t.toJson()).toList(),
        'budgets': tracker.budgets,
      }),
    );
  }
}
