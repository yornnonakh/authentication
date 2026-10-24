import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/tracker_palette.dart';
import '../../../../core/widgets/app_motion.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height:
          100 +
          (MediaQuery.textScalerOf(context).scale(12) - 12).clamp(0.0, 36.0) +
          MediaQuery.paddingOf(context).bottom,
      child: Stack(
        children: [
          Positioned.fill(
            top: 22,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  child: Row(
                    children: [
                      _destination(
                        context,
                        0,
                        'Home',
                        CupertinoIcons.house_fill,
                      ),
                      _destination(
                        context,
                        1,
                        'Report',
                        CupertinoIcons.chart_bar_alt_fill,
                      ),
                      const Expanded(child: SizedBox()),
                      _destination(
                        context,
                        2,
                        'Plan',
                        CupertinoIcons.square_stack_3d_up_fill,
                      ),
                      _destination(
                        context,
                        3,
                        'Settings',
                        CupertinoIcons.gear_alt_fill,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Tooltip(
              message: 'Add transaction',
              child: Semantics(
                button: true,
                enabled: onAdd != null,
                label: 'Add transaction',
                child: PressFeedback(
                  enabled: onAdd != null,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFC4A2FF), TrackerPalette.purple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: TrackerPalette.purple.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onAdd,
                        child: Icon(
                          CupertinoIcons.plus,
                          size: 28,
                          color: Colors.white.withValues(
                            alpha: onAdd == null ? 0.4 : 1,
                          ),
                        ),
                      ),
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

  Widget _destination(
    BuildContext context,
    int index,
    String label,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    final selected = currentIndex == index;
    final color = selected ? colors.primary : colors.onSurfaceVariant;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: PressFeedback(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onTap(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: selected ? 1 : 0),
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Transform.translate(
                      offset: Offset(0, -2 * value),
                      child: Transform.rotate(
                        angle: math.sin(value * math.pi) * 0.12,
                        child: Transform.scale(
                          scale: 1 + value * 0.12,
                          child: child,
                        ),
                      ),
                    ),
                    child: AnimatedContainer(
                      duration: duration,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.primary.withValues(alpha: 0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                  ),
                  const SizedBox(height: 7),
                  FittedBox(
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      child: Text(label),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
