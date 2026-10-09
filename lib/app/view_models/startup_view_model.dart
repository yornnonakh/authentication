import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/view_models/session_restore_view_model.dart';

enum StartupDestination { dashboard, onboarding, signIn }

final startupViewModelProvider =
    AsyncNotifierProvider.autoDispose<StartupViewModel, StartupDestination>(
      StartupViewModel.new,
      retry: (count, error) => null,
    );

class StartupViewModel extends AsyncNotifier<StartupDestination> {
  @override
  Future<StartupDestination> build() async {
    final splash = Future<void>.delayed(const Duration(milliseconds: 1100));
    final hasSession = await ref.watch(restoredSessionProvider.future);
    await splash;
    return hasSession
        ? StartupDestination.dashboard
        : StartupDestination.onboarding;
  }
}
