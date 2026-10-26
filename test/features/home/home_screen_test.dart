import 'package:authentication/features/home/data/repositories/preferences_expense_repository.dart';
import 'package:authentication/features/home/domain/models/expense_tracker.dart';
import 'package:authentication/features/home/presentation/views/home_screen.dart';
import 'package:authentication/features/home/presentation/widgets/expense_entry_sheet.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/expense_fakes.dart';
import '../../support/profile_fakes.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    FakeExpenseRepository repository, {
    double width = 390,
    double textScale = 1,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const Scaffold(body: SafeArea(child: HomeScreen())),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('adds expenses and income, updates budget and switches months', (
    tester,
  ) async {
    final repository = FakeExpenseRepository();
    await mount(tester, repository);
    await tester.ensureVisible(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a description.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Lunch');
    await tester.enterText(find.byType(TextFormField).at(1), '19.99');
    await tester.ensureVisible(find.text('Save expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpenseEntrySheet), findsNothing);
    expect(find.text('\$19.99'), findsWidgets);
    await tester.ensureVisible(find.text('Set budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set budget'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '100');
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();
    expect(find.text('\$80.01 left to spend'), findsOneWidget);
    await tester.ensureVisible(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Income').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Salary');
    await tester.enterText(find.byType(TextFormField).at(1), '500');
    await tester.ensureVisible(find.text('Save income'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save income'));
    await tester.pumpAndSettle();
    expect(find.text('\$480.01'), findsWidgets);
    await tester.ensureVisible(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('0 expenses recorded · USD'), findsOneWidget);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('1 expense recorded · USD'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save failure keeps form values available for retry', (
    tester,
  ) async {
    final repository = FakeExpenseRepository()..failSave = true;
    await mount(tester, repository);
    await tester.ensureVisible(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Coffee');
    await tester.enterText(find.byType(TextFormField).at(1), '3.50');
    await tester.ensureVisible(find.text('Save expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to save. Please try again.'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    repository.failSave = false;
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();
    expect(find.byType(ExpenseEntrySheet), findsNothing);
    expect(find.text('\$3.50'), findsWidgets);
  });

  testWidgets(
    'loaded dashboard and transaction list fit narrow screens and large text',
    (tester) async {
      final now = DateTime.now();
      final repository = FakeExpenseRepository();
      await repository.save(
        'user-1',
        ExpenseTracker(
          entries: [
            for (var i = 0; i < 6; i++)
              ExpenseEntry(
                id: '$i',
                title: 'Transaction $i',
                amountCents: 1000,
                category: ExpenseCategory.values[i],
                date: now,
              ),
          ],
          budgets: {ExpenseTracker.monthKey(now): 5000},
        ),
      );
      await mount(tester, repository, width: 320, textScale: 1.5);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('See all'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Transaction 5'),
        150,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Transaction 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
