// lib/core/widgets/investment_tile.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InvestmentTile extends StatelessWidget {
  const InvestmentTile({
    super.key,
    required this.logo,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.change,
    required this.isPositive,
  });

  final Widget logo;
  final String name;
  final String symbol;
  final String amount;
  final String change;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          logo,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  symbol,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          // Mini chart placeholder
          Container(
            width: 50,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isPositive
                  ? AppColors.available.withOpacity(0.15)
                  : AppColors.bonds.withOpacity(0.15),
            ),
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              size: 18,
              color: isPositive ? AppColors.available : AppColors.bonds,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: isPositive ? AppColors.available : AppColors.bonds,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}