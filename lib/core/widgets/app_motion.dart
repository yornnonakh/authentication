import 'package:flutter/material.dart';

/// Replays an entrance when a retained dashboard page becomes active.
class AppEntrance extends StatefulWidget {
  const AppEntrance({super.key, required this.child, this.active = true});

  final Widget child;
  final bool active;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final _offset = Tween(
    begin: const Offset(0, 0.025),
    end: Offset.zero,
  ).animate(_curve);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate();
  }

  @override
  void didUpdateWidget(AppEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) _animate();
  }

  void _animate() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (widget.active) {
      _controller.forward();
    } else {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(position: _offset, child: widget.child),
  );
}

/// Adds a small tactile response while the child owns taps and semantics.
class PressFeedback extends StatefulWidget {
  const PressFeedback({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
    onPointerUp: (_) => _setPressed(false),
    onPointerCancel: (_) => _setPressed(false),
    child: AnimatedScale(
      scale:
          _pressed && widget.enabled && !MediaQuery.disableAnimationsOf(context)
          ? 0.96
          : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}
