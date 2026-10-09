import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/liquid_glass_container.dart';
import '../../domain/models/onboarding_page.dart';
import '../view_models/onboarding_view_model.dart';
import '../widgets/onboarding_artwork.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends ConsumerState<OnboardingScreen> {
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

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.signIn,
    );
  }

  Future<void> _continue(int currentPage) async {
    if (currentPage == _totalPages - 1) {
      await _finish();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);

    final busy = state.isCompleting || state.isCompleted;
    final isLastPage = state.page == _totalPages - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: Column(
              children: [
                // HEADER (Back / Skip)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    8,
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      state.page > 0
                          ? TextButton(
                              onPressed: busy
                                  ? null
                                  : () => _goToPage(state.page - 1),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                const Color(0xFF64748B),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text('Back'),
                                ],
                              ),
                            )
                          : const SizedBox(width: 48),

                      if (!isLastPage)
                        TextButton(
                          onPressed: busy ? null : _finish,
                          style: TextButton.styleFrom(
                            foregroundColor:
                            const Color(0xFF64748B),
                          ),
                          child: const Text('Skip'),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                // ONBOARDING PAGES
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
                    itemBuilder: (context, index) {
                      return _WelcomePage(
                        page: OnboardingPage.pages[index],
                        key: ValueKey(index),
                      );
                    },
                  ),
                ),

                // BOTTOM ACTIONS
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    12,
                    24,
                    28,
                  ),
                  child: Column(
                    children: [
                      // ERROR
                      if (state.error != null) ...[
                        Text(
                          state.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // BOTTOM ROW: Indicators on left, Button wrapped in LiquidGlassContainer on right
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          // Page indicator dots
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              _totalPages,
                              (index) => Semantics(
                                label:
                                'Page ${index + 1} of $_totalPages',
                                button: true,
                                selected: state.page == index,
                                child: InkWell(
                                  onTap: busy
                                      ? null
                                      : () => _goToPage(index),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeInOut,
                                      width: state.page == index
                                          ? 20
                                          : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: state.page == index
                                            ? AppColors.primaryOrange
                                            : const Color(0xFFE2E8F0),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ONLY THE PRIMARY BUTTON WRAPPED IN LIQUID GLASS CONTAINER
                          Flexible(
                            child: LiquidGlassContainer(
                              borderRadius: 24,
                              padding: EdgeInsets.zero,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: busy
                                      ? null
                                      : () => _continue(state.page),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryOrange,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors
                                        .primaryOrange
                                        .withValues(alpha: 0.5),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: state.isCompleting
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isLastPage ? 'Get Started' : 'Next',
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
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
    );
  }
}

// ------------------------------------------------------
// REFERENCE IMAGE STYLE ONBOARDING PAGE WITH ANIMATED ILLUSTRATION
// ------------------------------------------------------

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    super.key,
    required this.page,
  });

  final OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final circleSize = math.min(
          280.0,
          math.max(200.0, constraints.maxHeight * 0.45),
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // CIRCULAR BACKGROUND CONTAINER WITH ENTRANCE SCALE & FADE ANIMATION
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFFAED), // Soft warm orange/cream tint following app color
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange
                            .withValues(alpha: 0.08),
                        blurRadius: 36,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: circleSize * 0.8,
                      height: circleSize * 0.8,
                      child: OnboardingArtwork(
                        illustration: page.illustration,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // TITLE
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.8,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // DESCRIPTION
              Text(
                page.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
