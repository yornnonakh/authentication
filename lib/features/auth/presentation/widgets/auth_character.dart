import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AuthCharacterStyle { rounded, visor }

/// A vector mascot driven by form activity, without reading credential values.
class AuthCharacter extends StatefulWidget {
  const AuthCharacter({
    super.key,
    this.passwordFocused = false,
    this.passwordVisible = false,
    this.isTyping = false,
    this.lookProgress = 0,
    this.isLoading = false,
    this.style = AuthCharacterStyle.rounded,
  });

  final bool passwordFocused, passwordVisible, isTyping, isLoading;
  final AuthCharacterStyle style;
  final double lookProgress;

  @override
  State<AuthCharacter> createState() => _AuthCharacterState();
}

class _AuthCharacterState extends State<AuthCharacter>
    with SingleTickerProviderStateMixin {
  late final _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _idle.value = 0;
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final covering =
        !widget.isLoading && (widget.passwordFocused || widget.passwordVisible);
    final gaze = widget.isTyping && !covering && !widget.isLoading
        ? widget.lookProgress.clamp(0.0, 1.0) * 2 - 1
        : 0.0;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: SizedBox(
          width: 184,
          height: 192,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween(end: Offset(covering ? 1 : 0, gaze)),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, pose, child) => CustomPaint(
              painter: _CharacterPainter(
                idle: _idle,
                cover: pose.dx,
                gaze: pose.dy,
                peeking: widget.passwordVisible,
                typing: widget.isTyping,
                loading: widget.isLoading,
                style: widget.style,
                primary: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  _CharacterPainter({
    required this.idle,
    required this.cover,
    required this.gaze,
    required this.peeking,
    required this.typing,
    required this.loading,
    required this.style,
    required this.primary,
  }) : super(repaint: idle);

  final Animation<double> idle;
  final double cover, gaze;
  final bool peeking, typing, loading;
  final AuthCharacterStyle style;
  final Color primary;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 184, size.height / 192);
    canvas.translate(12, 16);
    final phase = idle.value;
    final cycle = phase * math.pi * 2;
    final visor = style == AuthCharacterStyle.visor;
    final accent = visor ? const Color(0xFF2BAFBF) : const Color(0xFF32BCDF);
    const pearl = Color(0xFFFAFDFF);
    final mid = Color.lerp(accent, pearl, 0.6)!;
    const deep = Color(0xFF2C414F);
    const led = Color(0xFF9AF6FF);
    // A sine loop has matching position and velocity at the repeat boundary.
    final lift = 11 + math.sin(cycle) * 11;
    final drift = math.sin(cycle * 2) * 4;
    final thrust = 0.7 + math.max(0, math.cos(cycle)) * 0.3;
    final blink =
        1 -
        (math.exp(-math.pow((phase - 0.32) / 0.018, 2)) +
                math.exp(-math.pow((phase - 0.78) / 0.018, 2))) *
            0.94;
    final waveEnvelope = math.pow(
      math.sin(((phase - 0.08) / 0.4).clamp(0.0, 1.0) * math.pi),
      2,
    );
    final wave = math.sin(cycle * 4) * waveEnvelope * (typing ? 0.2 : 1);

    void glow(Offset center, double radius, Color color, double alpha) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    void capsule(Rect rect, double radius, List<Color> colors) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ).createShader(rect),
      );
    }

    void stroke(Offset start, Offset end, Color color, double width) {
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    glow(const Offset(80, 78), 65, accent, 0.13);
    // Small stationary particles help show the flight path without moving UI.
    for (var i = 0; i < 3; i++) {
      final sparkle = Offset(24 + i * 29.0, 92 + (i.isEven ? 0 : 22));
      final shimmer = 0.15 + (math.sin(cycle + i * 2) + 1) * 0.12;
      stroke(
        sparkle - const Offset(0, 2.5),
        sparkle + const Offset(0, 2.5),
        led.withValues(alpha: shimmer),
        1.2,
      );
      stroke(
        sparkle - const Offset(2.5, 0),
        sparkle + const Offset(2.5, 0),
        led.withValues(alpha: shimmer),
        1.2,
      );
    }
    final shadowRect = Rect.fromCenter(
      center: const Offset(80, 158),
      width: 60 - lift * 1.15,
      height: 8 - lift * 0.12,
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0)],
        ).createShader(shadowRect),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(80, 158),
        width: 58 - lift * 0.6,
        height: 8,
      ),
      Paint()
        ..color = led.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    canvas.save();
    canvas.translate(drift + gaze * 0.8, -lift);
    canvas.translate(80, 93);
    canvas.rotate(math.sin(cycle) * 0.035 * (1 - cover));
    canvas.translate(-80, -93);

    // Translucent exhaust follows the robot; its ground shadow stays fixed.
    for (final x in [67.0, 93.0]) {
      final plume = Rect.fromLTWH(x - 8, 133, 16, 25 + thrust * 7);
      final trail = Path()
        ..moveTo(x - 5, 134)
        ..quadraticBezierTo(
          x - 10,
          146,
          x + math.sin(cycle * 2) * 2,
          plume.bottom,
        )
        ..quadraticBezierTo(x + 10, 146, x + 5, 134)
        ..close();
      canvas.drawPath(
        trail,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.9),
              led.withValues(alpha: 0.65 * thrust),
              led.withValues(alpha: 0),
            ],
            stops: const [0, 0.28, 1],
          ).createShader(plume),
      );
      glow(Offset(x, 135), 13, led, 0.4 * thrust);
      canvas.drawOval(
        Rect.fromLTWH(x - 2, 135, 4, 10 + thrust * 3),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }

    // Compact side boosters and stabilizer fins give the robot a flight rig.
    for (final x in [49.0, 101.0]) {
      capsule(Rect.fromLTWH(x, 95, 10, 28), 5, [deep, mid, accent]);
      stroke(Offset(x + 3, 102), Offset(x + 3, 113), led, 1.5);
    }
    for (final left in [true, false]) {
      final fin = Path()
        ..moveTo(left ? 54 : 106, 105)
        ..quadraticBezierTo(left ? 41 : 119, 110, left ? 38 : 122, 122)
        ..lineTo(left ? 55 : 105, 117)
        ..close();
      canvas.drawPath(fin, Paint()..color = mid.withValues(alpha: 0.8));
    }
    capsule(const Rect.fromLTWH(65, 88, 30, 13), 6, [mid, deep]);
    capsule(const Rect.fromLTWH(55, 94, 50, 37), 17, const [
      Colors.white,
      Color(0xFFE4ECF2),
      Color(0xFFB9CCD6),
    ]);
    capsule(const Rect.fromLTWH(61, 123, 16, 13), 6, [pearl, mid, deep]);
    capsule(const Rect.fromLTWH(84, 123, 16, 13), 6, [pearl, mid, deep]);
    stroke(const Offset(65, 134), const Offset(73, 134), led, 2.5);
    stroke(const Offset(88, 134), const Offset(96, 134), led, 2.5);
    capsule(const Rect.fromLTWH(65, 101, 30, 20), 8, [mid, pearl]);
    capsule(const Rect.fromLTWH(73, 104, 14, 6), 2, [accent, mid, deep]);
    canvas.drawCircle(const Offset(80, 117), 5, Paint()..color = deep);
    canvas.drawCircle(
      const Offset(79, 116),
      3.5,
      Paint()..color = const Color(0xFF455E6B),
    );
    for (final x in [58.5, 101.5]) {
      stroke(
        Offset(x, 103),
        Offset(x, 114),
        accent.withValues(alpha: 0.4),
        1.1,
      );
    }
    capsule(const Rect.fromLTWH(64, 124, 32, 3), 1.5, [mid, deep, mid]);

    // Short rounded helmet tabs, like the supplied white-and-cyan reference.
    for (final x in [58.0, 102.0]) {
      capsule(Rect.fromLTWH(x - 4, 20, 8, 13), 5, [pearl, mid, accent]);
      glow(Offset(x, 24), 8, led, 0.15);
    }
    capsule(const Rect.fromLTWH(29, 51, 17, 27), 9, [pearl, deep, accent]);
    capsule(const Rect.fromLTWH(114, 51, 17, 27), 9, [accent, deep, pearl]);
    stroke(const Offset(34, 58), const Offset(34, 66), led, 2);
    stroke(const Offset(125, 58), const Offset(125, 66), led, 2);
    final headRect = visor
        ? const Rect.fromLTWH(34, 28, 92, 72)
        : const Rect.fromLTWH(37, 26, 86, 75);
    final head = RRect.fromRectAndRadius(
      headRect,
      Radius.circular(visor ? 23 : 30),
    );
    canvas.drawRRect(
      head.shift(const Offset(0, 2)),
      Paint()..color = deep.withValues(alpha: 0.18),
    );
    capsule(headRect, visor ? 23 : 30, [pearl, mid, accent]);
    canvas.drawRRect(
      head.deflate(0.7),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    canvas.save();
    canvas.clipRRect(head);
    final sheen = Path()
      ..moveTo(40, 26)
      ..lineTo(93, 26)
      ..lineTo(65, 99)
      ..lineTo(26, 99)
      ..close();
    canvas.drawPath(
      sheen,
      Paint()..color = Colors.white.withValues(alpha: 0.13),
    );
    canvas.restore();
    final faceRect = visor
        ? const Rect.fromLTWH(40, 40, 80, 57)
        : const Rect.fromLTWH(43, 39, 74, 58);
    final face = RRect.fromRectAndRadius(
      faceRect,
      Radius.circular(visor ? 19 : 23),
    );
    capsule(faceRect, visor ? 19 : 23, const [
      Colors.white,
      Color(0xFFEAF0F4),
      Color(0xFFC5D2DB),
    ]);
    canvas.drawRRect(
      face,
      Paint()
        ..color = deep.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    final helmetShine = Path()
      ..moveTo(51, 34)
      ..quadraticBezierTo(72, 27, 101, 35);
    canvas.drawPath(
      helmetShine,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeCap = StrokeCap.round,
    );

    final glance =
        gaze * 2.5 + (typing || cover > 0 ? 0 : math.sin(cycle) * 1.1);
    for (final x in [64.0, 96.0]) {
      final eye = Rect.fromCenter(
        center: Offset(x, loading ? 65 : 67 + (typing ? 1 : 0)),
        width: 23,
        height: 27 * blink,
      );
      canvas.drawOval(
        eye.inflate(1.2),
        Paint()..color = deep.withValues(alpha: 0.18),
      );
      canvas.drawOval(
        eye,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.25, -0.3),
            radius: 0.85,
            colors: [Color(0xFF60D8EE), Color(0xFF24748F), Color(0xFF102F44)],
            stops: [0, 0.6, 1],
          ).createShader(eye),
      );
      if (blink > 0.15) {
        final pupil = Rect.fromCenter(
          center: eye.center + Offset(glance, 1),
          width: 15,
          height: 20 * blink,
        );
        canvas.drawOval(
          pupil,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF223746), Color(0xFF020A10)],
            ).createShader(pupil),
        );
        canvas.drawOval(
          eye.deflate(2),
          Paint()
            ..color = led.withValues(alpha: 0.45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.65,
        );
      }
      if (blink > 0.6) {
        canvas.drawOval(
          Rect.fromCenter(
            center: eye.center + Offset(3 + glance, -6),
            width: 6.5,
            height: 9,
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.7),
        );
        canvas.drawCircle(
          eye.center + Offset(-4 + glance, 5),
          2.2,
          Paint()..color = Colors.white,
        );
      }
      final eyebrow = Path()
        ..moveTo(x - 7, 48)
        ..quadraticBezierTo(x, loading ? 42 : 44, x + 6, 48);
      canvas.drawPath(
        eyebrow,
        Paint()
          ..color = deep.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..strokeCap = StrokeCap.round,
      );
    }
    final mouth = Path();
    if (loading) {
      mouth.addOval(const Rect.fromLTWH(77, 84, 6, 7));
    } else {
      mouth
        ..moveTo(71, 85)
        ..quadraticBezierTo(80, 90, 89, 85)
        ..quadraticBezierTo(80, 95, 71, 85)
        ..close();
    }
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF142A36));
    final left = Offset.lerp(
      const Offset(43, 108),
      const Offset(64, 67),
      cover,
    )!;
    final right = Offset.lerp(
      Offset(121 + wave * 4, 92 - waveEnvelope * 11 + wave * 6),
      Offset(peeking ? 108 : 96, peeking ? 86 : 67),
      cover,
    )!;
    for (final (shoulder, hand) in [
      (const Offset(58, 105), left),
      (const Offset(102, 105), right),
    ]) {
      stroke(shoulder, hand, deep, 10);
      stroke(
        shoulder - const Offset(0, 1),
        hand - const Offset(0, 1),
        pearl,
        7,
      );
      canvas.drawCircle(
        Offset.lerp(shoulder, hand, 0.5)!,
        4,
        Paint()..color = deep,
      );
      canvas.drawCircle(shoulder, 5, Paint()..color = accent);
      final palm = Rect.fromCenter(
        center: hand,
        width: 19 + cover * 6,
        height: 20 + cover * 9,
      );
      capsule(palm, 8, const [
        Color(0xFF667D8A),
        Color(0xFF354D5C),
        Color(0xFF223745),
      ]);
      canvas.drawCircle(hand + const Offset(-8, 1), 4, Paint()..color = deep);
      for (var finger = 0; finger < 3; finger++) {
        stroke(
          hand + Offset(-5.0 + finger * 5, -5),
          hand + Offset(-5.0 + finger * 5, -10),
          deep,
          3.5,
        );
      }
      stroke(
        hand + const Offset(-3, 3),
        hand + const Offset(4, 3),
        pearl.withValues(alpha: 0.7),
        1.3,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CharacterPainter oldDelegate) =>
      idle != oldDelegate.idle ||
      cover != oldDelegate.cover ||
      gaze != oldDelegate.gaze ||
      peeking != oldDelegate.peeking ||
      typing != oldDelegate.typing ||
      loading != oldDelegate.loading ||
      style != oldDelegate.style ||
      primary != oldDelegate.primary;
}
