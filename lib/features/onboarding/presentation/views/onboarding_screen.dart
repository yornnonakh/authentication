import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/finsight_brand.dart';
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

  Future<void> _finish() async {
    final completed = await ref
        .read(onboardingViewModelProvider.notifier)
        .complete();
    if (!mounted || !completed) return;
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.signIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final busy = state.isCompleting || state.isCompleted;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 20, 28, 16),
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
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
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
                                    width: state.page == index ? 20 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: state.page == index
                                          ? AppColors.primaryOrange
                                          : AppColors.border,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: busy ? null : _finish,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: busy ? null : _finish,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryOrange,
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
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              page.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textSecondary,
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
      );
    },
  );
}
