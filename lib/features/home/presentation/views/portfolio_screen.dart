import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/dashboard.dart';
import '../theme/dashboard_colors.dart';
import '../view_models/dashboard_navigation_view_model.dart';
import '../view_models/home_view_model.dart';
import '../widgets/dashboard_icon_button.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/investment_tile.dart';
import '../widgets/portfolio_chart.dart';
import '../widgets/portfolio_legend.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeViewModelProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      key: const PageStorageKey('portfolio-scroll'),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 108 + bottomInset),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to home',
                onPressed: ref
                    .read(dashboardNavigationViewModelProvider.notifier)
                    .showHome,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: DashboardColors.ink,
                  size: 26,
                ),
              ),
              const Expanded(
                child: Text(
                  'Portfolio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: DashboardColors.ink,
                  ),
                ),
              ),
              DashboardIconButton(
                icon: Icons.forum_outlined,
                tooltip: 'Messages',
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 40),
          PortfolioChart(
            balance: dashboard.wallet.balance,
            allocations: dashboard.allocations,
          ),
          const SizedBox(height: 46),
          PortfolioLegend(allocations: dashboard.allocations),
          const SizedBox(height: 26),
          DashboardSectionHeader(title: 'Your Investment', onViewAll: () {}),
          const SizedBox(height: 1),
          for (final investment in dashboard.investments)
            InvestmentTile(
              logo: _investmentLogo(investment.brand),
              name: investment.name,
              symbol: investment.symbol,
              amount: investment.amount,
              change: investment.change,
              isPositive: investment.isPositive,
              sparkline: investment.sparkline,
            ),
        ],
      ),
    );
  }
}

Widget _investmentLogo(InvestmentBrand brand) => switch (brand) {
  InvestmentBrand.apple => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF2B3843),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.apple, color: Colors.white, size: 26),
  ),
  InvestmentBrand.paypal => const Stack(
    alignment: Alignment.center,
    children: [
      Positioned(
        left: 10,
        top: 1,
        child: Text(
          'P',
          style: TextStyle(
            color: Color(0xFF009CDE),
            fontSize: 33,
            height: 1,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      Positioned(
        left: 5,
        top: -2,
        child: Text(
          'P',
          style: TextStyle(
            color: Color(0xFF003087),
            fontSize: 33,
            height: 1,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  ),
  InvestmentBrand.facebook => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF149FF9),
      shape: BoxShape.circle,
    ),
    child: const Text(
      'f',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    ),
  ),
};
