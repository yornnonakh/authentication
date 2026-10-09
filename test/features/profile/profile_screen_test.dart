import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/auth/domain/models/auth_event.dart';
import 'package:authentication/features/auth/presentation/views/sign_in_screen.dart';
import 'package:authentication/features/home/presentation/views/dashboard_screen.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_fakes.dart';

void main() {
  late FakeProfileRepository profile;
  late FakeLogoutRepository auth;
  setUp(() {
    profile = FakeProfileRepository();
    auth = FakeLogoutRepository();
  });
  tearDown(() => auth.events.close());

  Future<void> mount(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(profile),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'profile saves user input and updates home before logout clears routes',
    (tester) async {
      await mount(tester);
      expect(find.text('Sign Up Name'), findsOneWidget);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('My Profile'), findsOneWidget);
      final fields = find.byType(TextFormField);
      expect(
        tester.widget<TextFormField>(fields.at(1)).initialValue,
        'user@example.com',
      );
      await tester.enterText(fields.at(0), 'New Profile Name');
      await tester.enterText(fields.at(2), '+855 12345678');
      await tester.enterText(fields.at(3), 'Saved from my input');
      await tester.ensureVisible(find.text('Save profile'));
      await tester.tap(find.text('Save profile'));
      await tester.pumpAndSettle();
      expect(profile.profile.fullName, 'New Profile Name');
      await tester.tap(find.byTooltip('Home'));
      await tester.pumpAndSettle();
      expect(find.text('New Profile Name'), findsOneWidget);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Log out'));
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(find.byType(DashboardScreen), findsNothing);
      expect(auth.signOutCalls, 1);
      expect(
        Navigator.of(tester.element(find.byType(SignInScreen))).canPop(),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed save preserves typed input; failed logout keeps profile open',
    (tester) async {
      await mount(tester);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      profile.saveFailure = Exception('Network failed');
      await tester.enterText(find.byType(TextFormField).first, 'Unsaved Name');
      await tester.ensureVisible(find.text('Save profile'));
      await tester.tap(find.text('Save profile'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        'Unsaved Name',
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      auth.signOutFailure = const AuthFailure('Logout failed');
      await tester.ensureVisible(find.text('Log out'));
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsNothing);
      expect(find.text('Logout failed'), findsOneWidget);
      expect(find.byType(DashboardScreen), findsOneWidget);
    },
  );

  testWidgets('external signed-out event returns dashboard to sign-in', (
    tester,
  ) async {
    await mount(tester);
    auth.events.add(
      const AuthEvent(AuthEventType.signedOut, hasSession: false),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });
}
