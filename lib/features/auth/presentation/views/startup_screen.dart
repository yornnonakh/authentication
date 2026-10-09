import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/view_models/startup_view_model.dart';
import '../../../onboarding/presentation/views/splash_screen.dart';
import '../view_models/session_restore_view_model.dart';
import '../../domain/models/auth_event.dart';

// Startup selects the initial screen. Later sign-in and recovery actions
// continue to control their own navigation.
class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  bool _navigated = false;

  void _navigateToDestination(StartupDestination destination) {
    if (_navigated || !mounted) return;
    _navigated = true;
    final routeName = switch (destination) {
      StartupDestination.dashboard => AppRoutes.dashboard,
      StartupDestination.onboarding => AppRoutes.onboarding,
      StartupDestination.signIn => AppRoutes.signIn,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<StartupDestination>>(
      startupViewModelProvider,
      (previous, next) {
        next.whenData(_navigateToDestination);
      },
    );

    final restored = ref.watch(startupViewModelProvider);

    return restored.when(
      skipLoadingOnRefresh: false,
      data: (destination) {
        _navigateToDestination(destination);
        return const SplashScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, stackTrace) => SplashScreen(
        errorMessage: error is AuthFailure
            ? error.message
            : 'Unable to open your account. Please try again.',
        onRetry: () {
          _navigated = false;
          ref.invalidate(restoredSessionProvider);
          ref.invalidate(startupViewModelProvider);
        },
        onSignIn: () {
          Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
        },
      ),
    );
  }
}

