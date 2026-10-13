import 'package:flutter/material.dart';

import 'tracker_backdrop.dart';

class FinsightBrand extends StatelessWidget {
  const FinsightBrand({super.key, this.markSize = 36, this.fontSize = 25});
  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      FinsightMark(size: markSize),
      const SizedBox(width: 8),
      Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Expense Tracker',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -.7,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    ],
  );
}

class FinsightMark extends StatelessWidget {
  const FinsightMark({super.key, this.size = 64});
  final double size;
  @override
  Widget build(BuildContext context) => TrackerCoinMark(size: size);
}
