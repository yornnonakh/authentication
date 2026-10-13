import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/view_models/profile_view_model.dart';
import '../../data/repositories/preferences_expense_repository.dart';
import '../../domain/models/expense_tracker.dart';
import '../../domain/models/transaction.dart';

final expenseViewModelProvider =
    AsyncNotifierProvider.autoDispose<ExpenseViewModel, ExpenseTracker>(
      ExpenseViewModel.new,
      retry: (count, error) => null,
    );
final financeMonthProvider =
    NotifierProvider.autoDispose<FinanceMonthViewModel, DateTime>(
      FinanceMonthViewModel.new,
    );

class FinanceMonthViewModel extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month);
  void select(DateTime date) => state = DateTime(date.year, date.month);
  void step(int offset) {
    final next = DateTime(state.year, state.month + offset);
    final now = DateTime.now();
    if (!next.isAfter(DateTime(now.year, now.month)) && next.year >= 2000) {
      state = next;
    }
  }
}

class ExpenseViewModel extends AsyncNotifier<ExpenseTracker> {
  late ExpenseRepository _repository;
  String? _userId;
  bool _saving = false;
  int _generation = 0;
  @override
  Future<ExpenseTracker> build() async {
    _generation++;
    _repository = ref.watch(expenseRepositoryProvider);
    _userId = ref.watch(currentUserProfileProvider.select((p) => p?.id));
    if (_userId == null) return ExpenseTracker();
    return _repository.load(_userId!);
  }

  Future<bool> add(ExpenseEntry entry) async {
    if (entry.amountCents <= 0 || entry.title.trim().isEmpty) return false;
    return saveTransaction(entry.toTransaction());
  }

  Future<bool> saveTransaction(Transaction transaction) async {
    final current = state.value;
    if (current == null ||
        !TransactionValidation.validDate(transaction.date, DateTime.now())) {
      return false;
    }
    return _save(
      ExpenseTracker(
        transactions: [
          transaction,
          ...current.transactions.where((t) => t.id != transaction.id),
        ],
        budgets: current.budgets,
      ),
    );
  }

  Future<bool> deleteTransaction(String id) async {
    final current = state.value;
    if (current == null) return false;
    return _save(
      ExpenseTracker(
        transactions: current.transactions.where((t) => t.id != id).toList(),
        budgets: current.budgets,
      ),
    );
  }

  Future<bool> reset() => _save(ExpenseTracker());
  Future<bool> setBudget(DateTime month, int cents) async {
    final current = state.value;
    if (current == null || cents <= 0) return false;
    return _save(
      ExpenseTracker(
        transactions: current.transactions,
        budgets: {...current.budgets, ExpenseTracker.monthKey(month): cents},
      ),
    );
  }

  Future<bool> _save(ExpenseTracker next) async {
    if (_saving || _userId == null || state.isLoading) return false;
    _saving = true;
    final repository = _repository;
    final userId = _userId!;
    final generation = _generation;
    try {
      await repository.save(userId, next);
      if (!ref.mounted || _generation != generation || _userId != userId) {
        return false;
      }
      state = AsyncData(next);
      return true;
    } catch (_) {
      return false;
    } finally {
      _saving = false;
    }
  }
}
