import 'dart:async';

import 'package:authentication/feature/auth/services/auth_services.dart';
import 'package:authentication/feature/home/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/liquid_glass_container.dart';
import '../../../core/widgets/otp_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../widgets/auth_background.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(child: _VerifyCodeForm(email: email));
  }
}

class _VerifyCodeForm extends StatefulWidget {
  const _VerifyCodeForm({required this.email});

  final String email;

  @override
  State<_VerifyCodeForm> createState() => _VerifyCodeFormState();
}

class _VerifyCodeFormState extends State<_VerifyCodeForm> {
  String _otpCode = '';

  bool _isVerifying = false;
  bool _isResending = false;

  int _resendSeconds = 0;
  int _otpInputVersion = 0;

  Timer? _resendTimer;

  bool get _isLoading => _isVerifying || _isResending;

  // ============================================
  // VERIFY OTP
  // ============================================

  Future<void> _verifyOtp() async {
    if (_isLoading) return;

    final code = _otpCode.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _showSnackBar('Please enter your full 6-digit code.');
      return;
    }

    if (widget.email.trim().isEmpty) {
      _showSnackBar('Email address is missing.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await AuthService.instance.verifySignUpOtp(
        email: widget.email.trim().toLowerCase(),
        token: code,
      );

      if (!mounted) return;

      final session =
          response.session ?? Supabase.instance.client.auth.currentSession;

      if (session == null) {
        _showSnackBar(
          'Email verified. Please sign in to continue.',
          isError: false,
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      _showSnackBar(e.message);
    } on FormatException catch (e) {
      if (!mounted) return;

      _showSnackBar(e.message);
    } catch (_) {
      if (!mounted) return;

      _showSnackBar('Verification failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  // ============================================
  // RESEND OTP EMAIL
  // ============================================

  Future<void> _resendCode() async {
    if (_isLoading || _resendSeconds > 0) return;

    if (widget.email.trim().isEmpty) {
      _showSnackBar('Email address is missing.');
      return;
    }

    setState(() => _isResending = true);

    try {
      await AuthService.instance.resendSignUpOtp(
        widget.email.trim().toLowerCase(),
      );

      if (!mounted) return;

      // Clear the old OTP input.
      setState(() {
        _otpCode = '';
        _otpInputVersion++;
      });

      // Prevent rapid resend requests.
      _startResendCooldown();

      _showSnackBar(
        'New verification code requested. '
        'Check your inbox and spam folder.',
        isError: false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      _showSnackBar(e.message);
    } catch (_) {
      if (!mounted) return;

      _showSnackBar('Failed to resend code. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  // ============================================
  // RESEND COUNTDOWN
  // ============================================

  void _startResendCooldown() {
    _resendTimer?.cancel();

    setState(() => _resendSeconds = 60);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  // ============================================
  // SNACKBAR
  // ============================================

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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
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
    super.dispose();
  }

  // ============================================
  // BUILD UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                LiquidGlassContainer(
                  child: Column(
                    children: [
                      // Email Icon
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          color: AppColors.primaryOrange,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Heading
                      const Text(
                        'Verify Your Email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Enter the 6-digit verification code '
                        'we sent to your email address.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Email address
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // OTP Input
                      OtpInputField(
                        key: ValueKey(_otpInputVersion),
                        length: 6,
                        onCompleted: (code) {
                          _otpCode = code;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Resend Code
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
                                : _resendCode,
                            child: Text(
                              _isResending
                                  ? 'Sending...'
                                  : _resendSeconds > 0
                                  ? 'Resend in ${_resendSeconds}s'
                                  : 'Resend code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _isLoading || _resendSeconds > 0
                                    ? Colors.grey
                                    : AppColors.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Inbox / Spam message
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(
                            alpha: 0.07,
                          ),
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
                                'Can’t find the email? '
                                'Check your Spam or Junk folder. '
                                'If it is there, mark it as '
                                '"Not spam" to help future delivery.',
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

                      const SizedBox(height: 28),

                      // Verify Button
                      PrimaryButton(
                        label: 'Verify Email',
                        isLoading: _isVerifying,
                        onPressed: _isLoading ? null : _verifyOtp,
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
