import 'package:authentication/core/widgets/ai_dot_indicator.dart';
import 'package:authentication/core/widgets/app_motion.dart';
import 'package:authentication/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child, {bool reduceMotion = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('decorative dots settle and loading dots stop when removed', (
    tester,
  ) async {
    await tester.pumpWidget(host(const AiDotIndicator()));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);

    await tester.pumpWidget(host(const AiDotIndicator(loop: true)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpWidget(host(const SizedBox()));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion stops dots and shows page content immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const AppEntrance(child: AiDotIndicator(loop: true))),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpWidget(
      host(
        const AppEntrance(child: AiDotIndicator(loop: true)),
        reduceMotion: true,
      ),
    );
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    expect(
      tester
          .widget<FadeTransition>(find.byType(FadeTransition).last)
          .opacity
          .value,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled presses restore the button without firing a tap', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      host(PrimaryButton(label: 'Continue', onPressed: () => taps++)),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(ElevatedButton)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.96,
    );
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    expect(taps, 0);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('page entrances retain child state when reactivated', (
    tester,
  ) async {
    const child = TextField();
    await tester.pumpWidget(host(AppEntrance(child: child)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Saved note');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.pumpWidget(host(AppEntrance(active: false, child: child)));
    await tester.pumpWidget(host(AppEntrance(child: child)));
    await tester.pumpAndSettle();
    expect(find.text('Saved note').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading button announces progress and prevents duplicate taps', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    Widget button(bool loading) => host(
      PrimaryButton(
        label: 'Sign in',
        isLoading: loading,
        onPressed: () => taps++,
      ),
    );
    await tester.pumpWidget(button(true));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.bySemanticsLabel('Sign in, in progress'), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    expect(taps, 0);
    await tester.pumpWidget(button(false));
    await tester.pumpAndSettle();
    expect(find.byType(AiDotIndicator), findsNothing);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.binding.transientCallbackCount, 0);
    semantics.dispose();
  });
}
