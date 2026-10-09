import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/welcome_colors.dart';

class FinsightBrand extends StatelessWidget {
  const FinsightBrand({super.key, this.markSize = 36, this.fontSize = 25});
  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      FinsightMark(size: markSize),
      const SizedBox(width: 10),
      Text(
        'FinSight',
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: -.7,
          color: WelcomeColors.ink,
        ),
      ),
    ],
  );
}

class FinsightMark extends StatelessWidget {
  const FinsightMark({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: const _MarkPainter()),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    final petal = Path()
      ..moveTo(-s * .03, -s * .03)
      ..cubicTo(-s * .52, s * .02, -s * .49, -s * .51, -s * .2, -s * .46)
      ..cubicTo(s * .04, -s * .42, s * .02, -s * .12, -s * .03, -s * .03);
    const colors = [
      Color(0xFFB8CBFF),
      WelcomeColors.navy,
      Color(0xFF9DB8F5),
      Color(0xFF345395),
    ];
    for (final color in colors) {
      canvas.drawPath(petal, Paint()..color = color);
      canvas.rotate(math.pi / 2);
    }
  }

  @override
  bool shouldRepaint(covariant _MarkPainter oldDelegate) => false;
}
