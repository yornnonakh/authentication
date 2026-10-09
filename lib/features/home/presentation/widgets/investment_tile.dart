import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';

class InvestmentTile extends StatelessWidget {
  const InvestmentTile({
    super.key,
    required this.logo,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.change,
    required this.isPositive,
    this.sparkline = const [],
  });

  final Widget logo;
  final String name;
  final String symbol;
  final String amount;
  final String change;
  final bool isPositive;
  final List<double> sparkline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          SizedBox(width: 36, height: 36, child: logo),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DashboardColors.ink,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DashboardColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: SizedBox(
                height: 30,
                child: CustomPaint(painter: _SparklinePainter(sparkline)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DashboardColors.ink,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                change,
                style: TextStyle(
                  fontSize: 10,
                  color: isPositive
                      ? DashboardColors.positive
                      : DashboardColors.negative,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.points);
  final List<double> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2 || size.width <= 0) return;
    final minimum = points.reduce(math.min);
    final maximum = points.reduce(math.max);
    final range = maximum - minimum;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = range == 0
          ? size.height / 2
          : size.height - 3 - (points[i] - minimum) / range * (size.height - 6);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF373D46)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points;
}
