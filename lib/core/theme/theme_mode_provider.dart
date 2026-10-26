import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeViewModel, ThemeMode>(
  ThemeModeViewModel.new,
);

class ThemeModeViewModel extends Notifier<ThemeMode> {
  int _version = 0;
  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final version = _version;
    try {
      final name = await SharedPreferencesAsync().getString(
        'finsight.theme.mode',
      );
      if (ref.mounted && version == _version && name != null) {
        state = ThemeMode.values.firstWhere(
          (m) => m.name == name,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {
      /* System appearance is the fallback when preferences are unavailable. */
    }
  }

  Future<bool> select(ThemeMode mode) async {
    _version++;
    state = mode;
    try {
      await SharedPreferencesAsync().setString(
        'finsight.theme.mode',
        mode.name,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
