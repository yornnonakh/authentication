import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A short, decorative greeting by default; loops for ongoing work.
class AiDotIndicator extends StatefulWidget {
  const AiDotIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.loop = false,
  });

  final double size;
  final Color? color;
  final bool loop;

  @override
  State<AiDotIndicator> createState() => _AiDotIndicatorState();
}

class _AiDotIndicatorState extends State<AiDotIndicator>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate();
  }

  @override
  void didUpdateWidget(AiDotIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loop != widget.loop) _animate();
  }

  void _animate() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0;
    } else if (widget.loop) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (!_controller.isCompleted) {
      _controller.forward();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        width: widget.size * 1.75,
        height: widget.size,
        child: CustomPaint(
          painter: _DotPainter(animation: _controller, color: widget.color),
        ),
      ),
    ),
  );
}

class _DotPainter extends CustomPainter {
  _DotPainter({required this.animation, this.color})
    : super(repaint: animation);

  final Animation<double> animation;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    const palette = [Color(0xFFC4A2FF), Color(0xFFA78BFA), Color(0xFF93C5FD)];
    final phase = animation.value * math.pi * 4;
    // Ease into and out of motion so the decorative version settles softly.
    final envelope = math.pow(math.sin(animation.value * math.pi), 2);
    for (var i = 0; i < 3; i++) {
      final wave = math.sin(phase - i * 0.85) * envelope;
      final center = Offset(
        size.width * (0.2 + i * 0.3),
        size.height * (0.5 - wave * 0.16),
      );
      final radius = size.height * (0.14 + (wave + envelope) * 0.025);
      final tint = color ?? palette[i];
      canvas.drawCircle(
        center,
        radius * 2.4,
        Paint()
          ..shader = RadialGradient(
            colors: [tint.withValues(alpha: 0.3), tint.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius * 2.4)),
      );
      canvas.drawCircle(center, radius, Paint()..color = tint);
      canvas.drawCircle(
        center - Offset(radius * 0.25, radius * 0.3),
        radius * 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.animation != animation;
}
