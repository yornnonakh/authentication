import 'package:flutter_test/flutter_test.dart';

/// Flow tests settle between actions; mascot loop tests use normal motion.
void useReducedMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
