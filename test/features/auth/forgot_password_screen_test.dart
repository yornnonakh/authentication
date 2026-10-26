import 'package:authentication/app/app_routes.dart';
import 'package:authentication/core/theme/app_theme.dart';
import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:authentication/features/auth/presentation/views/sign_in_screen.dart';
import 'package:authentication/features/auth/presentation/widgets/auth_character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_fakes.dart';

class _RecoveryRepository extends FakeLogoutRepository {
  String? email;
  String? token;
  String? password;

  @override
  Future<void> sendPasswordResetEmail(String email) async => this.email = email;

  @override
  Future<bool> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    this.token = token;
    hasSavedSession = true;
    return true;
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    password = newPassword;
  }
}

void main() {
  late _RecoveryRepository auth;

  setUp(() => auth = _RecoveryRepository());
  tearDown(() => auth.events.close());

  Future<void> mount(WidgetTester tester, {bool fromSignIn = false}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
        child: MaterialApp(
          theme: AppTheme.forBrightness(Brightness.light),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          routes: {
            AppRoutes.signIn: (_) => const SignInScreen(),
            AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          },
          home: fromSignIn
              ? const SignInScreen()
              : const ForgotPasswordScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('back opens sign in when recovery has no previous route', (
    tester,
  ) async {
    await mount(tester);
    await tap(tester, 'Back to Sign In');
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovery dismisses login focus and returns to the saved form', (
    tester,
  ) async {
    await mount(tester, fromSignIn: true);
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tap(tester, 'Forgot Password?');
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    await tap(tester, 'Back to Sign In');
    expect(find.byType(SignInScreen), findsOneWidget);
    final email = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(email.controller!.text, 'user@example.com');
    final emailInput = tester.widget<TextField>(
      find.descendant(
        of: find.byType(TextFormField).first,
        matching: find.byType(TextField),
      ),
    );
    expect(emailInput.focusNode!.hasFocus, isFalse);
    expect(
      tester.getBottomRight(find.byType(AuthCharacter)).dy,
      lessThan(tester.getTopLeft(find.byType(CustomScrollView)).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('system back returns from code entry to email entry', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextFormField), 'user@example.com');
    await tap(tester, 'Send Verification Code');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Send Verification Code'), findsOneWidget);
    expect(find.text('Check Your Email'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recovery verifies a code, resets the password and signs out', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextFormField), ' USER@example.com ');
    await tap(tester, 'Send Verification Code');
    expect(auth.email, 'user@example.com');
    expect(find.text('Check Your Email'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tap(tester, 'Verify Code');
    expect(auth.token, '123456');
    expect(find.text('Create New Password'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'new-password-123',
    );
    await tester.enterText(find.byType(TextFormField).last, 'new-password-123');
    await tap(tester, 'Reset Password');
    expect(auth.password, 'new-password-123');
    expect(auth.signOutCalls, 1);
    expect(auth.hasSavedSession, isFalse);
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
