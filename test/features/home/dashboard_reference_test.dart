import 'package:authentication/core/theme/app_theme.dart';
import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/home/data/repositories/preferences_expense_repository.dart';
import 'package:authentication/features/home/domain/models/expense_tracker.dart';
import 'package:authentication/features/home/domain/models/transaction.dart';
import 'package:authentication/features/home/presentation/views/dashboard_screen.dart';
import 'package:authentication/features/home/presentation/views/history_screen.dart';
import 'package:authentication/features/home/presentation/widgets/expense_entry_sheet.dart';
import 'package:authentication/features/home/presentation/widgets/spending_chart.dart';
import 'package:authentication/features/home/presentation/widgets/rounded_spending_ring.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../support/expense_fakes.dart';
import '../../support/profile_fakes.dart';

void main() {
  late FakeExpenseRepository repository;
  late FakeLogoutRepository auth;
  final now = DateTime.now();
  setUp(() async {
    repository = FakeExpenseRepository();
    auth = FakeLogoutRepository();
    await repository.save(
      'user-1',
      ExpenseTracker(
        transactions: [
          Transaction(
            id: 'income',
            title: 'Monthly salary',
            amount: 5000,
            date: now,
            type: TransactionType.income,
            category: 'Salary',
          ),
          Transaction(
            id: 'food',
            title: 'Groceries',
            amount: 250,
            date: now,
            type: TransactionType.expense,
            category: 'Food & Dining',
          ),
          Transaction(
            id: 'shopping',
            title: 'New shoes',
            amount: 150,
            date: now,
            type: TransactionType.expense,
            category: 'Shopping',
          ),
          Transaction(
            id: 'previous-food',
            title: 'Last month groceries',
            amount: 200,
            date: DateTime(now.year, now.month - 1, 1),
            type: TransactionType.expense,
            category: 'Food & Dining',
          ),
        ],
        budgets: {ExpenseTracker.monthKey(now): 100000},
      ),
    );
  });
  tearDown(() => auth.events.close());

  Future<void> mount(
    WidgetTester tester, {
    double width = 390,
    double scale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repository),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          theme: AppTheme.forBrightness(brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('report switches transaction type and opens a filtered ledger', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('\$400.00'), findsWidgets);
    expect(find.text('+25% vs last month'), findsOneWidget);
    final ringFinder = find.byType(RoundedSpendingRing);
    final ring = tester.widget<RoundedSpendingRing>(ringFinder);
    await tester.tapAt(
      tester.getCenter(ringFinder) + Offset(ring.diameter * 0.35, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Food & Dining · \$250.00 · 62.5%'), findsOneWidget);
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.text('Total Income'), findsOneWidget);
    final chart = tester.widget<SpendingChart>(find.byType(SpendingChart));
    expect(chart.categories, {'Salary': 500000});
    await tester.ensureVisible(find.text('Salary'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('Monthly salary'), findsOneWidget);
    expect(find.text('New shoes'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'report selector drags and stays available while swiping scrolled reports',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      final expenses = tester.getCenter(find.text('Expenses'));
      final income = tester.getCenter(find.text('Income'));
      await tester.dragFrom(expenses, income - expenses);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SpendingChart>(find.byType(SpendingChart)).categories,
        {'Salary': 500000},
      );

      await tester.ensureVisible(find.text('Salary'));
      await tester.pumpAndSettle();
      expect(find.text('Expenses').hitTestable(), findsOneWidget);
      expect(find.text('Income').hitTestable(), findsOneWidget);
      await tester.drag(find.text('Salary'), const Offset(180, 0));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SpendingChart>(find.byType(SpendingChart)).categories,
        {'Food & Dining': 25000, 'Shopping': 15000},
      );

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SpendingChart>(find.byType(SpendingChart)).categories,
        {'Salary': 500000},
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'plan edits the saved budget and center add saves a transaction',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();
      expect(find.text('40% of budget used'), findsOneWidget);
      expect(find.text('\$600.00 Left'), findsOneWidget);
      await tester.tap(find.text('Edit budget'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '2000');
      await tester.tap(find.text('Save budget'));
      await tester.pumpAndSettle();
      expect(find.text('20% of budget used'), findsOneWidget);
      expect((await repository.load('user-1')).budgetFor(now), 200000);
      await tester.tap(find.byTooltip('Add transaction'));
      await tester.pumpAndSettle();
      expect(find.byType(ExpenseEntrySheet), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('transaction-title')),
        'Coffee',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '5');
      await tester.ensureVisible(find.text('Save expense'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save expense'));
      await tester.pumpAndSettle();
      expect(find.text('\$1,595.00 Left'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'all tabs fit 320px and large text in ${brightness.name} mode',
      (tester) async {
        await mount(tester, width: 320, scale: 1.5, brightness: brightness);
        expect(tester.takeException(), isNull);
        for (final tab in ['Report', 'Plan', 'Settings', 'Home']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$tab should fit');
        }
      },
    );
  }
}
