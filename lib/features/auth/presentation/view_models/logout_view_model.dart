import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';

final logoutViewModelProvider =
    AsyncNotifierProvider.autoDispose<LogoutViewModel, void>(
      LogoutViewModel.new,
    );

class LogoutViewModel extends AsyncNotifier<void> {
  @override
  void build() {}

  Future<bool> logout() async {
    if (state.isLoading) return false;
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    try {
      await repository.signOut();
      if (!ref.mounted) return false;
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
