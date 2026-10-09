import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/welcome_colors.dart';
import '../../../../core/widgets/finsight_brand.dart';
import '../../../auth/presentation/views/sign_in_screen.dart';
import '../../../auth/presentation/views/sign_up_screen.dart';
import '../../domain/models/onboarding_page.dart';
import '../view_models/onboarding_view_model.dart';
import '../widgets/onboarding_artwork.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool register}) async {
    final completed = await ref
        .read(onboardingViewModelProvider.notifier)
        .complete();
    if (!mounted || !completed) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => register ? const SignUpScreen() : const SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final busy = state.isCompleting || state.isCompleted;
    return Scaffold(
      backgroundColor: WelcomeColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3F6FF),
              WelcomeColors.background,
              Color(0xFFE9F3FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(28, 20, 28, 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FinsightBrand(),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      physics: busy
                          ? const NeverScrollableScrollPhysics()
                          : null,
                      itemCount: OnboardingPage.pages.length,
                      onPageChanged: ref
                          .read(onboardingViewModelProvider.notifier)
                          .selectPage,
                      itemBuilder: (_, index) =>
                          _WelcomePage(page: OnboardingPage.pages[index]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            OnboardingPage.pages.length,
                            (index) => Semantics(
                              label:
                                  'Page ${index + 1} of ${OnboardingPage.pages.length}',
                              selected: state.page == index,
                              button: true,
                              child: SizedBox(
                                width: 32,
                                height: 36,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: busy
                                      ? null
                                      : () => _pages.animateToPage(
                                          index,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeOutCubic,
                                        ),
                                  child: Center(
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: state.page == index ? 16 : 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: state.page == index
                                            ? WelcomeColors.blue
                                            : WelcomeColors.paleBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (state.error != null) ...[
                          Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFB44242),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: WelcomeColors.navy,
                              disabledBackgroundColor: WelcomeColors.navy
                                  .withValues(alpha: .6),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(58),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: busy
                                ? null
                                : () => _finish(register: true),
                            child: state.isCompleting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Get Started',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 21,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                fontSize: 12,
                                color: WelcomeColors.muted,
                              ),
                            ),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () => _finish(register: false),
                              style: TextButton.styleFrom(
                                foregroundColor: WelcomeColors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.page});
  final OnboardingPage page;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final fontSize = (width * .099).clamp(30.0, 44.0);
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                page.title,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1.16,
                  letterSpacing: -1.3,
                  fontWeight: FontWeight.w500,
                  color: WelcomeColors.ink,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                page.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: WelcomeColors.muted,
                ),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: math.max(
                  220,
                  math.min(350, constraints.maxHeight * .6),
                ),
                child: OnboardingArtwork(illustration: page.illustration),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}
