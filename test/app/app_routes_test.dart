import 'package:authentication/app/app.dart';
import 'package:authentication/app/app_routes.dart';
import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:authentication/features/auth/presentation/views/sign_in_screen.dart';
import 'package:authentication/features/auth/presentation/views/sign_up_screen.dart';
import 'package:authentication/features/auth/presentation/views/startup_screen.dart';
import 'package:authentication/features/home/presentation/views/dashboard_screen.dart';
import 'package:authentication/features/onboarding/data/providers/onboarding_providers.dart';
import 'package:authentication/features/onboarding/presentation/views/onboarding_screen.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/profile_fakes.dart';

void main() {
  late FakeLogoutRepository auth;
  late FakeOnboardingRepository onboarding;

  setUp(() {
    auth = FakeLogoutRepository();
    onboarding = FakeOnboardingRepository()..completed = false;
  });

  tearDown(() => auth.events.close());

  Future<void> mountApp(WidgetTester tester) async {
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
  }

  testWidgets(
    'app navigation flow: splash -> onboarding -> sign in -> main app',
    (tester) async {
      await mountApp(tester);

      // 1. Open app -> Splash screen
      await tester.pump();
      expect(find.byType(OnboardingScreen), findsNothing);

      // 2. Splash screen transitions to Onboarding screen
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // 3. Complete onboarding -> Sign In screen
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);

      // 4. Sign in -> Open App (Dashboard screen)
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
    },
  );

  testWidgets('AppRoutes onGenerateRoute resolves all named routes correctly', (
    tester,
  ) async {
    final routeMap = {
      AppRoutes.splash: StartupScreen,
      AppRoutes.onboarding: OnboardingScreen,
      AppRoutes.signIn: SignInScreen,
      AppRoutes.signUp: SignUpScreen,
      AppRoutes.forgotPassword: ForgotPasswordScreen,
      AppRoutes.dashboard: DashboardScreen,
    };

    for (final entry in routeMap.entries) {
      final route = AppRoutes.onGenerateRoute(
        RouteSettings(name: entry.key),
      );
      expect(route, isNotNull);
    }

    final verifyRoute = AppRoutes.onGenerateRoute(
      const RouteSettings(
        name: AppRoutes.verifyCode,
        arguments: 'test@example.com',
      ),
    );
    expect(verifyRoute, isNotNull);
  });
}
