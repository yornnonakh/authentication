import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../auth/data/providers/auth_providers.dart';
import '../../../auth/domain/models/auth_event.dart';
import '../../../profile/presentation/views/profile_screen.dart';
import '../theme/dashboard_colors.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'portfolio_screen.dart';

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
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.signIn,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(dashboardNavigationViewModelProvider);
    final navigation = ref.read(dashboardNavigationViewModelProvider.notifier);
    ref.listen(authEventsProvider, (previous, next) {
      next.whenData((event) {
        if (event.type == AuthEventType.signedOut) _openSignIn();
      });
    });
    ref.listen(dashboardNavigationViewModelProvider, (previous, next) {
      if (previous != next) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
    final navIndex = tab == DashboardTab.profile ? 3 : tab.index;
    return PopScope(
      canPop: tab == DashboardTab.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) navigation.showHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F2FB),
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: DashboardColors.background),
          child: SizedBox.expand(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Stack(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: IndexedStack(
                        index: tab.index,
                        children: [
                          const HomeScreen(),
                          const PortfolioScreen(),
                          ProfileScreen(onLoggedOut: _openSignIn),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        minimum: const EdgeInsets.only(bottom: 16),
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.82,
                            child: AppBottomNavBar(
                              currentIndex: navIndex,
                              onTap: navigation.select,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
