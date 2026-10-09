import 'package:authentication/app/app.dart';
import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/auth/domain/models/auth_event.dart';
import 'package:authentication/features/auth/presentation/views/sign_in_screen.dart';
import 'package:authentication/features/home/presentation/views/dashboard_screen.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:authentication/features/onboarding/data/providers/onboarding_providers.dart';
import 'package:authentication/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_fakes.dart';

void main() {
  late FakeLogoutRepository auth;
  late FakeProfileRepository profile;
  setUp(() {
    auth = FakeLogoutRepository();
    profile = FakeProfileRepository();
  });
  tearDown(() => auth.events.close());

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          profileRepositoryProvider.overrideWithValue(profile),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> completeOnboarding(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get Started'));
  }

  testWidgets('reopening with a saved session shows the account and profile', (
    tester,
  ) async {
    auth.hasSavedSession = true;
    await mount(tester);
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
    expect(find.text('Sign Up Name'), findsOneWidget);
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('user@example.com'), findsWidgets);
    expect(auth.restoreCalls, 1);
  });

  testWidgets('without a saved session startup shows onboarding and transitions to sign-in', (tester) async {
    await mount(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
    await completeOnboarding(tester);
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('hot reload after sign-in keeps the account and selected tab', (
    tester,
  ) async {
    await mount(tester);
    await completeOnboarding(tester);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'fixture-password',
    );
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    final reload = tester.binding.reassembleApplication();
    await tester.pump();
    await reload;
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
    expect(find.text('user@example.com'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'Sign Up Name'), findsOneWidget);
    expect(auth.hasSavedSession, isTrue);
    expect(auth.signOutCalls, 0);
    expect(auth.restoreCalls, 1);
  });

  testWidgets('hot reload after restoring a session keeps its profile', (
    tester,
  ) async {
    auth.hasSavedSession = true;
    await mount(tester);
    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();

    final reload = tester.binding.reassembleApplication();
    await tester.pump();
    await reload;
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
    expect(find.text('user@example.com'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'Sign Up Name'), findsOneWidget);
    expect(auth.signOutCalls, 0);
    expect(auth.restoreCalls, 1);
  });

  testWidgets(
    'password recovery does not send the sign-in screen to dashboard',
    (tester) async {
      await mount(tester);
      await completeOnboarding(tester);
      await tester.pumpAndSettle();
      auth.events.add(
        const AuthEvent(AuthEventType.passwordRecovery, hasSession: true),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
    },
  );

  testWidgets(
    'session restoration failure offers retry without deleting the account',
    (tester) async {
      auth.hasSavedSession = true;
      auth.restoreFailure = const AuthFailure('Connection failed');
      await mount(tester);
      expect(find.text('Connection failed'), findsOneWidget);
      expect(auth.signOutCalls, 0);
      auth.restoreFailure = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(auth.restoreCalls, 2);
    },
  );
}
