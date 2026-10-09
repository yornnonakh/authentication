import 'package:flutter/material.dart';

import '../../../../core/theme/welcome_colors.dart';
import '../../../../core/widgets/finsight_brand.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    this.errorMessage,
    this.onRetry,
    this.onSignIn,
  });
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: WelcomeColors.background,
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6F8FF),
            WelcomeColors.background,
            Color(0xFFDDE9FF),
          ],
        ),
      ),
      child: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FinsightMark(size: 84),
                      const SizedBox(height: 22),
                      const Text(
                        'FinSight',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1.5,
                          color: WelcomeColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Clarity for your money.',
                        style: TextStyle(
                          fontSize: 16,
                          color: WelcomeColors.muted,
                        ),
                      ),
                      const SizedBox(height: 36),
                      if (errorMessage == null)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: WelcomeColors.navy,
                          ),
                        )
                      else ...[
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: WelcomeColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: WelcomeColors.navy,
                          ),
                          onPressed: onRetry,
                          child: const Text('Try again'),
                        ),
                        TextButton(
                          onPressed: onSignIn,
                          child: const Text('Go to sign in'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Text(
                  'YOUR MONEY. MORE POSSIBILITIES.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: WelcomeColors.muted,
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
