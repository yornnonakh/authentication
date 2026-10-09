import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/onboarding_providers.dart';
import '../../domain/models/onboarding_page.dart';
import 'onboarding_state.dart';

final onboardingViewModelProvider =
    NotifierProvider.autoDispose<OnboardingViewModel, OnboardingState>(
      OnboardingViewModel.new,
    );

class OnboardingViewModel extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void selectPage(int page) {
    if (page < 0 ||
        page >= OnboardingPage.pages.length ||
        state.isCompleting ||
        state.isCompleted) {
      return;
    }
    state = OnboardingState(page: page);
  }

  Future<bool> complete() async {
    if (state.isCompleting || state.isCompleted) return false;
    final repository = ref.read(onboardingRepositoryProvider);
    state = OnboardingState(page: state.page, isCompleting: true);
    try {
      await repository.complete();
      if (!ref.mounted) return false;
      state = OnboardingState(page: state.page, isCompleted: true);
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = OnboardingState(
          page: state.page,
          error: 'Unable to save your preference. Please try again.',
        );
      }
      return false;
    }
  }
}
