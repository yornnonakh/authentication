import 'package:authentication/app/app.dart';
import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/auth/presentation/views/sign_in_screen.dart';
import 'package:authentication/features/home/presentation/views/dashboard_screen.dart';
import 'package:authentication/features/onboarding/data/providers/onboarding_providers.dart';
import 'package:authentication/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:authentication/features/onboarding/presentation/views/splash_screen.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_fakes.dart';

void main() {
  late FakeLogoutRepository auth;
  late FakeOnboardingRepository onboarding;
  setUp(() {
    auth = FakeLogoutRepository();
    onboarding = FakeOnboardingRepository()..completed = false;
  });
  tearDown(() => auth.events.close());

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          onboardingRepositoryProvider.overrideWithValue(onboarding),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'first launch shows splash then onboarding and supports swiping',
    (tester) async {
      await mount(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Your Money.\nMore Possibilities.'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-700, 0));
      await tester.pumpAndSettle();
      expect(find.text('Small Steps.\nBigger Goals.'), findsOneWidget);
      final semantics = tester.ensureSemantics();
      await tester.tap(find.bySemanticsLabel('Page 3 of 3'));
      await tester.pumpAndSettle();
      expect(find.text('Your Account.\nYour Peace of Mind.'), findsOneWidget);
      semantics.dispose();
      expect(onboarding.saveCalls, 0);
    },
  );

  testWidgets('get started remembers onboarding and opens sign in', (
    tester,
  ) async {
    await mount(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(onboarding.completed, isTrue);
    expect(onboarding.saveCalls, 1);
    expect(auth.signOutCalls, 0);
  });

  testWidgets('log in remembers onboarding and shows onboarding on next startup when unauthenticated', (
    tester,
  ) async {
    await mount(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(onboarding.completed, isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await mount(tester);
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('restored account bypasses onboarding even on first launch', (
    tester,
  ) async {
    auth.hasSavedSession = true;
    await mount(tester);
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(onboarding.readCalls, 0);
    expect(auth.signOutCalls, 0);
  });

  testWidgets('failed preference save stays on onboarding and offers retry', (
    tester,
  ) async {
    onboarding.saveFailure = Exception('Storage unavailable');
    await mount(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(
      find.text('Unable to save your preference. Please try again.'),
      findsOneWidget,
    );
    expect(onboarding.completed, isFalse);
    onboarding.saveFailure = null;
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(onboarding.completed, isTrue);
  });

  testWidgets('small screen with large text can scroll every onboarding page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [onboardingRepositoryProvider.overrideWithValue(onboarding)],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const OnboardingScreen(),
        ),
      ),
    );
    for (var page = 0; page < 3; page++) {
      expect(tester.takeException(), isNull);
      expect(find.text('Get Started'), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-320, 0));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
