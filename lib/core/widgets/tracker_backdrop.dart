import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrackerBackdrop extends StatelessWidget {
  const TrackerBackdrop({super.key,required this.child,this.headerHeight = 220});
  final Widget child;
  final double headerHeight;
  @override
  Widget build(BuildContext context) => ColoredBox(color: Theme.of(context).colorScheme.surface,child: child);
}
class TrackerCoinMark extends StatelessWidget {
  const TrackerCoinMark({super.key,this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(label: 'Expense Tracker',image: true,child: Container(
    width: size,height: size,decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,borderRadius: BorderRadius.circular(size * 0.23)),
    child: Icon(CupertinoIcons.creditcard,color: Colors.white,size: size * 0.55),
  ));
}
