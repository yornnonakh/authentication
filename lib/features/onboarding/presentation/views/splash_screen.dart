import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/widgets/finsight_brand.dart';

class SplashScreen extends StatefulWidget {
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
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _ambient = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorMessage != widget.errorMessage) _updateMotion();
  }

  void _updateMotion() {
    if (_reduceMotion) {
      _entrance.value = 1;
    } else {
      _entrance.forward();
    }

    if (_reduceMotion || widget.errorMessage != null) {
      _ambient.stop();
      _ambient.value = 0;
    } else if (!_ambient.isAnimating) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  Widget _reveal({
    required double start,
    required Widget child,
    double distance = 16,
  }) {
    final progress = _entrance.drive(
      CurveTween(curve: Interval(start, 1, curve: Curves.easeOutCubic)),
    );
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) => Opacity(
        opacity: progress.value,
        child: Transform.translate(
          offset: Offset(0, distance * (1 - progress.value)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final safePadding = MediaQuery.paddingOf(context);
    final compact = MediaQuery.sizeOf(context).height < 700;
    final status = widget.errorMessage == null
        ? _SplashLoading(animation: _ambient)
        : _buildRecovery(colors);
    final revealedStatus = _reveal(
      start: 0.36,
      child: _reduceMotion
          ? status
          : AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              child: status,
            ),
    );
    final brand = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _reveal(
            start: 0,
            distance: 24,
            child: SizedBox.square(
              dimension: compact ? 128 : 184,
              child: FittedBox(child: _SplashEmblem(animation: _ambient)),
            ),
          ),
          SizedBox(height: compact ? 20 : 28),
          _reveal(
            start: 0.12,
            child: Text(
              'Expense Tracker',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.3,
                height: 1.15,
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          _reveal(
            start: 0.24,
            child: Text(
              'Clarity for your money.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    colors.primary.withValues(alpha: dark ? 0.12 : 0.07),
                    colors.surface.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              // Equal top and bottom insets keep the brand at the screen midpoint.
              minimum: EdgeInsets.symmetric(
                vertical: math.max(safePadding.top, safePadding.bottom),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: widget.errorMessage == null
                                ? (compact ? 112 : 176)
                                : 88,
                          ),
                          child: widget.errorMessage == null
                              ? Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    brand,
                                    // Loading sits below the centered brand.
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: FractionalTranslation(
                                        translation: const Offset(0, 1),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: compact ? 24 : 44,
                                          ),
                                          child: revealedStatus,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 360,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      brand,
                                      const SizedBox(height: 44),
                                      revealedStatus,
                                    ],
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 28,
                          right: 28,
                          child: _reveal(
                            start: 0.45,
                            distance: 8,
                            child: Text(
                              'YOUR MONEY. MORE POSSIBILITIES.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.7,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecovery(ColorScheme colors) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            widget.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurface, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: widget.onRetry, child: const Text('Try again')),
        const SizedBox(height: 4),
        TextButton(
          onPressed: widget.onSignIn,
          child: const Text('Go to sign in'),
        ),
      ],
    ),
  );
}

class _SplashEmblem extends StatelessWidget {
  const _SplashEmblem({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.22),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const FinsightMark(size: 88),
      ),
      builder: (context, child) {
        final breathe = (1 - math.cos(animation.value * 2 * math.pi)) / 2;
        return SizedBox.square(
          dimension: 184,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ExcludeSemantics(
                child: Transform.scale(
                  scale: 1 + breathe * 0.035,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.045),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -4 * breathe),
                child: child,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Getting things ready',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 12,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final wave =
                        (1 +
                            math.sin(
                              animation.value * 2 * math.pi - index * 0.9,
                            )) /
                        2;
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.primary.withValues(
                          alpha: 0.25 + wave * 0.65,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Getting things ready',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
