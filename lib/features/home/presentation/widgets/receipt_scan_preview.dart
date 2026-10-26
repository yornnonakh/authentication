import 'package:flutter/material.dart';
import '../../../../core/theme/tracker_palette.dart';

class ReceiptScanPreview extends StatelessWidget {
  const ReceiptScanPreview({super.key, this.scanning = true});
  final bool scanning;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        SizedBox(
          height: 110,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.15, end: scanning ? 0.85 : 0.5),
            duration: scanning ? const Duration(seconds: 2) : Duration.zero,
            builder: (context, progress, child) => CustomPaint(
              painter: _BarcodePainter(
                progress: progress,
                color: Theme.of(context).colorScheme.onSurface,
                scanning: scanning,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          scanning ? 'Scanning mock receipt…' : 'Mock receipt preview',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter({
    required this.progress,
    required this.color,
    required this.scanning,
  });
  final double progress;
  final Color color;
  final bool scanning;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.62,
      height: 72,
    );
    final widths = [
      3.0,
      5.0,
      2.0,
      4.0,
      6.0,
      2.0,
      5.0,
      3.0,
      2.0,
      4.0,
      5.0,
      2.0,
      3.0,
    ];
    final total = widths.fold(0.0, (sum, width) => sum + width + 4);
    var x = rect.center.dx - total / 2;
    for (final width in widths) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, rect.top + 8, width, rect.height - 16),
          const Radius.circular(1.5),
        ),
        Paint()..color = color.withValues(alpha: 0.8),
      );
      x += width + 4;
    }
    final paint = Paint()
      ..color = TrackerPalette.pink
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      final dx = corner.dx == rect.left ? 12.0 : -12.0;
      final dy = corner.dy == rect.top ? 12.0 : -12.0;
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy),
        paint,
      );
    }
    if (scanning) {
      canvas.drawLine(
        Offset(rect.left + 6, rect.top + rect.height * progress),
        Offset(rect.right - 6, rect.top + rect.height * progress),
        Paint()
          ..color = TrackerPalette.coral
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.scanning != scanning;
}
