enum OnboardingIllustration { card, growth, security }

class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.illustration,
  });
  final String title;
  final String description;
  final OnboardingIllustration illustration;

  static const pages = [
    OnboardingPage(
      title: 'Your Money.\nMore Possibilities.',
      description:
          'Your finances made simple, secure\nand built for your tomorrow.',
      illustration: OnboardingIllustration.card,
    ),
    OnboardingPage(
      title: 'Small Steps.\nBigger Goals.',
      description:
          'See your spending, follow your portfolio,\nand plan your next move.',
      illustration: OnboardingIllustration.growth,
    ),
    OnboardingPage(
      title: 'Your Account.\nYour Peace of Mind.',
      description:
          'A personal space for your profile\nand a clear view of your money.',
      illustration: OnboardingIllustration.security,
    ),
  ];
}
