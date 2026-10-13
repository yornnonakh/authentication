import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'tracker_palette.dart';

abstract final class AppTheme {
  static ThemeData forBrightness(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final primary = dark ? const Color(0xFF0A84FF) : TrackerPalette.accent;
    final background = dark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final card = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final fill = dark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final text = dark ? const Color(0xFFF5F5F7) : const Color(0xFF1C1C1E);
    final secondary = dark ? const Color(0xFF98989D) : const Color(0xFF636366);
    final separator = dark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
    final scheme = ColorScheme.fromSeed(seedColor: primary,brightness: brightness).copyWith(
      primary: primary,onPrimary: Colors.white,
      primaryContainer: dark ? const Color(0xFF12283F) : const Color(0xFFEAF2FF),onPrimaryContainer: primary,
      secondary: primary,surface: background,surfaceContainerLowest: card,surfaceContainerLow: card,
      surfaceContainer: fill,surfaceContainerHigh: fill,surfaceContainerHighest: separator,
      onSurface: text,onSurfaceVariant: secondary,outline: separator,outlineVariant: separator,
      error: dark ? const Color(0xFFFF453A) : const Color(0xFFD70015),
    );
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    return ThemeData(
      useMaterial3: true,platform: TargetPlatform.iOS,brightness: brightness,colorScheme: scheme,
      typography: Typography.material2021(platform: TargetPlatform.iOS),
      cupertinoOverrideTheme: CupertinoThemeData(brightness: brightness,primaryColor: primary,
        scaffoldBackgroundColor: background,barBackgroundColor: card),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(backgroundColor: background,foregroundColor: text,centerTitle: true,
        elevation: 0,scrolledUnderElevation: 0,surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: text,fontSize: 17,fontWeight: FontWeight.w600)),
      cardTheme: CardThemeData(elevation: 0,color: card,surfaceTintColor: Colors.transparent,shape: rounded),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,fillColor: fill,labelStyle: TextStyle(color: secondary,fontSize: 15),
        hintStyle: TextStyle(color: secondary.withValues(alpha: 0.7),fontSize: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(color: primary,width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16)),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(backgroundColor: primary,foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600),minimumSize: const Size(120,50),
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 14),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primary,foregroundColor: Colors.white,
        elevation: 0,minimumSize: const Size(120,50),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: primary,side: BorderSide(color: separator),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primary,textStyle: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500))),
      chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),side: BorderSide.none,
        backgroundColor: fill,selectedColor: scheme.primaryContainer,labelStyle: TextStyle(fontSize: 13,color: text)),
      searchBarTheme: SearchBarThemeData(backgroundColor: WidgetStatePropertyAll(fill),elevation: const WidgetStatePropertyAll(0),
        side: const WidgetStatePropertyAll(BorderSide.none),shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      sliderTheme: SliderThemeData(activeTrackColor: primary,thumbColor: primary,inactiveTrackColor: separator,trackHeight: 3),
      dividerTheme: DividerThemeData(color: separator,thickness: 0.5),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      dialogTheme: DialogThemeData(backgroundColor: card,shape: rounded),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: background,surfaceTintColor: Colors.transparent,showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)))),
    );
  }
}
