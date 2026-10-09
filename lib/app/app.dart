import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../features/auth/presentation/views/startup_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      home: const StartupScreen(),
    );
  }
}
