import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A scalable Angkor Wat illustration, kept behind the authentication content.
class AngkorWatBackdrop extends StatelessWidget {
  const AngkorWatBackdrop({super.key, this.isSignIn = true});

  final bool isSignIn;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _AngkorPainter(
            dark: Theme.of(context).brightness == Brightness.dark,
            isSignIn: isSignIn,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}

class _AngkorPainter extends CustomPainter {
  const _AngkorPainter({required this.dark, required this.isSignIn});

  final bool dark, isSignIn;

  @override
  void paint(Canvas canvas, Size size) {
    final base = dark ? const Color(0xFF171B27) : const Color(0xFFFAF9FE);
    final sky = dark
        ? const Color(0xFF2C2948)
        : isSignIn
        ? const Color(0xFFEAE2FC)
        : const Color(0xFFDFF1EC);
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final sceneHeight = math.min(size.height, 490.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, sceneHeight),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky, base],
          stops: const [0.05, 1],
        ).createShader(Rect.fromLTWH(0, 0, size.width, sceneHeight)),
    );

    // Keep the temple at the same visual scale on phones and wide windows.
    final scale = (size.width / 440).clamp(0.7, 1.35);
    canvas.save();
    canvas.translate(size.width / 2, 68);
    canvas.scale(scale);
    canvas.translate(-220, 0);
    final stone = dark
        ? const Color(0xFF8981AC)
        : isSignIn
        ? const Color(0xFFACA0CA)
        : const Color(0xFF89B8AF);
    final fill = Paint()..color = stone.withValues(alpha: dark ? 0.16 : 0.22);
    final detail = Paint()
      ..color = stone.withValues(alpha: dark ? 0.25 : 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(
      const Offset(267, 61),
      47,
      Paint()
        ..color = const Color(0xFFF4D6B3).withValues(alpha: dark ? 0.1 : 0.4),
    );

    void temple() {
      // Long galleries, raised plinths, and five stepped lotus towers.
      canvas.drawRect(const Rect.fromLTWH(36, 172, 368, 14), fill);
      canvas.drawRect(const Rect.fromLTWH(49, 160, 342, 12), fill);
      final gallery = Path()
        ..moveTo(53, 160)
        ..lineTo(63, 147)
        ..lineTo(377, 147)
        ..lineTo(387, 160)
        ..close();
      canvas.drawPath(gallery, fill);
      canvas.drawPath(gallery, detail);
      for (var i = 0; i < 25; i++) {
        canvas.drawLine(
          Offset(65 + i * 13, 161),
          Offset(65 + i * 13, 171),
          detail,
        );
      }

      void tower(double x, double top, double width) {
        final height = 166 - top;
        final outline = Path()
          ..moveTo(x - width * 0.56, 166)
          ..lineTo(x - width * 0.56, top + height * 0.76)
          ..lineTo(x - width * 0.45, top + height * 0.76)
          ..lineTo(x - width * 0.45, top + height * 0.62)
          ..lineTo(x - width * 0.38, top + height * 0.59)
          ..lineTo(x - width * 0.4, top + height * 0.52)
          ..lineTo(x - width * 0.29, top + height * 0.49)
          ..lineTo(x - width * 0.31, top + height * 0.4)
          ..lineTo(x - width * 0.22, top + height * 0.37)
          ..lineTo(x - width * 0.24, top + height * 0.29)
          ..lineTo(x - width * 0.15, top + height * 0.24)
          ..quadraticBezierTo(x - width * 0.15, top + 7, x, top)
          ..quadraticBezierTo(
            x + width * 0.15,
            top + 7,
            x + width * 0.15,
            top + height * 0.24,
          )
          ..lineTo(x + width * 0.24, top + height * 0.29)
          ..lineTo(x + width * 0.22, top + height * 0.37)
          ..lineTo(x + width * 0.31, top + height * 0.4)
          ..lineTo(x + width * 0.29, top + height * 0.49)
          ..lineTo(x + width * 0.4, top + height * 0.52)
          ..lineTo(x + width * 0.38, top + height * 0.59)
          ..lineTo(x + width * 0.45, top + height * 0.62)
          ..lineTo(x + width * 0.45, top + height * 0.76)
          ..lineTo(x + width * 0.56, top + height * 0.76)
          ..lineTo(x + width * 0.56, 166)
          ..close();
        canvas.drawPath(outline, fill);
        canvas.drawPath(outline, detail);
        for (final level in [0.4, 0.52, 0.64, 0.78]) {
          final y = top + height * level;
          final halfWidth = width * (0.1 + level * 0.42);
          canvas.drawLine(
            Offset(x - halfWidth, y),
            Offset(x + halfWidth, y),
            detail,
          );
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 4, 143, 8, 23),
            const Radius.circular(4),
          ),
          Paint()..color = stone.withValues(alpha: 0.18),
        );
      }

      tower(94, 94, 35);
      tower(346, 94, 35);
      tower(158, 67, 42);
      tower(282, 67, 42);
      tower(220, 27, 52);
      for (var i = 0; i < 3; i++) {
        canvas.drawLine(
          Offset(30 - i * 6, 186 + i * 5),
          Offset(410 + i * 6, 186 + i * 5),
          detail,
        );
      }
    }

    temple();
    canvas.saveLayer(
      const Rect.fromLTWH(0, 202, 440, 130),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );
    canvas.translate(0, 341.5);
    canvas.scale(1, -0.75);
    temple();
    canvas.restore();
    for (var i = 0; i < 7; i++) {
      final y = 211.0 + i * 11;
      canvas.drawLine(
        Offset(40 + i * 8, y),
        Offset(400 - i * 8, y),
        Paint()
          ..color = base.withValues(alpha: 0.65)
          ..strokeWidth = 4,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AngkorPainter oldDelegate) =>
      oldDelegate.dark != dark || oldDelegate.isSignIn != isSignIn;
}
