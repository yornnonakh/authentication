import 'package:flutter/material.dart';

abstract final class TrackerPalette {
  static const accent = Color(0xFF9381FF);
  static const purple = Color(0xFF9381FF);
  static const blue = accent;
  static const coral = accent;
  static const peach = Color(0xFFFFA08C);
  static const pink = Color(0xFFFF94C2);
  static const mint = Color(0xFF80DFC2);
  static const cream = Color(0xFFFFFFFF);
  static const slate = Color(0xFF5D6578);
  static const ink = Color(0xFF1C1D22);
  static const muted = Color(0xFF8E92A0);
  static const panel = Color(0xFFFFFFFF);
  static const green = Color(0xFF80DFC2);
  static const cyan = Color(0xFF70D6FF);

  static Color backdrop(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1C23)
          : const Color(0xFF5D6578);

  static Color header(BuildContext context) => backdrop(context);

  static Color onBackdrop(BuildContext context) => Colors.white;
}
