import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../view_models/auth_feedback.dart';
import '../view_models/sign_in_state.dart';
import '../view_models/sign_in_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_character.dart';
import '../widgets/auth_form_page.dart';
import '../widgets/auth_feedback_snackbar.dart';
import '../widgets/social_login_row.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthBackground(
      isSignIn: true,
      showAngkor: true,
      child: _SignInForm(),
    );
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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  late final _characterActivity = Listenable.merge([
    _emailController,
    _emailFocus,
    _passwordFocus,
  ]);

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
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
  }

  void _showSnackBar(String message) =>
      showAuthFeedback(context, AuthFeedback(message));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
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
    final colors = Theme.of(context).colorScheme;
    return AuthFormPage(
      title: 'Welcome back',
      subtitle: 'A little clarity for your everyday spending.',
      character: AnimatedBuilder(
        animation: _characterActivity,
        builder: (context, child) => AuthCharacter(
          passwordFocused: _passwordFocus.hasFocus,
          passwordVisible: !_obscurePassword,
          isTyping: _emailFocus.hasFocus,
          lookProgress: _emailController.text.length / 28,
          isLoading: _isLoading,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                .read(signInViewModelProvider.notifier)
                .togglePasswordVisibility(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      ref
                          .read(signInViewModelProvider.notifier)
                          .cancelGoogleSignIn();
                      Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
                    },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Sign In',
            isLoading: _isEmailLoading,
            onPressed: _isLoading ? null : _handleSignIn,
          ),
          const SizedBox(height: 24),
          const AuthFormDivider(label: 'or continue with'),
          const SizedBox(height: 16),
          SocialLoginRow(
            onGoogle: _handleGoogleSignIn,
            onApple: () {
              if (!_isLoading) {
                _showSnackBar('Apple Sign-In is not configured yet.');
              }
            },
            onFacebook: () {
              if (!_isLoading) {
                _showSnackBar('Facebook Sign-In is not configured yet.');
              }
            },
          ),
          if (_isGoogleLaunching)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Opening Google...'),
            ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        ref
                            .read(signInViewModelProvider.notifier)
                            .cancelGoogleSignIn();
                        Navigator.of(context).pushNamed(AppRoutes.signUp);
                      },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
