import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../../auth/domain/models/auth_event.dart';
import '../../../profile/presentation/views/profile_screen.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import 'home_screen.dart';
import 'report_screen.dart';
import 'plan_screen.dart';
import 'finance_settings_screen.dart';
import '../../../../core/theme/tracker_palette.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/expense_entry_sheet.dart';
import '../view_models/expense_view_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLeaving = false;
  void _openSignIn() {
    if (!mounted || _isLeaving) return;
    _isLeaving = true;
    FocusScope.of(context).unfocus();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(dashboardNavigationViewModelProvider);
    final navigation = ref.read(dashboardNavigationViewModelProvider.notifier);
    ref.listen(authEventsProvider, (_, next) {
      next.whenData((event) {
        if (event.type == AuthEventType.signedOut) _openSignIn();
      });
    });
    ref.listen(dashboardNavigationViewModelProvider, (previous, next) {
      if (previous != next) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
    return PopScope(
      canPop: tab == DashboardTab.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) navigation.showHome();
      },
      child: Scaffold(
        backgroundColor: TrackerPalette.backdrop(context),
        body: ColoredBox(
          color: TrackerPalette.backdrop(context),
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: IndexedStack(
                  index: tab.index,
                  children: [
                    HeroMode(
                      enabled: tab == DashboardTab.home,
                      child: TickerMode(
                        enabled: tab == DashboardTab.home,
                        child: AppEntrance(
                          active: tab == DashboardTab.home,
                          child: const HomeScreen(),
                        ),
                      ),
                    ),
                    HeroMode(
                      enabled: tab == DashboardTab.report,
                      child: TickerMode(
                        enabled: tab == DashboardTab.report,
                        child: AppEntrance(
                          active: tab == DashboardTab.report,
                          child: const ReportScreen(),
                        ),
                      ),
                    ),
                    TickerMode(
                      enabled: tab == DashboardTab.plan,
                      child: AppEntrance(
                        active: tab == DashboardTab.plan,
                        child: const PlanScreen(),
                      ),
                    ),
                    TickerMode(
                      enabled: tab == DashboardTab.settings,
                      child: AppEntrance(
                        active: tab == DashboardTab.settings,
                        child: const FinanceSettingsScreen(),
                      ),
                    ),
                    TickerMode(
                      enabled: tab == DashboardTab.profile,
                      child: AppEntrance(
                        active: tab == DashboardTab.profile,
                        child: ProfileScreen(onLoggedOut: _openSignIn),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: tab == DashboardTab.profile
              ? DashboardTab.settings.index
              : tab.index,
          onTap: navigation.select,
          onAdd: ref.watch(expenseViewModelProvider).hasValue
              ? () => showExpenseEntrySheet(
                  context,
                  ref.read(financeMonthProvider),
                )
              : null,
        ),
      ),
    );
  }
}
