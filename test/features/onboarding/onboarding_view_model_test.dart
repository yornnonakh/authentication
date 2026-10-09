import 'dart:async';
import 'package:authentication/features/onboarding/data/providers/onboarding_providers.dart';
import 'package:authentication/features/onboarding/presentation/view_models/onboarding_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_fakes.dart';

void main() {
  test('duplicate completion requests save the preference only once', () async {
    final repository = FakeOnboardingRepository()
      ..completed = false
      ..savePending = Completer<void>();
    final container = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(onboardingViewModelProvider, (_, next) {});
    final vm = container.read(onboardingViewModelProvider.notifier);
    final first = vm.complete();
    expect(await vm.complete(), isFalse);
    expect(repository.saveCalls, 1);
    repository.savePending!.complete();
    expect(await first, isTrue);
    expect(container.read(onboardingViewModelProvider).isCompleted, isTrue);
  });

  test(
    'leaving onboarding during a save does not update disposed state',
    () async {
      final repository = FakeOnboardingRepository()
        ..savePending = Completer<void>();
      final container = ProviderContainer(
        overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
      );
      container.listen(onboardingViewModelProvider, (_, next) {});
      final pending = container
          .read(onboardingViewModelProvider.notifier)
          .complete();
      container.dispose();
      repository.savePending!.complete();
      expect(await pending, isFalse);
    },
  );
}
