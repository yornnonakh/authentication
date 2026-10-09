import 'package:flutter/material.dart';

import '../../domain/models/dashboard.dart';
import '../theme/dashboard_colors.dart';
import 'portfolio_chart.dart';

class PortfolioLegend extends StatelessWidget {
  const PortfolioLegend({super.key, required this.allocations});
  final List<PortfolioAllocation> allocations;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          for (final allocation in allocations)
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: allocationColor(allocation.type),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          allocation.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DashboardColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    allocation.amount,
                    style: const TextStyle(
                      fontSize: 11,
                      color: DashboardColors.muted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
