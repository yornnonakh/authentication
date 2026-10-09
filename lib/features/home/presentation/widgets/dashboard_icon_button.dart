import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

class DashboardIconButton extends StatelessWidget {
  const DashboardIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        foregroundColor: DashboardColors.ink,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.all(10),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 20),
          if (showBadge)
            Positioned(
              right: 1,
              top: 0,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFED767C),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
