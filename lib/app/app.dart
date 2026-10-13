import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_mode_provider.dart';
import 'app_routes.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: AppConstants.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.forBrightness(Brightness.light),
    darkTheme: AppTheme.forBrightness(Brightness.dark),
    themeMode: ref.watch(themeModeProvider),
    initialRoute: AppRoutes.splash,
    onGenerateRoute: AppRoutes.onGenerateRoute,
  );
}
