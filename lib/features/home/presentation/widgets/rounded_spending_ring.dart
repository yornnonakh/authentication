import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'finance_widgets.dart';

/// A segmented ring with softly rounded corners, matching the report cards.
class RoundedSpendingRing extends StatelessWidget {
  const RoundedSpendingRing({
    super.key,
    required this.categories,
    required this.diameter,
    required this.selected,
    required this.onSelect,
  });
  final Map<String, int> categories;
  final double diameter;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: diameter,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final offset =
            details.localPosition - Offset(diameter / 2, diameter / 2);
        if (offset.distance < diameter * 0.29 ||
            offset.distance > diameter * 0.43) {
          return;
        }
        final angle =
            (math.atan2(offset.dy, offset.dx) + math.pi / 2) % (math.pi * 2);
        final total = categories.values.fold(0, (sum, value) => sum + value);
        var end = 0.0;
        for (final entry in categories.entries) {
          end += entry.value / total * math.pi * 2;
          if (angle <= end) {
            onSelect(entry.key);
            return;
          }
        }
      },
      child: CustomPaint(painter: _RingPainter(categories, selected)),
    ),
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.categories, this.selected);
  final Map<String, int> categories;
  final String? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final total = categories.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return;
    final inner = size.shortestSide * 0.29;
    final thickness = size.shortestSide * 0.12;
    var angle = -math.pi / 2;
    for (final entry in categories.entries) {
      final outer = inner + thickness + (entry.key == selected ? 4 : 0);
      final paint = Paint()..color = FinanceStyle.categoryColor(entry.key);
      final sweep = entry.value / total * math.pi * 2;
      if (categories.length == 1) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = outer - inner;
        canvas.drawCircle(center, (outer + inner) / 2, paint);
      } else {
        final gap = math.min(0.025, sweep * 0.15);
        final start = angle + gap / 2;
        final end = angle + sweep - gap / 2;
        final corner = math.min(
          10.0,
          math.min(thickness * 0.24, (end - start) * inner * 0.24),
        );
        Offset point(double radius, double theta) =>
            center + Offset(math.cos(theta), math.sin(theta)) * radius;
        final outerStart = point(outer, start + corner / outer);
        final outerCorner = point(outer, end);
        final outerEnd = point(outer - corner, end);
        final innerCorner = point(inner, end);
        final innerEnd = point(inner, end - corner / inner);
        final innerStartCorner = point(inner, start);
        final innerStart = point(inner + corner, start);
        final outerStartCorner = point(outer, start);
        final path = Path()
          ..moveTo(outerStart.dx, outerStart.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: outer),
            start + corner / outer,
            end - start - 2 * corner / outer,
            false,
          )
          ..quadraticBezierTo(
            outerCorner.dx,
            outerCorner.dy,
            outerEnd.dx,
            outerEnd.dy,
          );
        final innerRadial = point(inner + corner, end);
        path
          ..lineTo(innerRadial.dx, innerRadial.dy)
          ..quadraticBezierTo(
            innerCorner.dx,
            innerCorner.dy,
            innerEnd.dx,
            innerEnd.dy,
          )
          ..arcTo(
            Rect.fromCircle(center: center, radius: inner),
            end - corner / inner,
            -(end - start - 2 * corner / inner),
            false,
          )
          ..quadraticBezierTo(
            innerStartCorner.dx,
            innerStartCorner.dy,
            innerStart.dx,
            innerStart.dy,
          );
        final outerRadial = point(outer - corner, start);
        path
          ..lineTo(outerRadial.dx, outerRadial.dy)
          ..quadraticBezierTo(
            outerStartCorner.dx,
            outerStartCorner.dy,
            outerStart.dx,
            outerStart.dy,
          )
          ..close();
        canvas.drawPath(path, paint);
      }
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.categories != categories || oldDelegate.selected != selected;
}
