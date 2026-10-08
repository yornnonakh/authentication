import 'package:authentication/feature/auth/screen/forgot_password_screen.dart';
import 'package:authentication/feature/auth/services/auth_services.dart';
import 'package:authentication/feature/auth/widgets/auth_background.dart';
import 'package:authentication/feature/home/screen/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/liquid_glass_container.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/social_login_row.dart';

import 'sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthBackground(child: _SignInForm());
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  // ==========================================
  // CONTROLLERS
  // ==========================================

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ==========================================
  // SIGN IN
  // ==========================================

  Future<void> _handleSignIn() async {
    if (_isLoading) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter your email and password.');
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Please enter a valid email address.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      // Authenticate with Supabase.
      final response = await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Check authenticated session.
      final session =
          response.session ?? Supabase.instance.client.auth.currentSession;

      if (session == null) {
        _showSnackBar(
          'Unable to establish a session. '
          'Please verify your email and try again.',
        );
        return;
      }

      // ======================================
      // LOGIN SUCCESS -> HOME SCREEN
      // ======================================

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      if (e.message.toLowerCase().contains('email not confirmed')) {
        _showSnackBar('Please verify your email before signing in.');
      } else {
        _showSnackBar(e.message);
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================
  // SNACKBAR
  // ==========================================

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // BUILD UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                const SizedBox(height: 40),

                LiquidGlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================
                      // TITLE
                      // ==================================
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Hi! Welcome back, you've been missed",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================
                      // EMAIL FIELD
                      // ==================================
                      CustomTextField(
                        label: 'Email',
                        hint: 'example@mail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 18),

                      // ==================================
                      // PASSWORD FIELD
                      // ==================================
                      CustomTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onSuffixTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),

                      // ==================================
                      // FORGOT PASSWORD
                      // ==================================
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ==================================
                      // SIGN IN BUTTON
                      // ==================================
                      PrimaryButton(
                        label: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleSignIn,
                      ),

                      const SizedBox(height: 24),

                      // ==================================
                      // DIVIDER
                      // ==================================
                      Row(
                        children: [
                          const Expanded(child: Divider()),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or sign in with',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==================================
                      // SOCIAL LOGIN
                      // ==================================
                      SocialLoginRow(
                        onApple: () {
                          // TODO: Apple OAuth
                        },
                        onGoogle: () {
                          // TODO: Google OAuth
                        },
                        onFacebook: () {
                          // TODO: Facebook OAuth
                        },
                      ),

                      const SizedBox(height: 28),

                      // ==================================
                      // SIGN UP NAVIGATION
                      // ==================================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),

                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
