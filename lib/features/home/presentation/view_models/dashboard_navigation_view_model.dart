import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardTab { home, portfolio, profile }

final dashboardNavigationViewModelProvider =
    NotifierProvider.autoDispose<DashboardNavigationViewModel, DashboardTab>(
      DashboardNavigationViewModel.new,
    );

class DashboardNavigationViewModel extends Notifier<DashboardTab> {
  @override
  DashboardTab build() => DashboardTab.home;

  void select(int index) {
    if (index == 0) state = DashboardTab.home;
    if (index == 1) state = DashboardTab.portfolio;
    if (index == 3) state = DashboardTab.profile;
  }

  void showProfile() => state = DashboardTab.profile;

  void showHome() => state = DashboardTab.home;
}
