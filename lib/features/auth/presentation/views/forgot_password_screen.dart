import '../../../../core/widgets/ios_scroll_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/liquid_glass_container.dart';
import '../../../../core/widgets/tracker_backdrop.dart';
import '../../../../core/widgets/primary_button.dart';
import '../view_models/recovery_state.dart';
import '../view_models/recovery_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_feedback_snackbar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpFocusNode = FocusNode();

  RecoveryState get _state => ref.read(recoveryViewModelProvider);
  RecoveryStep get _step => _state.step;
  bool get _isLoading => _state.isLoading;
  bool get _obscurePassword => _state.obscurePassword;
  bool get _obscureConfirmPassword => _state.obscureConfirmPassword;
  int get _resendSeconds => _state.resendSeconds;
  String get _email => _state.email;

  Future<void> _sendOtp({bool isResend = false}) async {
    FocusScope.of(context).unfocus();
    final sent = await ref
        .read(recoveryViewModelProvider.notifier)
        .sendOtp(_emailController.text, isResend: isResend);
    if (!mounted || !sent) return;
    _otpController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _step == RecoveryStep.otp) _otpFocusNode.requestFocus();
    });
  }

  Future<void> _resendOtp() => _sendOtp(isResend: true);

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    final verified = await ref
        .read(recoveryViewModelProvider.notifier)
        .verifyOtp(_otpController.text);
    if (!mounted || !verified) return;
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _updatePassword() async {
    FocusScope.of(context).unfocus();
    final updated = await ref
        .read(recoveryViewModelProvider.notifier)
        .updatePassword(
          _passwordController.text,
          _confirmPasswordController.text,
        );
    if (mounted && updated) _openSignIn();
  }

  void _openSignIn() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
  }

  Future<void> _handleBack() async {
    _otpFocusNode.unfocus();
    final result = await ref.read(recoveryViewModelProvider.notifier).goBack();
    if (!mounted) return;
    switch (result) {
      case RecoveryBackResult.stay:
        break;
      case RecoveryBackResult.pop:
        final didPop = await Navigator.of(context).maybePop();
        if (mounted && !didPop) _openSignIn();
      case RecoveryBackResult.signIn:
        _openSignIn();
    }
  }

  // ============================================
  // MODERN 6 DIGIT OTP BOXES
  // ============================================

  Widget _buildOtpBoxes() {
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          // --------------------------------------
          // VISUAL BOXES
          // --------------------------------------
          AnimatedBuilder(
            animation: _otpController,
            builder: (context, _) {
              final code = _otpController.text;

              final activeIndex = code.length >= 6 ? 5 : code.length;

              return Row(
                children: List.generate(6, (index) {
                  final hasValue = index < code.length;

                  final isActive = !_isLoading && index == activeIndex;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 5 ? 0 : 7),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        alignment: Alignment.center,

                        decoration: BoxDecoration(
                          color: isActive
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.09)
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,

                          borderRadius: BorderRadius.circular(14),

                          border: Border.all(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withValues(alpha: 0.25),
                            width: isActive ? 2 : 1,
                          ),

                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),

                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),

                          child: Text(
                            hasValue ? code[index] : '',
                            key: ValueKey(
                              '$index-${hasValue ? code[index] : ''}',
                            ),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // --------------------------------------
          // REAL INPUT FIELD
          // --------------------------------------
          Positioned.fill(
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              enabled: !_isLoading,

              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,

              autofillHints: const [AutofillHints.oneTimeCode],

              maxLength: 6,

              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],

              autocorrect: false,
              enableSuggestions: false,
              showCursor: false,
              cursorColor: Colors.transparent,

              style: const TextStyle(color: Colors.transparent, fontSize: 1),

              decoration: const InputDecoration(
                // The digits are painted by the boxes behind this input.
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STEP 1 UI: ENTER EMAIL
  // ============================================

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "Don't worry! Enter your registered email "
          "address and we'll send you a verification code.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 30),

        CustomTextField(
          label: 'Email Address',
          hint: 'example@gmail.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ),

        const SizedBox(height: 28),

        PrimaryButton(
          label: 'Send Verification Code',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _sendOtp,
        ),

        const SizedBox(height: 18),

        TextButton.icon(
          onPressed: _isLoading ? null : _handleBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Back to Sign In'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ============================================
  // STEP 2 UI: VERIFY OTP
  // ============================================

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TITLE
        Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Enter the 6-digit recovery code sent to',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 6),

        // EMAIL
        Text(
          _email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 32),

        // OTP BOXES
        _buildOtpBoxes(),

        const SizedBox(height: 24),

        // RESEND CODE
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              "Didn't receive the code?",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            TextButton(
              onPressed: _isLoading || _resendSeconds > 0 ? null : _resendOtp,

              child: Text(
                _resendSeconds > 0
                    ? 'Resend in ${_resendSeconds}s'
                    : 'Resend Code',

                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isLoading || _resendSeconds > 0
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // VERIFY BUTTON
        PrimaryButton(
          label: 'Verify Code',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _verifyOtp,
        ),

        const SizedBox(height: 20),

        // EMAIL HELP
        Container(
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Didn't get the email? Check your "
                  "Inbox or Spam folder.",
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // CHANGE EMAIL
        TextButton.icon(
          onPressed: _isLoading ? null : _handleBack,

          icon: const Icon(Icons.arrow_back_rounded, size: 18),

          label: const Text('Change Email Address'),

          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ============================================
  // STEP 3 UI: CREATE NEW PASSWORD
  // ============================================

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create New Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Your email is verified. '
          'Create a secure new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 30),

        // NEW PASSWORD
        CustomTextField(
          label: 'New Password',
          hint: '••••••••',
          controller: _passwordController,
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixTap: () {
            ref
                .read(recoveryViewModelProvider.notifier)
                .togglePasswordVisibility();
          },
        ),

        const SizedBox(height: 18),

        // CONFIRM PASSWORD
        CustomTextField(
          label: 'Confirm New Password',
          hint: '••••••••',
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icons.lock_reset_rounded,
          suffixIcon: _obscureConfirmPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixTap: () {
            ref
                .read(recoveryViewModelProvider.notifier)
                .toggleConfirmPasswordVisibility();
          },
        ),

        const SizedBox(height: 12),

        Text(
          'Password must be at least 8 characters.',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 28),

        // RESET PASSWORD
        PrimaryButton(
          label: 'Reset Password',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _updatePassword,
        ),

        const SizedBox(height: 18),

        TextButton(
          onPressed: _isLoading ? null : _handleBack,
          child: Text(
            'Cancel Recovery',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // MAIN BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    ref.watch(recoveryViewModelProvider);
    ref.listen(recoveryViewModelProvider.select((state) => state.feedback), (
      previous,
      next,
    ) {
      if (next != null) showAuthFeedback(context, next);
    });
    return PopScope(
      canPop: _step == RecoveryStep.email && !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_isLoading && _step != RecoveryStep.email) {
          _handleBack();
        }
      },

      child: AuthBackground(
        child: IosScrollPage(
          title: switch (_step) {
            RecoveryStep.email => 'Password recovery',
            RecoveryStep.otp => 'Verify recovery code',
            _ => 'Reset password',
          },
          onBack: _handleBack,
          backEnabled: !_isLoading,
          maxContentWidth: 460,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const TrackerCoinMark(size: 64),
              const SizedBox(height: 28),
              // Rounded form surface
              LiquidGlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ICON
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,

                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.12),

                          borderRadius: BorderRadius.circular(24),
                        ),

                        child: Icon(
                          _step == RecoveryStep.email
                              ? Icons.lock_reset_rounded
                              : _step == RecoveryStep.otp
                              ? Icons.mark_email_read_outlined
                              : Icons.shield_outlined,

                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ANIMATED SCREEN TRANSITIONS
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),

                      child: KeyedSubtree(
                        key: ValueKey(_step),

                        child: switch (_step) {
                          RecoveryStep.email => _buildEmailStep(),

                          RecoveryStep.otp => _buildOtpStep(),

                          RecoveryStep.password => _buildPasswordStep(),
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // DISPOSE
  // ============================================

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _otpFocusNode.dispose();

    super.dispose();
  }
}
