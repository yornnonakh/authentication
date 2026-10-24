import 'package:flutter/material.dart';

import 'ai_dot_indicator.dart';
import 'app_motion.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: PressFeedback(
        enabled: !isLoading && onPressed != null,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            disabledBackgroundColor: colors.primary.withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
            elevation: 0,
            shape: const StadiumBorder(),
          ),
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 180),
            child: isLoading
                ? Semantics(
                    key: const ValueKey('loading'),
                    label: '$label, in progress',
                    liveRegion: true,
                    child: const AiDotIndicator(
                      color: Colors.white,
                      loop: true,
                    ),
                  )
                : Text(
                    label,
                    key: ValueKey(label),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
