
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_services.dart';
import '../widgets/auth_background.dart';
import 'sign_in_screen.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/liquid_glass_container.dart';
import '../../../core/widgets/primary_button.dart';

// ============================================
// RECOVERY STEPS
// ============================================

enum RecoveryStep {
  email,
  otp,
  password,
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  // ============================================
  // CONTROLLERS
  // ============================================

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _otpFocusNode = FocusNode();

  // ============================================
  // STATES
  // ============================================

  RecoveryStep _step = RecoveryStep.email;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  int _resendSeconds = 0;

  Timer? _resendTimer;

  String get _email =>
      _emailController.text.trim().toLowerCase();

  // ============================================
  // STEP 1: SEND RESET OTP
  // ============================================

  Future<void> _sendOtp() async {
    if (_isLoading) return;

    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!emailRegex.hasMatch(_email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.sendPasswordResetEmail(
        _email,
      );

      if (!mounted) return;

      _otpController.clear();

      setState(() {
        _step = RecoveryStep.otp;
      });

      _startResendTimer();

      _showMessage(
        'If an account exists for this email, '
        'a recovery code has been requested.',
        isError: false,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _step == RecoveryStep.otp) {
          _otpFocusNode.requestFocus();
        }
      });
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage(
        'Unable to send recovery code. Try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // RESEND OTP
  // ============================================

  Future<void> _resendOtp() async {
    if (_isLoading || _resendSeconds > 0) return;

    await _sendOtp();
  }

  // ============================================
  // RESEND COUNTDOWN
  // ============================================

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() => _resendSeconds = 60);

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_resendSeconds <= 1) {
          timer.cancel();

          setState(() {
            _resendSeconds = 0;
          });
        } else {
          setState(() {
            _resendSeconds--;
          });
        }
      },
    );
  }

  // ============================================
  // STEP 2: VERIFY OTP
  // ============================================

  Future<void> _verifyOtp() async {
    if (_isLoading) return;

    final code = _otpController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showMessage('Please enter a valid 6-digit code.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final response =
          await AuthService.instance.verifyRecoveryOtp(
        email: _email,
        token: code,
      );

      if (!mounted) return;

      final session = response.session ??
          Supabase.instance.client.auth.currentSession;

      if (session == null) {
        _showMessage(
          'Unable to establish a recovery session.',
        );
        return;
      }

      _resendTimer?.cancel();

      setState(() {
        _step = RecoveryStep.password;
        _resendSeconds = 0;
      });

      _showMessage(
        'Email verified successfully!',
        isError: false,
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage(
        'Invalid or expired code. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // STEP 3: UPDATE PASSWORD
  // ============================================

  Future<void> _updatePassword() async {
    if (_isLoading) return;

    final password = _passwordController.text;
    final confirmPassword =
        _confirmPasswordController.text;

    if (password.length < 8) {
      _showMessage(
        'Password must contain at least 8 characters.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    bool passwordUpdated = false;

    try {
      await AuthService.instance.updatePassword(
        newPassword: password,
      );

      passwordUpdated = true;

      // End the temporary recovery session.
      await AuthService.instance.signOut();

      if (!mounted) return;

      _openSignIn();
    } on AuthException catch (e) {
      _showMessage(
        passwordUpdated
            ? 'Password updated, but sign out failed: ${e.message}'
            : e.message,
      );
    } on FormatException catch (e) {
      _showMessage(e.message);
    } catch (_) {
      _showMessage(
        passwordUpdated
            ? 'Password updated, but sign out failed. '
              'Please try again.'
            : 'Unable to reset password. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ============================================
  // NAVIGATION
  // ============================================

  void _openSignIn() {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const SignInScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _handleBack() async {
    if (_isLoading) return;

    if (_step == RecoveryStep.password) {
      setState(() => _isLoading = true);

      try {
        await AuthService.instance.signOut();

        if (!mounted) return;

        _openSignIn();
      } on AuthException catch (e) {
        _showMessage(e.message);
      } catch (_) {
        _showMessage('Unable to end recovery session.');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }

      return;
    }

    if (_step == RecoveryStep.otp) {
      _otpFocusNode.unfocus();

      setState(() {
        _step = RecoveryStep.email;
      });

      return;
    }

    Navigator.of(context).maybePop();
  }

  // ============================================
  // SNACKBAR
  // ============================================

  void _showMessage(
    String message, {
    bool isError = true,
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Colors.redAccent
            : Colors.green.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
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
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // INPUT DECORATION
  // ============================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.65),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.25),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryOrange,
          width: 1.6,
        ),
      ),
    );
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

              final activeIndex =
                  code.length >= 6 ? 5 : code.length;

              return Row(
                children: List.generate(6, (index) {
                  final hasValue = index < code.length;

                  final isActive =
                      !_isLoading && index == activeIndex;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == 5 ? 0 : 7,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 200,
                        ),
                        curve: Curves.easeInOut,
                        alignment: Alignment.center,

                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryOrange
                                  .withValues(alpha: 0.09)
                              : Colors.white.withValues(
                                  alpha: 0.65,
                                ),

                          borderRadius:
                              BorderRadius.circular(14),

                          border: Border.all(
                            color: isActive
                                ? AppColors.primaryOrange
                                : Colors.grey.withValues(
                                    alpha: 0.25,
                                  ),
                            width: isActive ? 2 : 1,
                          ),

                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryOrange
                                            .withValues(
                                      alpha: 0.12,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(
                                      0,
                                      4,
                                    ),
                                  ),
                                ]
                              : [],
                        ),

                        child: AnimatedSwitcher(
                          duration: const Duration(
                            milliseconds: 150,
                          ),

                          child: Text(
                            hasValue ? code[index] : '',
                            key: ValueKey(
                              '$index-${hasValue ? code[index] : ''}',
                            ),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
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
          // An invisible text input over the boxes.
          // Handles keyboard, paste, and OTP autofill.
          Positioned.fill(
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              enabled: !_isLoading,

              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,

              autofillHints: const [
                AutofillHints.oneTimeCode,
              ],

              maxLength: 6,

              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],

              autocorrect: false,
              enableSuggestions: false,
              showCursor: false,
              cursorColor: Colors.transparent,

              style: const TextStyle(
                color: Colors.transparent,
                fontSize: 1,
              ),

              decoration: const InputDecoration(
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
        const Text(
          'Forgot Password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Don't worry! Enter your registered email "
          "address and we'll send you a verification code.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 30),

        TextField(
          controller: _emailController,
          enabled: !_isLoading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [
            AutofillHints.email,
          ],
          onSubmitted: (_) => _sendOtp(),

          decoration: _inputDecoration(
            label: 'Email Address',
            icon: Icons.email_outlined,
          ),
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
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 18,
          ),
          label: const Text('Back to Sign In'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryOrange,
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
        const Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Enter the 6-digit recovery code sent to',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 6),

        // EMAIL
        Text(
          _email,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
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
            const Text(
              "Didn't receive the code?",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            TextButton(
              onPressed: _isLoading || _resendSeconds > 0
                  ? null
                  : _resendOtp,

              child: Text(
                _resendSeconds > 0
                    ? 'Resend in ${_resendSeconds}s'
                    : 'Resend Code',

                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isLoading || _resendSeconds > 0
                      ? Colors.grey
                      : AppColors.primaryOrange,
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
            color: AppColors.primaryOrange
                .withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
          ),

          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryOrange,
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
                    color: AppColors.textSecondary,
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

          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 18,
          ),

          label: const Text(
            'Change Email Address',
          ),

          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryOrange,
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
        const Text(
          'Create New Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Your email is verified. '
          'Create a secure new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 30),

        // NEW PASSWORD
        TextField(
          controller: _passwordController,
          enabled: !_isLoading,
          obscureText: _obscurePassword,

          autofillHints: const [
            AutofillHints.newPassword,
          ],

          decoration: _inputDecoration(
            label: 'New Password',
            icon: Icons.lock_outline_rounded,

            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),

              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 18),

        // CONFIRM PASSWORD
        TextField(
          controller: _confirmPasswordController,
          enabled: !_isLoading,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,

          decoration: _inputDecoration(
            label: 'Confirm New Password',
            icon: Icons.lock_reset_rounded,

            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),

              onPressed: () {
                setState(() {
                  _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Password must be at least 8 characters.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 28),

        // RESET PASSWORD
        PrimaryButton(
          label: 'Reset Password',
          isLoading: _isLoading,
          onPressed: _isLoading
              ? null
              : _updatePassword,
        ),

        const SizedBox(height: 18),

        TextButton(
          onPressed: _isLoading ? null : _handleBack,
          child: const Text(
            'Cancel Recovery',
            style: TextStyle(
              color: AppColors.textSecondary,
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
    return PopScope(
      canPop: _step == RecoveryStep.email && !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop &&
            !_isLoading &&
            _step != RecoveryStep.email) {
          _handleBack();
        }
      },

      child: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),

              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 460,
                ),

                child: Column(
                  children: [

                    // BACK BUTTON
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed:
                            _isLoading ? null : _handleBack,

                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LIQUID GLASS CARD
                    LiquidGlassContainer(
                      child: Column(
                        children: [

                          // ICON
                          Container(
                            width: 76,
                            height: 76,

                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange
                                  .withValues(alpha: 0.12),

                              borderRadius:
                                  BorderRadius.circular(24),
                            ),

                            child: Icon(
                              _step == RecoveryStep.email
                                  ? Icons.lock_reset_rounded
                                  : _step == RecoveryStep.otp
                                      ? Icons.mark_email_read_outlined
                                      : Icons.shield_outlined,

                              size: 36,
                              color: AppColors.primaryOrange,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ANIMATED SCREEN TRANSITIONS
                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 250,
                            ),

                            child: KeyedSubtree(
                              key: ValueKey(_step),

                              child: switch (_step) {
                                RecoveryStep.email =>
                                  _buildEmailStep(),

                                RecoveryStep.otp =>
                                  _buildOtpStep(),

                                RecoveryStep.password =>
                                  _buildPasswordStep(),
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
    _resendTimer?.cancel();

    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _otpFocusNode.dispose();

    super.dispose();
  }
}
