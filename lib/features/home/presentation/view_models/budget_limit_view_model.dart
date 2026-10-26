import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_view_model.dart';

class BudgetLimitState {
  const BudgetLimitState({
    required this.cents,
    this.isSaving = false,
    this.error,
  });
  final int cents;
  final bool isSaving;
  final String? error;
}

final budgetLimitProvider = NotifierProvider.autoDispose
    .family<BudgetLimitViewModel, BudgetLimitState, DateTime>(
      BudgetLimitViewModel.new,
    );

class BudgetLimitViewModel extends Notifier<BudgetLimitState> {
  BudgetLimitViewModel(this.month);
  final DateTime month;
  @override
  BudgetLimitState build() => BudgetLimitState(
    cents: ref.watch(
      expenseViewModelProvider.select(
        (data) => data.value?.budgetFor(month) ?? 0,
      ),
    ),
  );
  void adjust(int cents) {
    if (!state.isSaving && cents > 0) state = BudgetLimitState(cents: cents);
  }

  Future<void> commit() async {
    if (state.isSaving) return;
    final cents = state.cents;
    state = BudgetLimitState(cents: cents, isSaving: true);
    final saved = await ref
        .read(expenseViewModelProvider.notifier)
        .setBudget(month, cents);
    if (!ref.mounted) return;
    state = BudgetLimitState(
      cents: saved
          ? cents
          : ref.read(expenseViewModelProvider).value?.budgetFor(month) ?? 0,
      error: saved ? null : 'Unable to save the budget. Please try again.',
    );
  }
}
