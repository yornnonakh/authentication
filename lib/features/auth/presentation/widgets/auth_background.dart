import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
          ? const Color(0xFF0B1020)
          : const Color(0xFFF8FAFC),

      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          // 1. Clean gradient background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                  Color(0xFF0B1020),
                  Color(0xFF121827),
                  Color(0xFF0F172A),
                ]
                    : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF8FAFC),
                  Color(0xFFF1F5F9),
                ],
              ),
            ),
          ),

          // 2. Soft orange ambient light
          Positioned(
            top: -140,
            right: -140,
            child: _AmbientGlow(
              size: 420,
              color: isDark
                  ? const Color(0xFFFF8A3D)
                  .withValues(alpha: 0.18)
                  : const Color(0xFFFFAA70)
                  .withValues(alpha: 0.25),
            ),
          ),

          // 3. Soft blue ambient light
          Positioned(
            bottom: -170,
            left: -150,
            child: _AmbientGlow(
              size: 450,
              color: isDark
                  ? const Color(0xFF6478FF)
                  .withValues(alpha: 0.15)
                  : const Color(0xFF93C5FD)
                  .withValues(alpha: 0.22),
            ),
          ),

          // 4. Subtle center highlight
          Positioned(
            top: 180,
            left: -160,
            child: _AmbientGlow(
              size: 300,
              color: isDark
                  ? const Color(0xFFA78BFA)
                  .withValues(alpha: 0.06)
                  : const Color(0xFFE9D5FF)
                  .withValues(alpha: 0.15),
            ),
          ),

          // 5. Screen content
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Reusable soft radial glow.
/// No heavy BackdropFilter required.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.5,
            colors: [
              color,
              color.withValues(alpha: color.a * 0.45),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}