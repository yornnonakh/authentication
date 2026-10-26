import 'package:flutter/material.dart';

abstract final class TrackerPalette {
  static const accent = Color(0xFF9865F8);
  static const purple = accent;
  static const blue = Color(0xFF219CF3);
  static const coral = Color(0xFFFF7053);
  static const peach = Color(0xFFFFA08C);
  static const pink = Color(0xFFFF94C2);
  static const mint = Color(0xFF80DFC2);
  static const cream = Color(0xFFFFFFFF);
  static const slate = Color(0xFFF8F8FA);
  static const ink = Color(0xFF1C1D22);
  static const muted = Color(0xFF858589);
  static const panel = Color(0xFFFFFFFF);
  static const green = Color(0xFF80DFC2);
  static const cyan = Color(0xFF70D6FF);

  static Color backdrop(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1A1C23)
      : slate;

  static Color header(BuildContext context) => backdrop(context);

  static Color onBackdrop(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
}
