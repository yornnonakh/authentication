import 'package:flutter/material.dart';

import '../../../../core/widgets/liquid_glass_container.dart';
import 'auth_robot_flight.dart';

/// A full-screen authentication layout with a fixed robot above a scrolling form.
class AuthFormPage extends StatefulWidget {
  const AuthFormPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.character,
    required this.child,
  });

  final String title, subtitle;
  final Widget character, child;

  @override
  State<AuthFormPage> createState() => _AuthFormPageState();
}

class _AuthFormPageState extends State<AuthFormPage>
    with WidgetsBindingObserver {
  final _target = ValueNotifier<Offset?>(null);
  TextEditingController? _activeController;
  bool _caretQueued = false;
  bool _followCaretEnabled = false;

  EditableTextState? get _focusedEditable {
    final editable = FocusManager.instance.primaryFocus?.context
        ?.findAncestorStateOfType<EditableTextState>();
    return editable?.context.findAncestorStateOfType<_AuthFormPageState>() ==
            this
        ? editable
        : null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_focusChanged);
  }

  @override
  void didChangeMetrics() => _queueCaret();

  void _focusChanged() {
    _activeController?.removeListener(_textChanged);
    final editable = _focusedEditable;
    _activeController = editable?.widget.controller;
    _activeController?.addListener(_textChanged);
    _followCaretEnabled = editable != null;
    if (editable == null) _target.value = null;
    _queueCaret();
  }

  void _textChanged() {
    _followCaretEnabled = true;
    _queueCaret();
  }

  void _followTouch(Offset position) {
    _followCaretEnabled = false;
    _target.value = position;
  }

  void _queueCaret() {
    if (!mounted || _caretQueued || !_followCaretEnabled) return;
    _caretQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caretQueued = false;
      if (!mounted || !_followCaretEnabled) return;
      final editable = _focusedEditable;
      if (editable == null || !editable.mounted) return;
      final selection = editable.widget.controller.selection;
      final render = editable.renderEditable;
      if (!selection.isValid || !render.attached || !render.hasSize) return;
      final caret = render.getLocalRectForCaret(selection.extent);
      _target.value = render.localToGlobal(caret.center);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_focusChanged);
    _activeController?.removeListener(_textChanged);
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _followTouch(event.position),
      onPointerMove: (event) => _followTouch(event.position),
      child: MouseRegion(
        onHover: (event) => _followTouch(event.position),
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              // Reserve a header outside the scroll viewport. Shrink it when
              // the keyboard opens so the form still has room on small screens.
              SizedBox(
                height: (constraints.maxHeight * 0.28)
                    .clamp(0.0, 184.0)
                    .toDouble(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: AuthRobotFlight(
                        target: _target,
                        homeAlignment: Alignment.topCenter,
                        child: SizedBox(
                          height: 160,
                          child: FittedBox(child: widget.character),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    _queueCaret();
                    return false;
                  },
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Column(
                                children: [
                                  Text(
                                    widget.title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.subtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  LiquidGlassContainer(
                                    borderRadius: 28,
                                    blur: 24,
                                    opacity: 0.36,
                                    padding: const EdgeInsets.all(22),
                                    child: widget.child,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthFormDivider extends StatelessWidget {
  const AuthFormDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Expanded(
        flex: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      ),
      const Expanded(child: Divider()),
    ],
  );
}
