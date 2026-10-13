import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/liquid_glass_container.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/tracker_backdrop.dart';
import '../view_models/sign_up_state.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_feedback_snackbar.dart';
import '../widgets/social_login_row.dart';

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
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.verifyCode, arguments: email);
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
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            children: [
              const TrackerCoinMark(size: 64),
              const SizedBox(height: 28),
              LiquidGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Register',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you don’t have an account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 26),
                    CustomTextField(
                      label: 'Name',
                      hint: 'Full name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email',
                      hint: 'Email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: () => ref
                          .read(signUpViewModelProvider.notifier)
                          .togglePasswordVisibility(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          onChanged: _isLoading
                              ? null
                              : (value) => ref
                                    .read(signUpViewModelProvider.notifier)
                                    .setAgreeTerms(value ?? false),
                        ),
                        Expanded(
                          child: Text(
                            'Agree with Terms & Condition',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 190,
                        child: PrimaryButton(
                          label: 'Sign Up',
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _handleSignUp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Or sign up with',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 12),
              SocialLoginRow(),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Already a user?',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.signIn,
                            (route) => false,
                          ),
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
