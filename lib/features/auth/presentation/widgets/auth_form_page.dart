import 'package:flutter/material.dart';

import '../../../../core/widgets/liquid_glass_container.dart';
import 'auth_robot_flight.dart';

/// An open authentication layout with a glass form and a robot underneath.
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
  final _emailBounds = ValueNotifier<Rect?>(null);
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
    if (editable?.widget.keyboardType != TextInputType.emailAddress) {
      _emailBounds.value = null;
    }
    _followCaretEnabled = editable != null;
    _queueCaret();
  }

  void _textChanged() {
    _followCaretEnabled = true;
    _queueCaret();
  }

  void _followTouch(Offset position) {
    _followCaretEnabled = _emailBounds.value?.contains(position) ?? false;
    if (!_followCaretEnabled) _emailBounds.value = null;
    _target.value = position;
    if (_followCaretEnabled) _queueCaret();
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
      Rect? emailBounds;
      if (editable.widget.keyboardType == TextInputType.emailAddress) {
        editable.context.visitAncestorElements((element) {
          if (element.widget is! TextField) return true;
          final field = element.findRenderObject();
          if (field is RenderBox && field.attached && field.hasSize) {
            emailBounds = field.localToGlobal(Offset.zero) & field.size;
          }
          return false;
        });
      }
      _emailBounds.value = emailBounds;
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
    _emailBounds.dispose();
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
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _queueCaret();
            return false;
          },
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
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
                          Stack(
                            children: [
                              Padding(
                                // Keep a separate hover area beneath the glass form.
                                padding: const EdgeInsets.only(bottom: 168),
                                child: LiquidGlassContainer(
                                  borderRadius: 28,
                                  blur: 24,
                                  opacity: 0.36,
                                  padding: const EdgeInsets.all(22),
                                  child: widget.child,
                                ),
                              ),
                              Positioned.fill(
                                child: AuthRobotFlight(
                                  target: _target,
                                  belowField: _emailBounds,
                                  homeAlignment: Alignment.bottomCenter,
                                  child: SizedBox(
                                    height: 160,
                                    child: FittedBox(child: widget.character),
                                  ),
                                ),
                              ),
                            ],
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
