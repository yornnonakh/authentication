import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../domain/models/onboarding_page.dart';
import '../view_models/onboarding_view_model.dart';
import '../widgets/onboarding_artwork.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  int get _totalPages => OnboardingPage.pages.length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final completed = await ref
        .read(onboardingViewModelProvider.notifier)
        .complete();
    if (!mounted || !completed) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
  }

  void _continue(int currentPage) {
    if (currentPage == _totalPages - 1) {
      _finish();
    } else {
      _goToPage(currentPage + 1);
    }
  }

  void _goToPage(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(index);
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final colors = Theme.of(context).colorScheme;
    final busy = state.isCompleting || state.isCompleted;
    final isLastPage = state.page == _totalPages - 1;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: isLastPage
                          ? null
                          : TextButton(
                              onPressed: busy ? null : _finish,
                              style: TextButton.styleFrom(
                                foregroundColor: colors.onSurfaceVariant,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                              child: const Text('Skip'),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: busy
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    itemCount: _totalPages,
                    onPageChanged: ref
                        .read(onboardingViewModelProvider.notifier)
                        .selectPage,
                    itemBuilder: (context, index) => _WelcomePage(
                      key: ValueKey(index),
                      page: OnboardingPage.pages[index],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.error != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: colors.error),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _totalPages,
                          (index) => Semantics(
                            label: 'Page ${index + 1} of $_totalPages',
                            button: true,
                            selected: state.page == index,
                            child: InkResponse(
                              onTap: busy ? null : () => _goToPage(index),
                              radius: 20,
                              child: SizedBox(
                                width: 34,
                                height: 40,
                                child: Center(
                                  child: AnimatedContainer(
                                    duration: reduceMotion
                                        ? Duration.zero
                                        : const Duration(milliseconds: 250),
                                    curve: Curves.easeInOutCubic,
                                    width: state.page == index ? 24 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: state.page == index
                                          ? colors.primary
                                          : colors.outlineVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: busy ? null : () => _continue(state.page),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            disabledBackgroundColor: colors.primary.withValues(
                              alpha: 0.45,
                            ),
                            disabledForegroundColor: colors.onPrimary,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            minimumSize: Size(isLastPage ? 152 : 112, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                            textStyle: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          child: state.isCompleting
                              ? SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    color: colors.onPrimary,
                                    strokeWidth: 2,
                                    semanticsLabel: 'Finishing setup',
                                  ),
                                )
                              : Text(
                                  isLastPage ? 'Get Started' : 'Next',
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({super.key, required this.page});

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationSize = math.min(
          math.min(320.0, constraints.maxWidth - 48),
          math.max(200.0, constraints.maxHeight * 0.62),
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
              child: AppEntrance(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: illustrationSize,
                      child: OnboardingArtwork(illustration: page.illustration),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.65,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
