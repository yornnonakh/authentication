import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';

final restoredSessionProvider =
    AsyncNotifierProvider.autoDispose<SessionRestoreViewModel, bool>(
      SessionRestoreViewModel.new,
      retry: (retryCount, error) => null,
    );

class SessionRestoreViewModel extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(authRepositoryProvider).restoreSession();
}
