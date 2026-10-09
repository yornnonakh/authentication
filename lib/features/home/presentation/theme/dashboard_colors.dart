import 'package:flutter/material.dart';

class DashboardColors {
  DashboardColors._();

  static const ink = Color(0xFF151B28);
  static const muted = Color(0xFF777D87);
  static const available = Color(0xFF79DEAC);
  static const bonds = Color(0xFFFFA5B9);
  static const spent = Color(0xFFFFDF83);
  static const positive = Color(0xFF46AF83);
  static const negative = Color(0xFFE18A98);
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3F2FB), Color(0xFFFCF7F5), Color(0xFFEFFAFF)],
    stops: [0, 0.57, 1],
  );
}
