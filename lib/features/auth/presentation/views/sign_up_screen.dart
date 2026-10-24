import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../view_models/sign_up_state.dart';
import '../view_models/sign_up_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_character.dart';
import '../widgets/auth_form_page.dart';
import '../widgets/auth_feedback_snackbar.dart';
import '../widgets/social_login_row.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthBackground(showAngkor: true, child: _SignUpForm());
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
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  late final _characterActivity = Listenable.merge([
    _nameController,
    _emailController,
    _nameFocus,
    _emailFocus,
    _passwordFocus,
  ]);
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
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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
    return AuthFormPage(
      title: 'Create your account',
      subtitle: 'Start building better money habits.',
      character: AnimatedBuilder(
        animation: _characterActivity,
        builder: (context, child) => AuthCharacter(
          style: AuthCharacterStyle.visor,
          passwordFocused: _passwordFocus.hasFocus,
          passwordVisible: !_obscurePassword,
          isTyping: _nameFocus.hasFocus || _emailFocus.hasFocus,
          lookProgress:
              (_nameFocus.hasFocus
                  ? _nameController.text.length
                  : _emailController.text.length) /
              28,
          isLoading: _isLoading,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Name',
            hint: 'Full name',
            prefixIcon: Icons.person_outline_rounded,
            controller: _nameController,
            focusNode: _nameFocus,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _emailController,
            focusNode: _emailFocus,
            focusedBottomSpace: 184,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Password',
            hint: 'Password',
            prefixIcon: Icons.lock_outline_rounded,
            controller: _passwordController,
            focusNode: _passwordFocus,
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
                  'I agree to the Terms & Conditions',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Sign Up',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleSignUp,
          ),
          const SizedBox(height: 20),
          const AuthFormDivider(label: 'or sign up with'),
          const SizedBox(height: 12),
          SocialLoginRow(),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
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
    );
  }
}
