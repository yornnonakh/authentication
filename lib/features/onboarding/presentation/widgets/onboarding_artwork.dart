import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/tracker_palette.dart';
import '../../domain/models/onboarding_page.dart';

/// Flat, resolution-independent scenes drawn directly on the page canvas.
class OnboardingArtwork extends StatelessWidget {
  const OnboardingArtwork({super.key, required this.illustration});

  final OnboardingIllustration illustration;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      painter: _OnboardingScene(
        illustration,
        colors: Theme.of(context).colorScheme,
      ),
      size: const Size.square(320),
    ),
  );
}

class _OnboardingScene extends CustomPainter {
  const _OnboardingScene(this.illustration, {required this.colors});

  final OnboardingIllustration illustration;
  final ColorScheme colors;

  static const _ink = Color(0xFF3F3C48);
  static const _green = TrackerPalette.mint;
  Color get _deepGreen => Color.lerp(_green, TrackerPalette.ink, 0.45)!;
  Color get _mint => colors.primaryContainer;
  Color get _accent => colors.primary;
  Color get _accentDetail => Color.lerp(_accent, _ink, 0.25)!;
  static const _skin = Color(0xFFE8B69C);
  static const _clay = Color(0xFFD0AD97);
  Color get _cream =>
      Color.lerp(colors.surfaceContainerLow, colors.primary, 0.08)!;

  Color get _line => colors.onSurfaceVariant.withValues(alpha: 0.5);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 320;
    canvas.save();
    canvas.translate(
      (size.width - 320 * scale) / 2,
      (size.height - 320 * scale) / 2,
    );
    canvas.scale(scale);
    _stroke(
      canvas,
      [const Offset(42, 294), const Offset(282, 294)],
      _line,
      1.2,
    );
    switch (illustration) {
      case OnboardingIllustration.card:
        _spending(canvas);
      case OnboardingIllustration.growth:
        _saving(canvas);
      case OnboardingIllustration.security:
        _security(canvas);
    }
    canvas.restore();
  }

  void _spending(Canvas canvas) {
    // A light thought bubble keeps the composition open above the character.
    _rounded(canvas, const Rect.fromLTWH(211, 30, 73, 61), 28, _line);
    _rounded(
      canvas,
      const Rect.fromLTWH(212.2, 31.2, 70.6, 58.6),
      27,
      colors.surfaceContainerLow,
    );
    _shape(canvas, [
      const Offset(224, 87),
      const Offset(218, 104),
      const Offset(240, 89),
    ], _line);
    _shape(canvas, [
      const Offset(225, 86),
      const Offset(221, 99),
      const Offset(238, 87),
    ], colors.surfaceContainerLow);
    _rounded(canvas, const Rect.fromLTWH(228, 49, 40, 27), 5, _accent);
    _rounded(canvas, const Rect.fromLTWH(250, 57, 21, 13), 4, _deepGreen);
    canvas.drawCircle(const Offset(256, 63.5), 1.5, Paint()..color = _cream);
    _dashed(
      canvas,
      Path()
        ..moveTo(284, 79)
        ..quadraticBezierTo(308, 89, 307, 118),
    );

    _plant(canvas, x: 70, y: 211, scale: 0.82, raised: true);
    _plant(canvas, x: 252, y: 276, scale: 0.85);
    _person(canvas, x: 164, y: 118, shirt: _mint);
    // Both arms meet naturally at the phone.
    _stroke(
      canvas,
      [const Offset(140, 140), const Offset(132, 166), const Offset(157, 177)],
      _skin,
      9,
    );
    _stroke(
      canvas,
      [const Offset(186, 140), const Offset(194, 165), const Offset(173, 177)],
      _skin,
      9,
    );
    _rounded(canvas, const Rect.fromLTWH(157, 150, 16, 28), 3, _deepGreen);
    _rounded(canvas, const Rect.fromLTWH(160, 154, 10, 16), 1, _green);
    canvas.drawCircle(const Offset(165, 174), 1, Paint()..color = _mint);
    canvas.drawOval(
      const Rect.fromLTWH(151, 169, 10, 8),
      Paint()..color = _skin,
    );
    canvas.drawOval(
      const Rect.fromLTWH(170, 169, 9, 8),
      Paint()..color = _skin,
    );
  }

  void _saving(Canvas canvas) {
    // A dotted path leads to a goal, echoing the reference's delivery route.
    _dashed(
      canvas,
      Path()
        ..moveTo(48, 101)
        ..cubicTo(107, 107, 66, 41, 108, 51)
        ..cubicTo(147, 64, 106, 117, 162, 110)
        ..quadraticBezierTo(186, 105, 203, 78),
    );
    canvas.drawCircle(const Offset(221, 63), 21, Paint()..color = _cream);
    canvas.drawCircle(const Offset(221, 63), 12, Paint()..color = _accent);
    _stroke(
      canvas,
      [const Offset(216, 63), const Offset(220, 67), const Offset(227, 58)],
      _deepGreen,
      2.5,
    );

    _person(canvas, x: 105, y: 137, shirt: _accent, legLength: 80);
    _stroke(
      canvas,
      [const Offset(82, 157), const Offset(74, 182), const Offset(87, 197)],
      _skin,
      9,
    );
    _stroke(
      canvas,
      [const Offset(128, 157), const Offset(142, 180), const Offset(164, 170)],
      _skin,
      9,
    );
    _coin(canvas, const Offset(171, 162), 14);

    for (var index = 0; index < 4; index++) {
      _coinLayer(canvas, 176, 281 - index * 9, 42);
    }
    for (var index = 0; index < 7; index++) {
      _coinLayer(canvas, 223, 281 - index * 9, 45);
    }
    // A small sprout turns the tallest stack into a savings metaphor.
    _stroke(
      canvas,
      [const Offset(245, 217), const Offset(245, 184)],
      _deepGreen,
      2,
    );
    _leaf(canvas, const Offset(245, 195), const Offset(224, 175), _green);
    _leaf(canvas, const Offset(245, 204), const Offset(266, 181), _deepGreen);
    _plant(canvas, x: 276, y: 282, scale: 0.5);
  }

  void _security(Canvas canvas) {
    // A welcoming doorway with a separate shield badge, rather than a UI card.
    _rounded(canvas, const Rect.fromLTWH(125, 66, 112, 228), 2, _line);
    _rounded(canvas, const Rect.fromLTWH(129, 70, 104, 224), 1, _clay);
    _rounded(
      canvas,
      const Rect.fromLTWH(135, 76, 92, 218),
      1,
      const Color(0xFFD7B7A2),
    );
    _stroke(
      canvas,
      [const Offset(135, 294), const Offset(135, 76), const Offset(227, 76)],
      const Color(0xFFB4927D),
      1.5,
    );
    _rounded(canvas, const Rect.fromLTWH(211, 187, 7, 22), 3, _cream);
    canvas.drawCircle(const Offset(214.5, 188), 5.5, Paint()..color = _ink);
    _rounded(canvas, const Rect.fromLTWH(214, 190, 1, 8), 0.5, _cream);
    _plant(canvas, x: 100, y: 275, scale: 0.92);
    _rounded(canvas, const Rect.fromLTWH(135, 289, 111, 5), 2, _deepGreen);

    canvas.drawCircle(const Offset(251, 121), 34, Paint()..color = _cream);
    final shield = Path()
      ..moveTo(251, 96)
      ..quadraticBezierTo(263, 105, 272, 105)
      ..lineTo(270, 126)
      ..quadraticBezierTo(268, 139, 251, 149)
      ..quadraticBezierTo(234, 139, 232, 126)
      ..lineTo(230, 105)
      ..quadraticBezierTo(242, 104, 251, 96)
      ..close();
    canvas.drawPath(shield, Paint()..color = _accent);
    _stroke(
      canvas,
      [const Offset(241, 122), const Offset(248, 129), const Offset(261, 114)],
      _cream,
      3,
    );
    _dashed(
      canvas,
      Path()
        ..moveTo(62, 153)
        ..quadraticBezierTo(56, 103, 100, 107),
    );
    canvas.drawCircle(const Offset(96, 79), 4, Paint()..color = _accent);
  }

  void _person(
    Canvas canvas, {
    required double x,
    required double y,
    required Color shirt,
    double legLength = 99,
  }) {
    final hip = y + 69;
    final foot = hip + legLength;
    _shape(canvas, [
      Offset(x - 20, hip - 6),
      Offset(x + 20, hip - 6),
      Offset(x + 21, foot - 3),
      Offset(x + 9, foot - 3),
      Offset(x - 1, hip + 30),
      Offset(x - 10, foot - 3),
      Offset(x - 22, foot - 3),
    ], _ink);
    _stroke(
      canvas,
      [Offset(x, hip + 11), Offset(x - 1, hip + 29)],
      const Color(0xFF69616B),
      1,
    );
    _rounded(canvas, Rect.fromLTWH(x - 22, foot - 5, 12, 8), 2, _skin);
    _rounded(canvas, Rect.fromLTWH(x + 9, foot - 5, 12, 8), 2, _skin);
    _rounded(canvas, Rect.fromLTWH(x - 27, foot + 1, 18, 6), 3, _ink);
    _rounded(canvas, Rect.fromLTWH(x + 8, foot + 1, 19, 6), 3, _ink);
    _shape(canvas, [
      Offset(x - 8, y),
      Offset(x - 24, y + 8),
      Offset(x - 31, y + 28),
      Offset(x - 20, y + 33),
      Offset(x - 19, hip),
      Offset(x + 20, hip),
      Offset(x + 21, y + 33),
      Offset(x + 31, y + 27),
      Offset(x + 23, y + 8),
      Offset(x + 8, y),
    ], shirt);
    _rounded(canvas, Rect.fromLTWH(x - 5, y - 10, 10, 16), 4, _skin);
    _stroke(
      canvas,
      [Offset(x - 8, y + 3), Offset(x, y + 8), Offset(x + 8, y + 3)],
      shirt == _accent ? _accentDetail : _accent,
      1.5,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y - 22), width: 26, height: 34),
      Paint()..color = _skin,
    );
    _shape(canvas, [
      Offset(x - 13, y - 20),
      Offset(x - 17, y - 37),
      Offset(x - 12, y - 36),
      Offset(x - 14, y - 43),
      Offset(x - 5, y - 39),
      Offset(x - 3, y - 46),
      Offset(x + 4, y - 40),
      Offset(x + 12, y - 39),
      Offset(x + 16, y - 31),
      Offset(x + 12, y - 19),
      Offset(x + 8, y - 31),
      Offset(x - 6, y - 32),
    ], _ink);
    canvas.drawCircle(Offset(x - 5, y - 22), 0.8, Paint()..color = _ink);
    canvas.drawCircle(Offset(x + 5, y - 22), 0.8, Paint()..color = _ink);
    _stroke(canvas, [Offset(x - 2, y - 14), Offset(x + 3, y - 14)], _clay, 1);
  }

  void _plant(
    Canvas canvas, {
    required double x,
    required double y,
    double scale = 1,
    bool raised = false,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);
    for (final tip in [
      const Offset(-26, -43),
      const Offset(0, -61),
      const Offset(27, -48),
      const Offset(17, -25),
    ]) {
      _stroke(canvas, [const Offset(0, 0), tip * 0.8], _green, 1.5);
      _leaf(canvas, tip * 0.45, tip, tip.dx > 0 ? _green : _deepGreen);
    }
    _shape(canvas, [
      const Offset(-20, 0),
      const Offset(20, 0),
      const Offset(14, 23),
      const Offset(-14, 23),
    ], _clay);
    _rounded(canvas, const Rect.fromLTWH(-22, -2, 44, 5), 2, _cream);
    if (raised) {
      _stroke(
        canvas,
        [const Offset(-17, 24), const Offset(-22, 100)],
        _line,
        1.5,
      );
      _stroke(
        canvas,
        [const Offset(17, 24), const Offset(22, 100)],
        _line,
        1.5,
      );
      _stroke(canvas, [const Offset(-19, 47), const Offset(19, 47)], _line, 1);
    }
    canvas.restore();
  }

  void _leaf(Canvas canvas, Offset base, Offset tip, Color color) {
    final vector = tip - base;
    final normal = Offset(-vector.dy, vector.dx) * 0.3;
    canvas.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + vector.dx * 0.2 + normal.dx,
          base.dy + vector.dy * 0.2 + normal.dy,
          tip.dx,
          tip.dy,
        )
        ..quadraticBezierTo(
          base.dx + vector.dx * 0.65 - normal.dx,
          base.dy + vector.dy * 0.65 - normal.dy,
          base.dx,
          base.dy,
        )
        ..close(),
      Paint()..color = color,
    );
  }

  void _coin(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius, Paint()..color = _accent);
    canvas.drawCircle(
      center,
      radius - 3,
      Paint()
        ..color = _accentDetail
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _stroke(
      canvas,
      [center - const Offset(0, 5), center + const Offset(0, 5)],
      _cream,
      2,
    );
  }

  void _coinLayer(Canvas canvas, double x, double y, double width) {
    _rounded(canvas, Rect.fromLTWH(x, y, width, 10), 3, _accent);
    _stroke(
      canvas,
      [Offset(x + 3, y + 9), Offset(x + width - 3, y + 9)],
      _accentDetail,
      1,
    );
    _stroke(canvas, [Offset(x + 8, y + 2), Offset(x + 8, y + 6)], _cream, 1);
  }

  void _rounded(Canvas canvas, Rect rect, double radius, Color color) =>
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()..color = color,
      );

  void _shape(Canvas canvas, List<Offset> points, Color color) =>
      canvas.drawPath(Path()..addPolygon(points, true), Paint()..color = color);

  void _stroke(Canvas canvas, List<Offset> points, Color color, double width) =>
      canvas.drawPath(
        Path()..addPolygon(points, false),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

  void _dashed(Canvas canvas, Path path) {
    final paint = Paint()
      ..color = _line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 8) {
        canvas.drawPath(metric.extractPath(distance, distance + 3), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_OnboardingScene oldDelegate) =>
      illustration != oldDelegate.illustration || colors != oldDelegate.colors;
}
