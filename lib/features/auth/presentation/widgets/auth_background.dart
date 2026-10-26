import 'package:flutter/material.dart';
import 'angkor_wat_backdrop.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({
    super.key,
    required this.child,
    this.isSignIn = false,
    this.showAngkor = false,
  });
  final Widget child;
  final bool isSignIn;
  final bool showAngkor;
  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: Stack(
      children: [
        if (showAngkor)
          Positioned.fill(child: AngkorWatBackdrop(isSignIn: isSignIn)),
        SafeArea(child: child),
      ],
    ),
  );
}
