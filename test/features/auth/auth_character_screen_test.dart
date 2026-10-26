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
      expect(robotRect.bottom, lessThan(cardRect.top));
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
        final email = find.byType(TextFormField).at(signUp ? 1 : 0);
        await tester.enterText(email, 'user@example.com');
        await tester.pumpAndSettle();
        expect(
          tester.getBottomRight(robot).dy,
          lessThan(tester.getTopLeft(find.byType(CustomScrollView)).dy),
        );

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
          tester.getBottomRight(robot).dy,
          lessThan(tester.getTopLeft(find.byType(CustomScrollView)).dy),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '$name robot stays pinned and keeps inputs clear while scrolling and typing',
      (tester) async {
        await mount(tester, signUp: signUp, width: 320, textScale: 1.5);
        final email = find.byType(TextFormField).at(signUp ? 1 : 0);
        final emailInput = find.descendant(
          of: email,
          matching: find.byType(TextField),
        );
        final password = find.byType(TextFormField).last;
        final robot = find.byType(AuthCharacter);
        final scrollView = find.byType(CustomScrollView);
        final robotTop = tester.getTopLeft(robot).dy;
        final heading = find.text(
          signUp ? 'Create your account' : 'Welcome back',
        );
        final headingTop = tester.getTopLeft(heading).dy;

        await tester.drag(scrollView, const Offset(0, -180));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(robot).dy, closeTo(robotTop, 0.1));
        expect(tester.getTopLeft(heading).dy, lessThan(headingTop));

        Future<void> expectInputsClear() async {
          await tester.pumpAndSettle();
          final field = tester.getRect(emailInput);
          final companion = tester.getRect(robot);
          final viewport = tester.getRect(scrollView);
          for (final element in find.byType(TextFormField).evaluate()) {
            final input = tester.getRect(find.byWidget(element.widget));
            if (input.overlaps(viewport)) {
              expect(
                companion.overlaps(input.intersect(viewport)),
                isFalse,
                reason: 'The robot must not obscure an input or its text.',
              );
            }
          }
          expect(companion.bottom, lessThan(viewport.top));
          expect(tester.getTopLeft(password).dy - field.bottom, lessThan(100));
        }

        await tester.ensureVisible(email);
        await tester.tap(email);
        await expectInputsClear();
        // Tapping the same focused field and typing must preserve the placement.
        await tester.tap(email);
        await expectInputsClear();
        await tester.enterText(email, 'user@example.com');
        await expectInputsClear();
        await tester.enterText(
          email,
          'a.long.email.address.for.testing@example.com',
        );
        await expectInputsClear();

        tester.view.viewInsets = FakeViewPadding(
          bottom: 300 * tester.view.devicePixelRatio,
        );
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.ensureVisible(email);
        await expectInputsClear();
        expect(emailInput.hitTestable(), findsOneWidget);

        await tester.ensureVisible(password);
        await tester.tap(password);
        await expectInputsClear();
        expect(tester.widget<AuthCharacter>(robot).passwordFocused, isTrue);
        expect(
          tester.getTopLeft(password).dy - tester.getBottomRight(emailInput).dy,
          lessThan(100),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('sign in robot returns home after keyboard dismissal', (
    tester,
  ) async {
    await mount(tester, signUp: false);
    final robot = find.byType(AuthCharacter);
    final viewport = find.byType(CustomScrollView);
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(
      tester.getBottomRight(robot).dy,
      lessThan(tester.getTopLeft(viewport).dy),
    );
    expect(tester.takeException(), isNull);
  });

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
