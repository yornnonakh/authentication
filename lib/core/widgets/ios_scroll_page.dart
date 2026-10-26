import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shared iOS navigation for tab pages and pushed screens.
class IosSliverNavigationBar extends StatelessWidget {
  const IosSliverNavigationBar({
    super.key,
    required this.title,
    this.onBack,
    this.backLabel = 'Back',
    this.backEnabled = true,
    this.trailing,
    this.bottom,
    this.bottomMode,
  });
  final String title, backLabel;
  final VoidCallback? onBack;
  final bool backEnabled;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;
  final NavigationBarBottomMode? bottomMode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canGoBack = onBack != null || Navigator.of(context).canPop();
    return CupertinoSliverNavigationBar(
      automaticallyImplyLeading: false,
      transitionBetweenRoutes: false,
      stretch: true,
      backgroundColor: colors.surface.withValues(alpha: 0.92),
      border: Border(
        bottom: BorderSide(
          color: colors.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      largeTitle: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colors.onSurface),
      ),
      leading: canGoBack
          ? Tooltip(
              message: backLabel == 'Home' ? 'Back to home' : 'Back',
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: backEnabled
                    ? onBack ?? () => Navigator.of(context).maybePop()
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.back, size: 24),
                    const SizedBox(width: 3),
                    Text(backLabel, style: const TextStyle(fontSize: 17)),
                  ],
                ),
              ),
            )
          : null,
      trailing: trailing,
      bottom: bottom,
      bottomMode: bottomMode,
    );
  }
}

class IosScrollPage extends StatelessWidget {
  const IosScrollPage({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.backLabel = 'Back',
    this.backEnabled = true,
    this.trailing,
    this.bottom,
    this.bottomMode,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 28),
    this.maxContentWidth = double.infinity,
  });
  final String title, backLabel;
  final Widget child;
  final VoidCallback? onBack;
  final bool backEnabled;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;
  final NavigationBarBottomMode? bottomMode;
  final EdgeInsetsGeometry padding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    slivers: [
      IosSliverNavigationBar(
        title: title,
        onBack: onBack,
        backLabel: backLabel,
        backEnabled: backEnabled,
        trailing: trailing,
        bottom: bottom,
        bottomMode: bottomMode,
      ),
      SliverPadding(
        padding: padding,
        sliver: SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: child,
            ),
          ),
        ),
      ),
    ],
  );
}
