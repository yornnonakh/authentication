import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_feedback.dart';
import 'auth_validation.dart';
import 'recovery_state.dart';

enum RecoveryBackResult { stay, pop, signIn }

final recoveryViewModelProvider =
    NotifierProvider.autoDispose<RecoveryViewModel, RecoveryState>(
      RecoveryViewModel.new,
    );

class RecoveryViewModel extends Notifier<RecoveryState> {
  late AuthRepository _repository;
  Timer? _timer;

  @override
  RecoveryState build() {
    _repository = ref.watch(authRepositoryProvider);
    ref.onDispose(() => _timer?.cancel());
    return const RecoveryState();
  }

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  void toggleConfirmPasswordVisibility() => state = state.copyWith(
    obscureConfirmPassword: !state.obscureConfirmPassword,
  );

  Future<bool> sendOtp(String email, {bool isResend = false}) async {
    if (state.isLoading || state.step == RecoveryStep.password) return false;
    if (isResend &&
        (state.step != RecoveryStep.otp || state.resendSeconds > 0)) {
      return false;
    }
    email = isResend ? state.email : AuthValidation.normalizeEmail(email);
    if (!AuthValidation.isEmail(email)) {
      state = state.copyWith(
        feedback: AuthFeedback('Please enter a valid email address.'),
      );
      return false;
    }
    state = state.copyWith(isLoading: true);
    try {
      await _repository.sendPasswordResetEmail(email);
      if (!ref.mounted) return false;
      state = state.copyWith(
        step: RecoveryStep.otp,
        email: email,
        feedback: AuthFeedback(
          'If an account exists for this email, a recovery code has been requested.',
          isError: false,
        ),
      );
      _startCooldown();
      return true;
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          feedback: AuthFeedback.fromError(
            error,
            'Unable to send recovery code. Try again.',
          ),
        );
      }
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (state.isLoading || state.step != RecoveryStep.otp) return false;
    if (!AuthValidation.isOtp(code)) {
      state = state.copyWith(
        feedback: AuthFeedback('Please enter a valid 6-digit code.'),
      );
      return false;
    }
    state = state.copyWith(isLoading: true);
    try {
      final hasSession = await _repository.verifyRecoveryOtp(
        email: state.email,
        token: code.trim(),
      );
      if (!ref.mounted) return false;
      if (!hasSession) {
        state = state.copyWith(
          feedback: AuthFeedback('Unable to establish a recovery session.'),
        );
        return false;
      }
      _timer?.cancel();
      state = state.copyWith(step: RecoveryStep.password, resendSeconds: 0);
      return true;
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          feedback: AuthFeedback.fromError(
            error,
            'Invalid or expired code. Please try again.',
          ),
        );
      }
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> updatePassword(String password, String confirmation) async {
    if (state.isLoading || state.step != RecoveryStep.password) return false;
    final error =
        AuthValidation.passwordError(password) ??
        (password != confirmation ? 'Passwords do not match.' : null);
    if (error != null) {
      state = state.copyWith(feedback: AuthFeedback(error));
      return false;
    }
    state = state.copyWith(isLoading: true);
    var updated = false;
    try {
      await _repository.updatePassword(newPassword: password);
      updated = true;
      // Always end a successfully updated recovery session, even if the view closed.
      await _repository.signOut();
      return ref.mounted;
    } catch (error) {
      if (ref.mounted) {
        final feedback = AuthFeedback.fromError(error, 'Please try again.');
        state = state.copyWith(
          feedback: AuthFeedback(
            updated
                ? 'Password updated, but sign out failed: ${feedback.message}'
                : AuthFeedback.fromError(
                    error,
                    'Unable to reset password. Please try again.',
                  ).message,
          ),
        );
      }
      return false;
    } finally {
      if (ref.mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<RecoveryBackResult> goBack() async {
    if (state.isLoading) return RecoveryBackResult.stay;
    if (state.step == RecoveryStep.otp) {
      _timer?.cancel();
      state = state.copyWith(step: RecoveryStep.email, resendSeconds: 0);
      return RecoveryBackResult.stay;
    }
    if (state.step == RecoveryStep.email) return RecoveryBackResult.pop;
    state = state.copyWith(isLoading: true);
    try {
      await _repository.signOut();
      return ref.mounted ? RecoveryBackResult.signIn : RecoveryBackResult.stay;
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          feedback: AuthFeedback.fromError(
            error,
            'Unable to end recovery session.',
          ),
        );
      }
      return RecoveryBackResult.stay;
    } finally {
      if (ref.mounted) state = state.copyWith(isLoading: false);
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    state = state.copyWith(resendSeconds: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted) {
        timer.cancel();
        return;
      }
      final remaining = state.resendSeconds - 1;
      if (remaining <= 0) timer.cancel();
      state = state.copyWith(resendSeconds: remaining);
    });
  }
}
