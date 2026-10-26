import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/receipt_scanner.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/money_input.dart';
import 'expense_view_model.dart';

class TransactionFormState {
  const TransactionFormState({
    required this.date,
    this.title = '',
    this.amount = '',
    this.notes = '',
    this.type = TransactionType.expense,
    this.category = 'Food & Dining',
    this.isScanning = false,
    this.isSaving = false,
    this.scanVersion = 0,
    this.error,
  });
  final String title, amount, notes, category;
  final TransactionType type;
  final DateTime date;
  final bool isScanning, isSaving;
  final int scanVersion;
  final String? error;
  bool get busy => isScanning || isSaving;
  TransactionFormState copyWith({
    String? title,
    String? amount,
    String? notes,
    TransactionType? type,
    String? category,
    DateTime? date,
    bool? isScanning,
    bool? isSaving,
    int? scanVersion,
    String? error,
  }) => TransactionFormState(
    title: title ?? this.title,
    amount: amount ?? this.amount,
    notes: notes ?? this.notes,
    type: type ?? this.type,
    category: category ?? this.category,
    date: date ?? this.date,
    isScanning: isScanning ?? this.isScanning,
    isSaving: isSaving ?? this.isSaving,
    scanVersion: scanVersion ?? this.scanVersion,
    error: error,
  );
}

final transactionFormProvider = NotifierProvider.autoDispose
    .family<TransactionFormViewModel, TransactionFormState, Transaction?>(
      TransactionFormViewModel.new,
    );

class TransactionFormViewModel extends Notifier<TransactionFormState> {
  TransactionFormViewModel(this.original);
  final Transaction? original;
  @override
  TransactionFormState build() {
    final month = ref.read(financeMonthProvider);
    final now = DateTime.now();
    return TransactionFormState(
      title: original?.title ?? '',
      amount: original?.amount.toStringAsFixed(2) ?? '',
      notes: original?.notes ?? '',
      type: original?.type ?? TransactionType.expense,
      category: original?.category ?? 'Food & Dining',
      date:
          original?.date ??
          (month.year == now.year && month.month == now.month ? now : month),
    );
  }

  void setTitle(String value) => state = state.copyWith(title: value);
  void setAmount(String value) => state = state.copyWith(amount: value);
  void setNotes(String value) => state = state.copyWith(notes: value);
  void setCategory(String value) {
    if (TransactionCategories.forType(state.type).contains(value)) {
      state = state.copyWith(category: value);
    }
  }

  void setType(TransactionType type) => state = state.copyWith(
    type: type,
    category: TransactionCategories.forType(type).first,
  );
  void setDate(DateTime date) {
    if (TransactionValidation.validDate(date, DateTime.now())) {
      state = state.copyWith(date: date);
    }
  }

  Future<void> scan() async {
    if (state.busy) return;
    state = state.copyWith(isScanning: true);
    try {
      final receipt = await ref.read(receiptScannerProvider).scan();
      if (!ref.mounted) return;
      state = state.copyWith(
        title: receipt.merchant,
        amount: receipt.amount.toStringAsFixed(2),
        type: TransactionType.expense,
        category: receipt.category,
        isScanning: false,
        scanVersion: state.scanVersion + 1,
      );
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(
          isScanning: false,
          error: 'Unable to scan this receipt. Please try again.',
        );
      }
    }
  }

  Future<Transaction?> save() async {
    if (state.busy) return null;
    final error =
        TransactionValidation.title(state.title) ??
        TransactionValidation.amount(state.amount) ??
        TransactionValidation.notes(state.notes) ??
        (TransactionValidation.validDate(state.date, DateTime.now())
            ? null
            : 'Choose a date that is not in the future.');
    if (error != null) {
      state = state.copyWith(error: error);
      return null;
    }
    final transaction = Transaction(
      id: original?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: state.title,
      amount: parseExpenseCents(state.amount)! / 100,
      date: state.date,
      type: state.type,
      category: state.category,
      notes: state.notes,
    );
    state = state.copyWith(isSaving: true);
    final saved = await ref
        .read(expenseViewModelProvider.notifier)
        .saveTransaction(transaction);
    if (!ref.mounted) return null;
    state = state.copyWith(
      isSaving: false,
      error: saved ? null : 'Unable to save. Please try again.',
    );
    if (saved) ref.read(financeMonthProvider.notifier).select(transaction.date);
    return saved ? transaction : null;
  }
}
