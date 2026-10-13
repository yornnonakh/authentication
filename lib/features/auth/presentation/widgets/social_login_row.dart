import 'package:flutter/material.dart';
import '../../../../core/theme/tracker_palette.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({
    super.key,
    this.onApple,
    this.onGoogle,
    this.onFacebook,
  });

  final VoidCallback? onApple;
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(icon: Icons.apple, onTap: onApple),
        const SizedBox(width: 16),
        _SocialButton(
          icon: Icons.g_mobiledata, // or use font_awesome / custom asset
          onTap: onGoogle,
          isGoogle: true,
        ),
        const SizedBox(width: 16),
        _SocialButton(
          icon: Icons.facebook,
          onTap: onFacebook,
          color: const Color(0xFF1877F2),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    this.onTap,
    this.color,
    this.isGoogle = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool isGoogle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border.all(
            color: TrackerPalette.coral.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: isGoogle ? 32 : 24,
          color: color ?? TrackerPalette.coral,
        ),
      ),
    );
  }
}
