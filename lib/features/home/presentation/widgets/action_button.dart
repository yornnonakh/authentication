import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF08090B),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 17),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: DashboardColors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
