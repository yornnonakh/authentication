import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/welcome_colors.dart';
import '../../domain/models/onboarding_page.dart';

class OnboardingArtwork extends StatelessWidget {
  const OnboardingArtwork({super.key, required this.illustration});
  final OnboardingIllustration illustration;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: MediaQuery.withNoTextScaling(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 360,
          height: 310,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _OrbitPainter()),
              ),
              Positioned(
                left: 28,
                top: 62,
                child: Transform.rotate(
                  angle: -.2,
                  child: Opacity(
                    opacity: illustration == OnboardingIllustration.security
                        ? .45
                        : 1,
                    child: const _DebitCard(),
                  ),
                ),
              ),
              if (illustration == OnboardingIllustration.growth)
                Positioned(
                  right: 4,
                  bottom: 5,
                  child: Container(
                    width: 154,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FBFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18345AA7),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your portfolio',
                          style: TextStyle(
                            fontSize: 11,
                            color: WelcomeColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              size: 20,
                              color: WelcomeColors.navy,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Keep growing',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: WelcomeColors.navy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(
                          height: 30,
                          width: double.infinity,
                          child: CustomPaint(painter: _GrowthPainter()),
                        ),
                      ],
                    ),
                  ),
                ),
              if (illustration == OnboardingIllustration.security)
                Positioned(
                  left: 115,
                  top: 102,
                  child: Container(
                    width: 130,
                    height: 148,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FBFF),
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x24325291),
                          blurRadius: 28,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          size: 92,
                          color: WelcomeColors.navy,
                        ),
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DebitCard extends StatelessWidget {
  const _DebitCard();
  @override
  Widget build(BuildContext context) => Container(
    width: 304,
    height: 192,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(21),
      gradient: const LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFF385895), Color(0xFF111F48)],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x334266AA),
          blurRadius: 24,
          offset: Offset(0, 18),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _CardShinePainter()),
          ),
          const Positioned(
            top: 24,
            left: 23,
            child: Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 23,
                letterSpacing: -.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE2E9FF),
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 22,
            child: Transform.rotate(
              angle: math.pi / 2,
              child: const Icon(
                Icons.contactless_outlined,
                color: Color(0xFFDEE7FF),
                size: 29,
              ),
            ),
          ),
          const Positioned(
            left: 24,
            top: 84,
            child: SizedBox(
              width: 39,
              height: 30,
              child: CustomPaint(painter: _ChipPainter()),
            ),
          ),
          const Positioned(
            left: 24,
            bottom: 24,
            child: Text(
              '••••  4821',
              style: TextStyle(
                color: Color(0xFFE1E8FF),
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
          const Positioned(
            right: 23,
            bottom: 19,
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * .52, size.height * .53);
    canvas.rotate(-.57);
    final oval = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 1.08,
      height: size.height * .65,
    );
    canvas.drawOval(
      oval,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFCAD9FF), Color(0xFFDCE7FF), Color(0xFFB6C9FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(oval),
    );
    final ribbon = Rect.fromCenter(
      center: Offset(24, size.height * .21),
      width: size.width * .67,
      height: size.height * .21,
    );
    canvas.drawOval(
      ribbon,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF839AFF), Color(0xFFC6D7FF), Color(0x00DDE7FF)],
        ).createShader(ribbon),
    );
    canvas.drawOval(
      oval.deflate(10),
      Paint()
        ..color = const Color(0x90FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    canvas.restore();
    canvas.drawCircle(
      Offset(size.width * .91, size.height * .18),
      3,
      Paint()..color = const Color(0xFF98B1F5),
    );
    canvas.drawCircle(
      Offset(size.width * .08, size.height * .63),
      2,
      Paint()..color = const Color(0xFF98B1F5),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}

class _CardShinePainter extends CustomPainter {
  const _CardShinePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, size.height * .24)
      ..quadraticBezierTo(
        size.width * .6,
        size.height * .48,
        size.width * .24,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0x40102043));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(21)),
      Paint()
        ..color = const Color(0x22FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(covariant _CardShinePainter oldDelegate) => false;
}

class _ChipPainter extends CustomPainter {
  const _ChipPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFECEADA), Color(0xFFB8C3D3), Color(0xFFEAF0F4)],
        ).createShader(rect),
    );
    final paint = Paint()
      ..color = const Color(0xFF8D9BAC)
      ..strokeWidth = .9
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(7), const Radius.circular(4)),
      paint,
    );
    for (final y in [.3, .7]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(7, size.height * y),
        paint,
      );
      canvas.drawLine(
        Offset(size.width - 7, size.height * y),
        Offset(size.width, size.height * y),
        paint,
      );
    }
    canvas.drawLine(
      Offset(size.width * .5, 0),
      Offset(size.width * .5, 7),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .5, size.height - 7),
      Offset(size.width * .5, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChipPainter oldDelegate) => false;
}

class _GrowthPainter extends CustomPainter {
  const _GrowthPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final line = Path()..moveTo(0, size.height * .9);
    const points = [
      Offset(.18, .66),
      Offset(.33, .8),
      Offset(.5, .4),
      Offset(.63, .55),
      Offset(.8, .18),
      Offset(1, .08),
    ];
    for (final point in points) {
      line.lineTo(point.dx * size.width, point.dy * size.height);
    }
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x555875F6), Color(0x005875F6)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = WelcomeColors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GrowthPainter oldDelegate) => false;
}
