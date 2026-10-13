import 'package:flutter/material.dart';
import 'tracker_palette.dart';

class AppColors {
  AppColors._();

  static const Color primaryOrange = TrackerPalette.coral;
  static const Color background = TrackerPalette.cream;
  static const Color textPrimary = TrackerPalette.ink;
  static const Color textSecondary = TrackerPalette.muted;
  static const Color border = Color(0xFFE5E5EA);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // New for FinSight
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color available = Color(0xFF34C759); // green
  static const Color bonds = Color(0xFFFF2D55); // pink
  static const Color spent = Color(0xFFFFCC00); // yellow
}
