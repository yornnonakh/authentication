import 'package:authentication/core/theme/app_theme.dart';
import 'package:authentication/core/widgets/liquid_glass_container.dart';
import 'package:authentication/core/widgets/finsight_brand.dart';
import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/auth/presentation/views/sign_in_screen.dart';
import 'package:authentication/features/auth/presentation/views/sign_up_screen.dart';
import 'package:authentication/features/auth/presentation/widgets/auth_character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_fakes.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    required bool signUp,
    bool reduceMotion = true,
    Brightness brightness = Brightness.light,
    double width = 390,
    double textScale = 1,
  }) async {
    final auth = FakeLogoutRepository();
    addTearDown(auth.events.close);
    await tester.binding.setSurfaceSize(Size(width, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(auth)],
        child: MaterialApp(
          theme: AppTheme.forBrightness(brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduceMotion,
              textScaler: TextScaler.linear(textScale),
            ),
            child: child!,
          ),
          home: signUp ? const SignUpScreen() : const SignInScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final signUp in [false, true]) {
    final name = signUp ? 'sign up' : 'sign in';
    testWidgets('$name character follows focus and password visibility', (
      tester,
    ) async {
      await mount(tester, signUp: signUp);
      AuthCharacter character() =>
          tester.widget<AuthCharacter>(find.byType(AuthCharacter));
      expect(
        character().style,
        signUp ? AuthCharacterStyle.visor : AuthCharacterStyle.rounded,
      );
      final robotRect = tester.getRect(find.byType(AuthCharacter));
      final cardRect = tester.getRect(find.byType(LiquidGlassContainer));
      expect(robotRect.top, greaterThan(cardRect.bottom));
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(FinsightBrand), findsNothing);
      expect(find.byTooltip('Back'), findsNothing);
      final fields = find.byType(TextFormField);
      final email = fields.at(signUp ? 1 : 0);
      final password = fields.at(signUp ? 2 : 1);
      final passwordInput = find.descendant(
        of: password,
        matching: find.byType(TextField),
      );
      await tester.enterText(email, 'user@example.com');
      await tester.pumpAndSettle();
      expect(character().isTyping, isTrue);
      expect(character().lookProgress, greaterThan(0));
      expect(character().passwordFocused, isFalse);

      await tester.ensureVisible(password);
      await tester.enterText(password, 'fixture-password');
      await tester.pumpAndSettle();
      expect(character().passwordFocused, isTrue);
      expect(character().passwordVisible, isFalse);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();
      expect(character().passwordVisible, isTrue);
      expect(tester.widget<TextField>(passwordInput).obscureText, isFalse);
      expect(
        tester.widget<TextFormField>(password).controller!.text,
        'fixture-password',
      );
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();
      expect(character().passwordVisible, isFalse);
      expect(tester.widget<TextField>(passwordInput).obscureText, isTrue);
      expect(tester.takeException(), isNull);
    });

    for (final brightness in Brightness.values) {
      testWidgets(
        '$name fits narrow screens with reduced motion in $brightness',
        (tester) async {
          await mount(
            tester,
            signUp: signUp,
            width: 320,
            textScale: 1.5,
            reduceMotion: true,
            brightness: brightness,
          );
          expect(find.byType(AuthCharacter), findsOneWidget);
          expect(tester.binding.transientCallbackCount, 0);
          await tester.ensureVisible(find.text(signUp ? 'Sign Up' : 'Sign In'));
          await tester.pumpAndSettle();
          expect(
            find.text(signUp ? 'Sign Up' : 'Sign In').hitTestable(),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      '$name robot follows field selection, caret, and screen touches',
      (tester) async {
        await mount(tester, signUp: signUp);
        final robot = find.byType(AuthCharacter);
        final initialTop = tester.getTopLeft(robot).dy;
        final email = find.byType(TextFormField).at(signUp ? 1 : 0);
        await tester.enterText(email, 'user@example.com');
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(robot).dy, lessThan(initialTop));

        final controller = tester.widget<TextFormField>(email).controller!;
        controller.selection = const TextSelection.collapsed(offset: 0);
        await tester.pumpAndSettle();
        final startX = tester.getCenter(robot).dx;
        controller.selection = TextSelection.collapsed(
          offset: controller.text.length,
        );
        await tester.pumpAndSettle();
        expect(tester.getCenter(robot).dx, greaterThan(startX));

        await tester.tap(
          find.text(signUp ? 'Create your account' : 'Welcome back'),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(robot).dy,
          closeTo(tester.getTopLeft(find.byType(LiquidGlassContainer)).dy, 0.1),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$name email tap places the robot below the input with clear space',
      (tester) async {
        await mount(tester, signUp: signUp, width: 320, textScale: 1.5);
        final email = find.byType(TextFormField).at(signUp ? 1 : 0);
        final emailInput = find.descendant(
          of: email,
          matching: find.byType(TextField),
        );
        final password = find.byType(TextFormField).last;
        final robot = find.byType(AuthCharacter);

        Future<void> expectBelow() async {
          await tester.pumpAndSettle();
          final field = tester.getRect(emailInput);
          final companion = tester.getRect(robot);
          expect(companion.top, greaterThan(field.bottom));
          expect(companion.bottom, lessThan(tester.getTopLeft(password).dy));
        }

        await tester.ensureVisible(email);
        await tester.tap(email);
        await expectBelow();
        // Tapping the same focused field and typing must preserve the placement.
        await tester.tap(email);
        await expectBelow();
        await tester.enterText(email, 'user@example.com');
        await expectBelow();

        await tester.ensureVisible(password);
        await tester.tap(password);
        await tester.pumpAndSettle();
        expect(tester.widget<AuthCharacter>(robot).passwordFocused, isTrue);
        expect(
          tester.getTopLeft(password).dy - tester.getBottomRight(emailInput).dy,
          lessThan(100),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final style in AuthCharacterStyle.values) {
    testWidgets('$style loops, pauses offscreen, and respects reduced motion', (
      tester,
    ) async {
      Widget host({
        bool reduceMotion = false,
        bool active = true,
        bool show = true,
      }) => MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: TickerMode(
              enabled: active,
              child: show ? AuthCharacter(style: style) : const SizedBox(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(host());
      await tester.pump(const Duration(seconds: 20));
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester.pumpWidget(host(active: false));
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);

      await tester.pumpWidget(host());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester.pumpWidget(host(reduceMotion: true));
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);

      await tester.pumpWidget(host());
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pumpWidget(host(show: false));
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    });
  }
}
