import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key,required this.child,this.isSignIn = false});
  final Widget child;
  final bool isSignIn;
  @override
  Widget build(BuildContext context) => Scaffold(resizeToAvoidBottomInset: true,
    backgroundColor: Theme.of(context).colorScheme.surface,body: SafeArea(child: child));
}
