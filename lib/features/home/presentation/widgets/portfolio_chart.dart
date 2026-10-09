import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/dashboard.dart';
import '../theme/dashboard_colors.dart';

Color allocationColor(AllocationType type) => switch (type) {
  AllocationType.available => DashboardColors.available,
  AllocationType.bonds => DashboardColors.bonds,
  AllocationType.spent => DashboardColors.spent,
};

class PortfolioChart extends StatelessWidget {
  const PortfolioChart({
    super.key,
    required this.balance,
    required this.allocations,
  });

  final String balance;
  final List<PortfolioAllocation> allocations;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Portfolio balance $balance. ${allocations.map((item) => '${item.label}: ${item.amount}').join(', ')}',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diameter = math.min(256.0, constraints.maxWidth - 32);
          return Center(
            child: SizedBox.square(
              dimension: diameter,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _PortfolioPainter(allocations)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4E5664),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        balance,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: DashboardColors.ink,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PortfolioPainter extends CustomPainter {
  _PortfolioPainter(this.allocations);
  final List<PortfolioAllocation> allocations;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.shortestSide / 2;
    final inner = outer - size.shortestSide * 0.155;
    final total = allocations.fold<double>(
      0,
      (sum, item) => sum + math.max(0, item.fraction),
    );
    if (total <= 0) return;
    var start = -math.pi / 2 + 0.22;
    for (final allocation in allocations) {
      final sweep = math.max(0, allocation.fraction) / total * math.pi * 2;
      if (sweep > 0.08) {
        final path = _roundedSegment(
          center,
          outer,
          inner,
          start + 0.022,
          sweep - 0.044,
        );
        canvas.drawPath(
          path,
          Paint()..color = allocationColor(allocation.type),
        );
      }
      start += sweep;
    }
  }

  Path _roundedSegment(
    Offset center,
    double outer,
    double inner,
    double start,
    double sweep,
  ) {
    final end = start + sweep;
    final corner = math.min(7.0, inner * sweep / 4);
    final outerCorner = corner / outer;
    final innerCorner = corner / inner;
    Offset point(double radius, double angle) =>
        center + Offset(math.cos(angle), math.sin(angle)) * radius;
    final first = point(outer, start + outerCorner);
    final path = Path()..moveTo(first.dx, first.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: outer),
      start + outerCorner,
      sweep - 2 * outerCorner,
      false,
    );
    final outerEnd = point(outer, end);
    final outerEndInset = point(outer - corner, end);
    path.quadraticBezierTo(
      outerEnd.dx,
      outerEnd.dy,
      outerEndInset.dx,
      outerEndInset.dy,
    );
    final innerEndInset = point(inner + corner, end);
    path.lineTo(innerEndInset.dx, innerEndInset.dy);
    final innerEnd = point(inner, end);
    final innerEndArc = point(inner, end - innerCorner);
    path.quadraticBezierTo(
      innerEnd.dx,
      innerEnd.dy,
      innerEndArc.dx,
      innerEndArc.dy,
    );
    path.arcTo(
      Rect.fromCircle(center: center, radius: inner),
      end - innerCorner,
      -sweep + 2 * innerCorner,
      false,
    );
    final innerStart = point(inner, start);
    final innerStartInset = point(inner + corner, start);
    path.quadraticBezierTo(
      innerStart.dx,
      innerStart.dy,
      innerStartInset.dx,
      innerStartInset.dy,
    );
    final outerStartInset = point(outer - corner, start);
    path.lineTo(outerStartInset.dx, outerStartInset.dy);
    final outerStart = point(outer, start);
    path.quadraticBezierTo(outerStart.dx, outerStart.dy, first.dx, first.dy);
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _PortfolioPainter oldDelegate) =>
      oldDelegate.allocations != allocations;
}
