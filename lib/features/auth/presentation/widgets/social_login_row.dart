import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          icon: Icons.g_mobiledata,
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
    final colors = Theme.of(context).colorScheme;
    final iconColor = color ?? colors.onSurface;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surfaceContainerLow,
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.2),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: isGoogle ? 32 : 24,
          color: iconColor,
        ),
      ),
    );
  }
}
