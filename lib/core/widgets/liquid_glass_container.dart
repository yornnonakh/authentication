import 'dart:ui';

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A clipped, frosted surface with a translucent tint and a soft glass rim.
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(28),
    this.borderRadius = 24,
    this.blur = AppConstants.glassBlur,
    this.opacity = AppConstants.glassOpacity,
  }) : assert(blur >= 0),
       assert(opacity >= 0 && opacity <= 1),
       assert(borderRadius >= 0);

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius, blur, opacity;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final highContrast = MediaQuery.highContrastOf(context);
    final radius = BorderRadius.circular(borderRadius);
    final tint = colors.surfaceContainerLow.withValues(alpha: opacity);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: dark ? 0.12 : 0.09),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.12 : 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: highContrast ? 0 : blur,
            sigmaY: highContrast ? 0 : blur,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: highContrast ? colors.surfaceContainerLow : null,
              borderRadius: radius,
              border: Border.all(
                color: highContrast
                    ? colors.outline
                    : Colors.white.withValues(alpha: dark ? 0.2 : 0.75),
                width: 1,
              ),
              gradient: highContrast
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.alphaBlend(
                          Colors.white.withValues(alpha: dark ? 0.09 : 0.52),
                          tint,
                        ),
                        Color.alphaBlend(
                          Colors.white.withValues(alpha: dark ? 0.02 : 0.2),
                          tint,
                        ),
                        Color.alphaBlend(
                          colors.primary.withValues(alpha: dark ? 0.07 : 0.035),
                          tint,
                        ),
                      ],
                      stops: const [0, 0.55, 1],
                    ),
            ),
            child: Stack(
              children: [
                Padding(padding: padding, child: child),
                if (!highContrast)
                  Positioned(
                    top: 1,
                    left: borderRadius,
                    right: borderRadius,
                    child: IgnorePointer(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: dark ? 0.3 : 0.9),
                              Colors.white.withValues(alpha: 0),
                            ],
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
    );
  }
}
