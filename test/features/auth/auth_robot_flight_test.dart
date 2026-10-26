import 'package:authentication/features/auth/presentation/widgets/auth_robot_flight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const stageKey = ValueKey('card-bounds');
  const robotKey = ValueKey('robot');

  Widget host({
    bool reduceMotion = false,
    double height = 400,
    ValueNotifier<Offset?>? target,
    ValueNotifier<Rect?>? belowField,
    Alignment homeAlignment = Alignment.topCenter,
  }) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            key: stageKey,
            width: 300,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AuthRobotFlight(
                    target: target,
                    belowField: belowField,
                    homeAlignment: homeAlignment,
                    child: const SizedBox(
                      key: robotKey,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  for (final height in [300.0, 480.0]) {
    testWidgets(
      'robot rises from below a ${height.toInt()}px card to its top',
      (tester) async {
        await tester.pumpWidget(host(height: height));
        final stage = tester.getRect(find.byKey(stageKey));
        expect(
          tester.getTopLeft(find.byKey(robotKey)).dy,
          closeTo(stage.bottom, 0.1),
        );

        await tester.pump(const Duration(milliseconds: 1100));
        final halfway = tester.getTopLeft(find.byKey(robotKey)).dy;
        expect(halfway, greaterThan(stage.top));
        expect(halfway, lessThan(stage.bottom));

        await tester.pump(const Duration(milliseconds: 1100));
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.byKey(robotKey)).dy,
          closeTo(stage.top, 0.1),
        );
        expect(tester.binding.transientCallbackCount, 0);

        // A form rebuild must not restart the flight across the input fields.
        await tester.pumpWidget(host(height: height));
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          tester.getTopLeft(find.byKey(robotKey)).dy,
          closeTo(stage.top, 0.1),
        );
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }

  testWidgets('reduced motion immediately finishes an active flight', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(host(reduceMotion: true));
    await tester.pump();
    expect(
      tester.getTopLeft(find.byKey(robotKey)).dy,
      closeTo(tester.getTopLeft(find.byKey(stageKey)).dy, 0.1),
    );
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('follows a target smoothly and remains inside the card bounds', (
    tester,
  ) async {
    final target = ValueNotifier<Offset?>(null);
    addTearDown(target.dispose);
    await tester.pumpWidget(host(target: target));
    await tester.pumpAndSettle();
    final stage = tester.getRect(find.byKey(stageKey));
    final point = stage.topLeft + const Offset(260, 330);
    target.value = point;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final halfway = tester.getTopLeft(find.byKey(robotKey)).dy;
    expect(halfway, greaterThan(stage.top));
    await tester.pumpAndSettle();
    final robot = tester.getRect(find.byKey(robotKey));
    expect(robot.top, greaterThan(halfway));
    expect(robot.bottom, lessThan(point.dy));
    expect(robot.left, greaterThanOrEqualTo(stage.left));
    expect(robot.right, lessThanOrEqualTo(stage.right));

    target.value = stage.bottomRight + const Offset(500, 500);
    await tester.pumpAndSettle();
    final clamped = tester.getRect(find.byKey(robotKey));
    expect(clamped.bottom, lessThanOrEqualTo(stage.bottom + 0.1));
    expect(clamped.right, lessThanOrEqualTo(stage.right));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'bottom home stays beneath the form and can follow touches upward',
    (tester) async {
      final target = ValueNotifier<Offset?>(null);
      addTearDown(target.dispose);
      await tester.pumpWidget(
        host(
          reduceMotion: true,
          target: target,
          homeAlignment: Alignment.bottomCenter,
        ),
      );
      await tester.pumpAndSettle();
      final stage = tester.getRect(find.byKey(stageKey));
      expect(
        tester.getBottomRight(find.byKey(robotKey)).dy,
        closeTo(stage.bottom, 0.1),
      );
      target.value = stage.topLeft + const Offset(150, 180);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.byKey(robotKey)).dy,
        lessThan(stage.top + 180),
      );
      target.value = null;
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.byKey(robotKey)).dy,
        closeTo(stage.bottom, 0.1),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'field placement uses the bottom edge and follows layout changes',
    (tester) async {
      final target = ValueNotifier<Offset?>(null);
      final below = ValueNotifier<Rect?>(null);
      addTearDown(target.dispose);
      addTearDown(below.dispose);
      await tester.pumpWidget(
        host(reduceMotion: true, target: target, belowField: below),
      );
      final stage = tester.getRect(find.byKey(stageKey));
    final field = Rect.fromLTWH(stage.left + 20, stage.top + 150, 260, 60);
      target.value = field.center;
      below.value = field;
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(robotKey)).dy,
        closeTo(field.bottom + 12, 0.1),
      );

      below.value = field.shift(const Offset(0, 45));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(robotKey)).dy,
        closeTo(field.bottom + 57, 0.1),
      );
      below.value = null;
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.byKey(robotKey)).dy,
        lessThan(field.center.dy),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
