import 'dart:async';
import 'dart:convert';

import 'package:authentication/features/home/data/repositories/preferences_expense_repository.dart';
import 'package:authentication/features/home/domain/models/expense_tracker.dart';
import 'package:authentication/features/home/domain/models/transaction.dart';

class FakeExpenseRepository implements ExpenseRepository {
  final Map<String, String> records = {};
  bool failSave = false;
  bool failLoad = false;
  Completer<void>? pendingSave;

  @override
  Future<ExpenseTracker> load(String userId) async {
    if (failLoad) throw Exception('Unable to load');
    final record = records[userId];
    if (record == null) return ExpenseTracker();
    final json = jsonDecode(record) as Map<String, dynamic>;
    return ExpenseTracker(
      transactions: (json['transactions'] as List<dynamic>)
          .map((entry) => Transaction.fromJson(entry as Map<String, dynamic>))
          .toList(),
      budgets: (json['budgets'] as Map<String, dynamic>).cast<String, int>(),
    );
  }

  @override
  Future<void> save(String userId, ExpenseTracker tracker) async {
    if (pendingSave != null) await pendingSave!.future;
    if (failSave) throw Exception('Unable to save');
    records[userId] = jsonEncode({
      'transactions': tracker.transactions
          .map((entry) => entry.toJson())
          .toList(),
      'budgets': tracker.budgets,
    });
  }
}
