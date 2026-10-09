import 'package:flutter/material.dart';

import '../features/auth/presentation/views/forgot_password_screen.dart';
import '../features/auth/presentation/views/sign_in_screen.dart';
import '../features/auth/presentation/views/sign_up_screen.dart';
import '../features/auth/presentation/views/startup_screen.dart';
import '../features/auth/presentation/views/verify_code_screen.dart';
import '../features/home/presentation/views/dashboard_screen.dart';
import '../features/onboarding/presentation/views/onboarding_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String verifyCode = '/verify-code';
  static const String dashboard = '/dashboard';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const StartupScreen(),
        onboarding: (_) => const OnboardingScreen(),
        signIn: (_) => const SignInScreen(),
        signUp: (_) => const SignUpScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        dashboard: (_) => const DashboardScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == verifyCode) {
      final args = settings.arguments;
      final email = args is String
          ? args
          : (args is Map<String, dynamic> ? args['email'] as String? ?? '' : '');
      return MaterialPageRoute(
        builder: (_) => VerifyCodeScreen(email: email),
        settings: settings,
      );
    }
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }
}
