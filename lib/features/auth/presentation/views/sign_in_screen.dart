import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/liquid_glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../view_models/auth_feedback.dart';
import '../view_models/sign_in_state.dart';
import '../view_models/sign_in_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_feedback_snackbar.dart';
import '../widgets/social_login_row.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthBackground(child: _SignInForm());
  }
}

class _SignInForm extends ConsumerStatefulWidget {
  const _SignInForm();

  @override
  ConsumerState<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends ConsumerState<_SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  SignInState get _state => ref.read(signInViewModelProvider);
  bool get _obscurePassword => _state.obscurePassword;
  bool get _isLoading => _state.isLoading;
  bool get _isEmailLoading => _state.isEmailLoading;
  bool get _isGoogleLaunching => _state.isGoogleLaunching;

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    await ref
        .read(signInViewModelProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();
    await ref.read(signInViewModelProvider.notifier).signInWithGoogle();
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  void _showSnackBar(String message) =>
      showAuthFeedback(context, AuthFeedback(message));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(signInViewModelProvider);
    ref.listen(signInViewModelProvider, (previous, next) {
      if (next.feedback != null && next.feedback != previous?.feedback) {
        showAuthFeedback(context, next.feedback!);
      }
      if (next.authenticated && previous?.authenticated != true) {
        _navigateToHome();
      }
    });
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
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Sign in to continue to Expense Tracker',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ==================================
                      // EMAIL INPUT
                      // ==================================
                      CustomTextField(
                        label: 'Email',
                        hint: 'example@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 18),

                      // ==================================
                      // PASSWORD INPUT
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
                          ref
                              .read(signInViewModelProvider.notifier)
                              .togglePasswordVisibility();
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
                                  ref
                                      .read(signInViewModelProvider.notifier)
                                      .cancelGoogleSignIn();

                                  Navigator.of(context).pushNamed(
                                    AppRoutes.forgotPassword,
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
                      // EMAIL SIGN IN BUTTON
                      // ==================================
                      PrimaryButton(
                        label: 'Sign In',
                        isLoading: _isEmailLoading,
                        onPressed: _isLoading ? null : _handleSignIn,
                      ),

                      const SizedBox(height: 26),

                      // ==================================
                      // DIVIDER
                      // ==================================
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ==================================
                      // SOCIAL LOGIN BUTTONS
                      // ==================================
                      SocialLoginRow(
                        onGoogle: _handleGoogleSignIn,

                        onApple: () {
                          if (_isLoading) return;

                          _showSnackBar('Apple Sign-In is not configured yet.');
                        },

                        onFacebook: () {
                          if (_isLoading) return;

                          _showSnackBar(
                            'Facebook Sign-In is not configured yet.',
                          );
                        },
                      ),

                      if (_isGoogleLaunching) ...[
                        const SizedBox(height: 16),

                        const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Opening Google...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),

                      // ==================================
                      // SIGN UP
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
                                    ref
                                        .read(signInViewModelProvider.notifier)
                                        .cancelGoogleSignIn();

                                    Navigator.of(context).pushNamed(
                                      AppRoutes.signUp,
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
