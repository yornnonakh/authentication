import 'package:authentication/features/auth/presentation/views/verify_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/liquid_glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../home/presentation/views/dashboard_screen.dart';
import '../view_models/sign_up_state.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_feedback_snackbar.dart';
import '../widgets/social_login_row.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthBackground(child: _SignUpForm());
  }
}

class _SignUpForm extends ConsumerStatefulWidget {
  const _SignUpForm();
  @override
  ConsumerState<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<_SignUpForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  SignUpState get _state => ref.read(signUpViewModelProvider);
  bool get _obscurePassword => _state.obscurePassword;
  bool get _agreeTerms => _state.agreeTerms;
  bool get _isLoading => _state.isLoading;

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim().toLowerCase();
    final result = await ref
        .read(signUpViewModelProvider.notifier)
        .signUp(
          name: _nameController.text,
          email: email,
          password: _passwordController.text,
        );
    if (!mounted || result == null) return;
    if (result == SignUpResult.authenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: email)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(signUpViewModelProvider);
    ref.listen(signUpViewModelProvider.select((state) => state.feedback), (
      previous,
      next,
    ) {
      if (next != null) showAuthFeedback(context, next);
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          LiquidGlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill your information below or register\nwith your social account.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Name
                CustomTextField(
                  label: 'Name',
                  hint: 'Esther Howard',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  label: 'Email',
                  hint: 'example@gmail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password
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
                        .read(signUpViewModelProvider.notifier)
                        .togglePasswordVisibility();
                  },
                ),
                const SizedBox(height: 12),

                // Terms Checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeTerms,
                        activeColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (v) {
                          ref
                              .read(signUpViewModelProvider.notifier)
                              .setAgreeTerms(v ?? false);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          children: const [
                            TextSpan(text: 'Agree with '),
                            TextSpan(
                              text: 'Terms & Condition',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign Up Button
                PrimaryButton(
                  label: 'Sign Up',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : () => _handleSignUp(),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Or sign up with',
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

                // Social Login
                SocialLoginRow(
                  onApple: () {},
                  onGoogle: () {},
                  onFacebook: () {},
                ),
                const SizedBox(height: 24),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign In',
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
    );
  }
}
