import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = AppConstants.borderRadius,
    this.blur = AppConstants.glassBlur,
    this.opacity = AppConstants.glassOpacity,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final radius = BorderRadius.circular(borderRadius);

    final glassOpacity =
    opacity.clamp(0.05, 0.32).toDouble();

    final blurValue =
    blur.clamp(0.0, 40.0).toDouble();

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.20 : 0.08,
            ),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(
              alpha: isDark ? 0.04 : 0.60,
            ),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              // Glass surface
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: radius,

                  // Translucent glass gradient
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                      Colors.white.withValues(
                        alpha: 0.16,
                      ),
                      const Color(0xFF18202F)
                          .withValues(alpha: 0.22),
                      Colors.white.withValues(
                        alpha: 0.06,
                      ),
                    ]
                        : [
                      Colors.white.withValues(
                        alpha: glassOpacity + 0.20,
                      ),
                      const Color(0xFFE5EDF8)
                          .withValues(
                        alpha: glassOpacity * 0.40,
                      ),
                      Colors.white.withValues(
                        alpha: glassOpacity + 0.10,
                      ),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),

                  // Glass outline
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: isDark ? 0.25 : 0.60,
                    ),
                    width: 1,
                  ),
                ),
                child: child,
              ),

              // Reflective glass edge
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GlassBorderPainter(
                      radius: borderRadius,
                      isDark: isDark,
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

// iOS-inspired reflective edge
class _GlassBorderPainter extends CustomPainter {
  const _GlassBorderPainter({
    required this.radius,
    required this.isDark,
  });

  final double radius;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = (Offset.zero & size).deflate(1);

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(
        (radius - 1).clamp(0.0, 1000.0).toDouble(),
      ),
    );

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(
          alpha: isDark ? 0.65 : 0.95,
        ),
        Colors.white.withValues(alpha: 0.30),
        Colors.white.withValues(alpha: 0.05),
        Colors.white.withValues(
          alpha: isDark ? 0.22 : 0.55,
        ),
      ],
      stops: const [0.0, 0.30, 0.70, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(
      covariant _GlassBorderPainter oldDelegate,
      ) {
    return oldDelegate.radius != radius ||
        oldDelegate.isDark != isDark;
  }
}