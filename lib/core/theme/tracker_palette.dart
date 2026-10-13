import 'package:flutter/material.dart';

/// Shared iOS system colors. Legacy names remain for existing artwork.
abstract final class TrackerPalette {
  static const accent = Color(0xFF007AFF);
  static const blue = accent;
  static const coral = accent;
  static const peach = Color(0xFFEAF2FF);
  static const cream = Color(0xFFF2F2F7);
  static const slate = cream;
  static const ink = Color(0xFF1C1C1E);
  static const muted = Color(0xFF8E8E93);
  static const panel = Color(0xFFF2F2F7);
  static const green = Color(0xFF248A3D);
  static const pink = Color(0xFFAF52DE);
  static const lavender = Color(0xFFAF52DE);
  static const cyan = Color(0xFF32ADE6);
  static Color backdrop(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color header(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color onBackdrop(BuildContext context) => Theme.of(context).colorScheme.onSurface;
}
