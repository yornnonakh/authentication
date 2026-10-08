// lib/features/home/screens/portfolio_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/investment_tile.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Portfolio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Donut Chart
                    SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(200, 200),
                            painter: _DonutPainter(),
                          ),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Balance',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$12505.58',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _LegendItem(color: AppColors.available, label: 'Available', value: '\$6150.00'),
                        _LegendItem(color: AppColors.bonds, label: 'Bonds', value: '\$3250.84'),
                        _LegendItem(color: AppColors.spent, label: 'Spent', value: '\$3103.66'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Your Investment Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Investment',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    // Investments
                    InvestmentTile(
                      logo: _LogoCircle(color: Colors.black, child: const Icon(Icons.apple, color: Colors.white, size: 22)),
                      name: 'Apple',
                      symbol: 'APPL',
                      amount: '\$157.54',
                      change: '+\$2.59 (5%)',
                      isPositive: true,
                    ),
                    InvestmentTile(
                      logo: _LogoCircle(color: const Color(0xFF003087), child: const Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      name: 'Paypal',
                      symbol: 'PPL',
                      amount: '\$427.54',
                      change: '-\$54.59 (2.5%)',
                      isPositive: false,
                    ),
                    InvestmentTile(
                      logo: _LogoCircle(color: const Color(0xFF1877F2), child: const Icon(Icons.facebook, color: Colors.white, size: 22)),
                      name: 'Facebook',
                      symbol: 'META',
                      amount: '\$14.54',
                      change: '+\$1.15 (1.5%)',
                      isPositive: true,
                    ),
                  ],
                ),
              ),
            ),

            AppBottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Helpers ----------

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const stroke = 28.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // Background circle
    paint.color = Colors.grey.shade200;
    canvas.drawCircle(center, radius - stroke / 2, paint);

    // Available (green) ~ 49%
    paint.color = AppColors.available;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      -1.57,
      3.0,
      false,
      paint,
    );

    // Bonds (pink) ~ 26%
    paint.color = AppColors.bonds;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      1.43,
      1.6,
      false,
      paint,
    );

    // Spent (yellow) ~ 25%
    paint.color = AppColors.spent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - stroke / 2),
      3.03,
      1.55,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}