import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      (
        label: 'Portfolio',
        icon: Icons.bar_chart_rounded,
        selectedIcon: Icons.bar_chart_rounded,
      ),
      (
        label: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        selectedIcon: Icons.account_balance_wallet_rounded,
      ),
      (
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.ink.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: Semantics(
                    label: destinations[index].label,
                    button: true,
                    selected: currentIndex == index,
                    child: Tooltip(
                      message: destinations[index].label,
                      excludeFromSemantics: true,
                      child: InkResponse(
                        onTap: () => onTap(index),
                        radius: 26,
                        child: SizedBox(
                          height: 48,
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentIndex == index
                                    ? DashboardColors.ink
                                    : Colors.transparent,
                              ),
                              child: Icon(
                                currentIndex == index
                                    ? destinations[index].selectedIcon
                                    : destinations[index].icon,
                                size: 23,
                                color: currentIndex == index
                                    ? Colors.white
                                    : DashboardColors.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
