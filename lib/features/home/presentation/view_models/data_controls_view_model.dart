import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/csv_export_service.dart';
import 'expense_view_model.dart';

class DataControlsState {
  const DataControlsState({this.busy = false, this.error, this.message});
  final bool busy;
  final String? error, message;
}

final dataControlsProvider =
    NotifierProvider.autoDispose<DataControlsViewModel, DataControlsState>(
      DataControlsViewModel.new,
    );

class DataControlsViewModel extends Notifier<DataControlsState> {
  @override
  DataControlsState build() => const DataControlsState();
  Future<void> export(Rect origin) async {
    if (state.busy) return;
    final tracker = ref.read(expenseViewModelProvider).value;
    if (tracker == null) {
      state = const DataControlsState(
        error: 'Wait for your records to finish loading.',
      );
      return;
    }
    state = const DataControlsState(busy: true);
    try {
      await ref
          .read(csvShareServiceProvider)
          .share(FinanceCsv.encode(tracker), origin: origin);
      if (ref.mounted) state = const DataControlsState();
    } catch (_) {
      if (ref.mounted) {
        state = const DataControlsState(
          error: 'Unable to export. Please try again.',
        );
      }
    }
  }

  Future<bool> reset(String confirmation) async {
    if (state.busy || confirmation != 'RESET') return false;
    state = const DataControlsState(busy: true);
    final saved = await ref.read(expenseViewModelProvider.notifier).reset();
    if (ref.mounted) {
      state = DataControlsState(
        error: saved ? null : 'Unable to reset. Your records have been kept.',
        message: saved ? 'Transactions and budgets reset.' : null,
      );
    }
    return saved;
  }
}
