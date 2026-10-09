import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });
  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: DashboardColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: DashboardColors.muted,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
          ),
          child: const Text(
            'View All',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
