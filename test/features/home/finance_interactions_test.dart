import 'package:authentication/core/theme/app_theme.dart';
import 'package:authentication/features/home/data/repositories/preferences_expense_repository.dart';
import 'package:authentication/features/home/data/services/csv_export_service.dart';
import 'package:authentication/features/home/domain/models/expense_tracker.dart';
import 'package:authentication/features/home/domain/models/transaction.dart';
import 'package:authentication/features/home/presentation/views/finance_settings_screen.dart';
import 'package:authentication/features/home/presentation/views/history_screen.dart';
import 'package:authentication/features/home/presentation/views/home_screen.dart';
import 'package:authentication/features/home/presentation/views/transaction_detail_screen.dart';
import 'package:authentication/features/home/presentation/widgets/expense_entry_sheet.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/expense_fakes.dart';
import '../../support/profile_fakes.dart';
import 'finance_logic_test.dart' show FakeCsvShare;

void main() {
  Transaction item(
    String id, {
    String? title,
    bool income = false,
    DateTime? date,
  }) => Transaction(
    id: id,
    title: title ?? id,
    amount: income ? 500 : 4.75,
    date: date ?? DateTime.now(),
    type: income ? TransactionType.income : TransactionType.expense,
    category: income ? 'Salary' : 'Food & Dining',
  );
  Future<void> mount(
    WidgetTester tester,
    FakeExpenseRepository repository,
    Widget screen, {
    Brightness brightness = Brightness.light,
    double width = 390,
    FakeCsvShare? sharing,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
          if (sharing != null)
            csvShareServiceProvider.overrideWithValue(sharing),
        ],
        child: MaterialApp(
          theme: AppTheme.forBrightness(brightness),
          home: Scaffold(body: SafeArea(child: screen)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'mock scan loads for two seconds and fills editable receipt fields',
    (tester) async {
      final repository = FakeExpenseRepository();
      await mount(tester, repository, const HomeScreen());
      await tester.ensureVisible(find.text('Add transaction'));
      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan Receipt (AI)'));
      await tester.pump();
      expect(find.text('Reading mock receipt…'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Starbucks'), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Mock receipt scanned'), findsOneWidget);
      expect(find.text('Starbucks'), findsOneWidget);
      expect(find.text('4.75'), findsOneWidget);
      await tester.ensureVisible(find.text('Save expense'));
      await tester.tap(find.text('Save expense'));
      await tester.pumpAndSettle();
      final stored = await repository.load('user-1');
      expect(stored.transactions.single.title, 'Starbucks');
      expect(stored.transactions.single.amount, 4.75);
    },
  );
  testWidgets(
    'ledger search and chips combine; swiping requires snackbar confirmation',
    (tester) async {
      final repository = FakeExpenseRepository();
      await repository.save(
        'user-1',
        ExpenseTracker(
          transactions: [
            item('1', title: 'Starbucks'),
            item('2', title: 'Salary', income: true),
          ],
        ),
      );
      await mount(tester, repository, const HistoryScreen());
      await tester.enterText(find.byType(TextField), 'strbcks');
      await tester.pumpAndSettle();
      expect(find.text('Starbucks'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expense only'));
      await tester.pumpAndSettle();
      expect(find.text('Salary'), findsNothing);
      await tester.drag(find.byKey(const ValueKey('1')), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Delete “Starbucks”?'), findsOneWidget);
      expect((await repository.load('user-1')).transactions, hasLength(2));
      await tester.pump(const Duration(seconds: 7));
      await tester.pumpAndSettle();
      expect(find.text('Starbucks'), findsOneWidget);
      await tester.drag(find.byKey(const ValueKey('1')), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect((await repository.load('user-1')).transactions, hasLength(1));
      expect(find.text('Starbucks'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'transaction detail uses Hero and edits the existing transaction',
    (tester) async {
      final repository = FakeExpenseRepository();
      await repository.save(
        'user-1',
        ExpenseTracker(transactions: [item('1', title: 'Coffee')]),
      );
      await mount(tester, repository, const HistoryScreen());
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionDetailScreen), findsOneWidget);
      expect(find.byType(Hero), findsWidgets);
      await tester.tap(find.text('Edit transaction'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('transaction-title')),
        'Coffee and snack',
      );
      await tester.enterText(
        find.byKey(const Key('transaction-notes')),
        'Shared with a friend',
      );
      await tester.ensureVisible(find.text('Save expense'));
      await tester.tap(find.text('Save expense'));
      await tester.pumpAndSettle();
      final stored = await repository.load('user-1');
      expect(stored.transactions, hasLength(1));
      expect(stored.transactions.single.id, '1');
      expect(stored.transactions.single.notes, 'Shared with a friend');
      expect(find.text('Coffee and snack'), findsOneWidget);
      expect(find.byType(ExpenseEntrySheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('CSV export and reset require the exact double confirmation', (
    tester,
  ) async {
    final repository = FakeExpenseRepository();
    final sharing = FakeCsvShare();
    await repository.save('user-1', ExpenseTracker(transactions: [item('1')]));
    await mount(
      tester,
      repository,
      const FinanceSettingsScreen(),
      sharing: sharing,
    );
    await tester.ensureVisible(find.text('Export Data to CSV'));
    await tester.tap(find.text('Export Data to CSV'));
    await tester.pumpAndSettle();
    expect(sharing.contents, contains('4.75'));
    await tester.ensureVisible(find.text('Reset All Data'));
    await tester.tap(find.text('Reset All Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect((await repository.load('user-1')).transactions, hasLength(1));
    await tester.tap(find.text('Reset All Data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final button = find.widgetWithText(FilledButton, 'Reset permanently');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'RESET');
    await tester.pump();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect((await repository.load('user-1')).transactions, isEmpty);
    expect(find.text('Transactions and budgets reset.'), findsOneWidget);
  });
  testWidgets(
    'dark dashboard, chart interaction and ledger fit a narrow screen',
    (tester) async {
      final repository = FakeExpenseRepository();
      await repository.save(
        'user-1',
        ExpenseTracker(transactions: [item('1', title: 'Coffee')]),
      );
      await mount(
        tester,
        repository,
        const HomeScreen(),
        brightness: Brightness.dark,
        width: 320,
      );
      expect(
        Theme.of(tester.element(find.byType(HomeScreen))).brightness,
        Brightness.dark,
      );
      await tester.ensureVisible(find.text('Food & Dining').last);
      await tester.tap(find.text('Food & Dining').last);
      await tester.pumpAndSettle();
      expect(find.text('Food & Dining · \$4.75 · 100.0%'), findsOneWidget);
      await tester.ensureVisible(find.text('See all').first);
      await tester.tap(find.text('See all').first);
      await tester.pumpAndSettle();
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
