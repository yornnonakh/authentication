class OnboardingState {
  const OnboardingState({
    this.page = 0,
    this.isCompleting = false,
    this.isCompleted = false,
    this.error,
  });
  final int page;
  final bool isCompleting;
  final bool isCompleted;
  final String? error;
}
