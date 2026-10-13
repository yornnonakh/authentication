import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/transaction.dart';
import 'expense_view_model.dart';

class SpendingDay {
  const SpendingDay({required this.date, required this.cents});
  final DateTime date;
  final int cents;
}

final spendingActivityProvider = Provider.autoDispose
    .family<List<SpendingDay>, DateTime>((ref, month) {
      final now = DateTime.now();
      final end = month.year == now.year && month.month == now.month
          ? DateTime(now.year, now.month, now.day)
          : DateTime(month.year, month.month + 1, 0);
      final entries =
          ref.watch(expenseViewModelProvider).value?.transactions ??
          <Transaction>[];
      return List.generate(7, (index) {
        final day = end.subtract(Duration(days: 6 - index));
        final cents = entries
            .where(
              (t) =>
                  !t.isIncome &&
                  t.date.year == day.year &&
                  t.date.month == day.month &&
                  t.date.day == day.day,
            )
            .fold(0, (sum, t) => sum + t.amountCents);
        return SpendingDay(date: day, cents: cents);
      });
    });
