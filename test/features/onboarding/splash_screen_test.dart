import 'package:authentication/core/theme/app_theme.dart';
import 'package:authentication/features/onboarding/presentation/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    bool reduceMotion = false,
    Brightness brightness = Brightness.light,
    double textScale = 1,
    String? error,
    VoidCallback? onRetry,
    VoidCallback? onSignIn,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.forBrightness(brightness),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reduceMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: SplashScreen(
        errorMessage: error,
        onRetry: onRetry,
        onSignIn: onSignIn,
      ),
    ),
  );

  testWidgets('reduced motion shows a static, accessible loading state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await mount(tester, reduceMotion: true);
      await tester.pumpAndSettle();

      expect(find.text('Expense Tracker'), findsOneWidget);
      expect(find.bySemanticsLabel('Getting things ready'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('motion stops on failure and resumes after retry', (
    tester,
  ) async {
    await mount(tester);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await mount(tester, error: 'Connection failed');
    await tester.pumpAndSettle();
    expect(find.text('Connection failed'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);

    await mount(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovery stays usable on a small dark screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var retries = 0;
    var signIns = 0;

    await mount(
      tester,
      reduceMotion: true,
      brightness: Brightness.dark,
      textScale: 2,
      error: 'Unable to open your account. Please try again.',
      onRetry: () => retries++,
      onSignIn: () => signIns++,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Try again'));
    await tester.tap(find.text('Try again'));
    await tester.ensureVisible(find.text('Go to sign in'));
    await tester.tap(find.text('Go to sign in'));

    expect(retries, 1);
    expect(signIns, 1);
    expect(tester.takeException(), isNull);
  });
}
