import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A clean grouped form surface styled following the concept UI white card containers.
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.borderRadius = 32,
    this.blur = AppConstants.glassBlur,
    this.opacity = AppConstants.glassOpacity,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius, blur, opacity;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
