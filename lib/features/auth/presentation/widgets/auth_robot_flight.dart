import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enters from below a card, then follows screen touches and text carets.
/// The parent supplies the complete card bounds through a positioned fill.
class AuthRobotFlight extends StatefulWidget {
  const AuthRobotFlight({
    super.key,
    required this.child,
    this.target,
    this.belowField,
    this.homeAlignment = Alignment.topCenter,
  });

  final Widget child;

  /// Screen coordinates of a touch or the active text caret.
  final ValueListenable<Offset?>? target;

  /// A focused field whose bottom edge the robot should hover beneath.
  final ValueListenable<Rect?>? belowField;
  final Alignment homeAlignment;

  @override
  State<AuthRobotFlight> createState() => _AuthRobotFlightState();
}

class _AuthRobotFlightState extends State<AuthRobotFlight>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );
  late final _flight = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );
  final _boundsKey = GlobalKey();
  final _characterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.target?.addListener(_followTarget);
    widget.belowField?.addListener(_followTarget);
  }

  @override
  void didUpdateWidget(AuthRobotFlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      oldWidget.target?.removeListener(_followTarget);
      widget.target?.addListener(_followTarget);
    }
    if (oldWidget.belowField != widget.belowField) {
      oldWidget.belowField?.removeListener(_followTarget);
      widget.belowField?.addListener(_followTarget);
    }
  }

  void _followTarget() {
    if (!mounted) return;
    if (widget.target?.value != null || widget.belowField?.value != null) {
      _controller.value = 1;
    }
    setState(() {});
  }

  Offset _destination(BoxConstraints constraints) {
    final target = widget.target?.value;
    final bounds = _boundsKey.currentContext?.findRenderObject();
    final character = _characterKey.currentContext?.findRenderObject();
    if (target == null ||
        bounds is! RenderBox ||
        !bounds.hasSize ||
        character is! RenderBox ||
        !character.hasSize) {
      return Offset.zero;
    }
    final local = bounds.globalToLocal(target);
    final room = math.max(
      0.0,
      (constraints.maxWidth - character.size.width) / 2 - 8,
    );
    final homeY =
        (constraints.maxHeight - character.size.height) *
        (widget.homeAlignment.y + 1) /
        2;
    final belowField = widget.belowField?.value;
    final top = belowField == null
        ? local.dy - character.size.height - 18
        : bounds.globalToLocal(Offset(target.dx, belowField.bottom + 12)).dy;
    return Offset(
      (local.dx - constraints.maxWidth / 2).clamp(-room, room),
      top.clamp(
            0.0,
            math.max(0.0, constraints.maxHeight - character.size.height),
          ) -
          homeY,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        widget.target?.value != null) {
      _controller.value = 1;
    } else if (!_controller.isCompleted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    widget.target?.removeListener(_followTarget);
    widget.belowField?.removeListener(_followTarget);
    _flight.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ClipRect(
      child: LayoutBuilder(
        key: _boundsKey,
        builder: (context, constraints) => TweenAnimationBuilder<Offset>(
          tween: Tween(end: _destination(constraints)),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          child: Align(
            alignment: widget.homeAlignment,
            child: KeyedSubtree(key: _characterKey, child: widget.child),
          ),
          builder: (context, destination, child) => AnimatedBuilder(
            animation: _flight,
            child: child,
            builder: (context, child) {
              final progress = _flight.value;
              return Transform.translate(
                offset:
                    destination +
                    Offset(
                      math.sin(progress * math.pi) * 18,
                      (1 - progress) *
                          (widget.homeAlignment == Alignment.bottomCenter
                              ? 160
                              : constraints.maxHeight),
                    ),
                child: child,
              );
            },
          ),
        ),
      ),
    ),
  );
}
