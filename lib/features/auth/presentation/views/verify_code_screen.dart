import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/liquid_glass_container.dart';
import '../../../../core/widgets/tracker_backdrop.dart';
import '../../../../core/widgets/primary_button.dart';
import '../view_models/auth_feedback.dart';
import '../view_models/verification_view_model.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_feedback_snackbar.dart';
import '../widgets/otp_input_field.dart';

class VerifyCodeScreen extends StatelessWidget {
  const VerifyCodeScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(child: _VerifyCodeForm(email: email));
  }
}

class _VerifyCodeForm extends ConsumerWidget {
  const _VerifyCodeForm({required this.email});
  final String email;

  Future<void> _verify(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    final result = await ref
        .read(verificationViewModelProvider(email).notifier)
        .verify();
    if (!context.mounted || result == null) return;
    final authenticated = result == VerificationResult.authenticated;
    Navigator.of(context).pushNamedAndRemoveUntil(
      authenticated ? AppRoutes.dashboard : AppRoutes.signIn,
      (route) => false,
    );
    if (!authenticated && context.mounted) {
      showAuthFeedback(
        context,
        const AuthFeedback(
          'Email verified. Please sign in to continue.',
          isError: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = verificationViewModelProvider(email);
    final state = ref.watch(provider);
    final viewModel = ref.read(provider.notifier);
    ref.listen(provider.select((state) => state.feedback), (previous, next) {
      if (next != null) showAuthFeedback(context, next);
    });
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
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const Center(child: TrackerCoinMark(size: 64)),
                const SizedBox(height: 28),

                LiquidGlassContainer(
                  child: Column(
                    children: [
                      // Email Icon
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.mark_email_unread_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Heading
                      Text(
                        'Verify Your Email',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Enter the 6-digit verification code '
                        'we sent to your email address.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Email address
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // OTP Input
                      OtpInputField(
                        key: ValueKey(state.otpInputVersion),
                        length: 6,
                        onChanged: (code) {
                          viewModel.setCode(code);
                        },
                      ),

                      const SizedBox(height: 20),

                      // Resend Code
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            "Didn't receive the code?",
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed:
                                state.isLoading || state.resendSeconds > 0
                                ? null
                                : viewModel.resend,
                            child: Text(
                              state.isResending
                                  ? 'Sending...'
                                  : state.resendSeconds > 0
                                  ? 'Resend in ${state.resendSeconds}s'
                                  : 'Resend code',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color:
                                    state.isLoading || state.resendSeconds > 0
                                    ? Colors.grey
                                    : Theme.of(context).colorScheme.primary,
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
                                'Can’t find the email? '
                                'Check your Spam or Junk folder. '
                                'If it is there, mark it as '
                                '"Not spam" to help future delivery.',
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
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
                        isLoading: state.isVerifying,
                        onPressed: state.isLoading
                            ? null
                            : () => _verify(context, ref),
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
