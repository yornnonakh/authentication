import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/dashboard_providers.dart';
import '../../domain/models/dashboard.dart';

final homeViewModelProvider =
    NotifierProvider.autoDispose<HomeViewModel, Dashboard>(HomeViewModel.new);

/// Home and portfolio present the same dashboard snapshot.
class HomeViewModel extends Notifier<Dashboard> {
  @override
  Dashboard build() => ref.watch(dashboardRepositoryProvider).getDashboard();
}
