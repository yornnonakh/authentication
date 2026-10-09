import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/view_models/startup_view_model.dart';
import '../../../home/presentation/views/dashboard_screen.dart';
import '../../../onboarding/presentation/views/onboarding_screen.dart';
import '../../../onboarding/presentation/views/splash_screen.dart';
import '../view_models/session_restore_view_model.dart';
import '../../domain/models/auth_event.dart';
import 'sign_in_screen.dart';

// Startup selects the initial screen. Later sign-in and recovery actions
// continue to control their own navigation.
class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restored = ref.watch(startupViewModelProvider);
    return restored.when(
      skipLoadingOnRefresh: false,
      data: (destination) => switch (destination) {
        StartupDestination.dashboard => const DashboardScreen(),
        StartupDestination.onboarding => const OnboardingScreen(),
        StartupDestination.signIn => const SignInScreen(),
      },
      loading: () => const SplashScreen(),
      error: (error, stackTrace) => SplashScreen(
        errorMessage: error is AuthFailure
            ? error.message
            : 'Unable to open your account. Please try again.',
        onRetry: () {
          ref.invalidate(restoredSessionProvider);
          ref.invalidate(startupViewModelProvider);
        },
        onSignIn: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        ),
      ),
    );
  }
}
