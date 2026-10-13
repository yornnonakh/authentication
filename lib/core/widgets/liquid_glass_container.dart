import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A grouped form surface, shared by all account screens.
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({super.key,required this.child,this.padding = const EdgeInsets.all(24),
    this.borderRadius = 16,this.blur = AppConstants.glassBlur,this.opacity = AppConstants.glassOpacity});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius,blur,opacity;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity,padding: padding,
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerLow,borderRadius: BorderRadius.circular(borderRadius)),child: child);
}
