import 'dart:async';

import 'package:authentication/features/home/data/repositories/preferences_expense_repository.dart';
import 'package:authentication/features/home/domain/models/expense_tracker.dart';
import 'package:authentication/features/home/presentation/view_models/expense_view_model.dart';
import 'package:authentication/features/profile/domain/models/user_profile.dart';
import 'package:authentication/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/expense_fakes.dart';

void main() {
  final month = DateTime(2026, 10);
  ExpenseEntry entry(
    String id,
    int cents, {
    bool income = false,
    DateTime? date,
  }) => ExpenseEntry(
    id: id,
    title: id,
    amountCents: cents,
    category: ExpenseCategory.food,
    date: date ?? month,
    isIncome: income,
  );

  ProviderContainer mount(
    FakeExpenseRepository repository, {
    String userId = 'user-1',
  }) {
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
        currentUserProfileProvider.overrideWithValue(
          UserProfile(id: userId, email: '', fullName: 'User'),
        ),
      ],
    );
    container.listen(expenseViewModelProvider, (_, next) {});
    addTearDown(container.dispose);
    return container;
  }

  test('decimal input rejects invalid values and preserves cents', () {
    expect(parseExpenseCents('19.99'), 1999);
    expect(parseExpenseCents(' 0.01 '), 1);
    expect(parseExpenseCents('123.4'), 12340);
    for (final input in ['0', '-1', '1.999', 'NaN', 'Infinity', '1e3', '']) {
      expect(parseExpenseCents(input), isNull);
    }
    expect(expenseMoney(-123456), '-\$1,234.56');
  });

  test(
    'monthly totals, income and budgets survive a provider reload',
    () async {
      final repository = FakeExpenseRepository();
      final container = mount(repository);
      await container.read(expenseViewModelProvider.future);
      final model = container.read(expenseViewModelProvider.notifier);
      expect(await model.add(entry('Lunch', 1999)), isTrue);
      expect(await model.add(entry('Salary', 250000, income: true)), isTrue);
      expect(
        await model.add(entry('Old expense', 900, date: DateTime(2026, 9, 30))),
        isTrue,
      );
      expect(await model.setBudget(month, 150000), isTrue);
      container.invalidate(expenseViewModelProvider);
      final loaded = await container.read(expenseViewModelProvider.future);
      expect(loaded.spentFor(month), 1999);
      expect(loaded.incomeFor(month), 250000);
      expect(loaded.budgetFor(month), 150000);
      expect(loaded.entriesFor(month), hasLength(2));
      expect(loaded.spentFor(DateTime(2026, 9)), 900);
      final otherUser = mount(repository, userId: 'user-2');
      expect(
        (await otherUser.read(expenseViewModelProvider.future)).entries,
        isEmpty,
      );
    },
  );

  test('failed saves preserve totals and can be retried', () async {
    final repository = FakeExpenseRepository()..failSave = true;
    final container = mount(repository);
    await container.read(expenseViewModelProvider.future);
    final model = container.read(expenseViewModelProvider.notifier);
    expect(await model.add(entry('Lunch', 1999)), isFalse);
    expect(container.read(expenseViewModelProvider).value!.entries, isEmpty);
    repository.failSave = false;
    expect(await model.add(entry('Lunch', 1999)), isTrue);
    expect(
      container.read(expenseViewModelProvider).value!.spentFor(month),
      1999,
    );
  });

  test('duplicate submissions cannot overwrite a pending save', () async {
    final repository = FakeExpenseRepository()..pendingSave = Completer<void>();
    final container = mount(repository);
    await container.read(expenseViewModelProvider.future);
    final model = container.read(expenseViewModelProvider.notifier);
    final first = model.add(entry('Lunch', 1999));
    expect(await model.add(entry('Duplicate', 1999)), isFalse);
    repository.pendingSave!.complete();
    expect(await first, isTrue);
    expect(
      container.read(expenseViewModelProvider).value!.entries,
      hasLength(1),
    );
  });
}
