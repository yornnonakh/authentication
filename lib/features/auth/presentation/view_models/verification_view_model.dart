import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_feedback.dart';
import 'auth_validation.dart';
import 'verification_state.dart';

enum VerificationResult { authenticated, needsSignIn }

final verificationViewModelProvider = NotifierProvider.autoDispose
    .family<VerificationViewModel, VerificationState, String>(
      VerificationViewModel.new,
    );

class VerificationViewModel extends Notifier<VerificationState> {
  VerificationViewModel(this.email);

  final String email;
  late AuthRepository _repository;
  Timer? _timer;

  @override
  VerificationState build() {
    _repository = ref.watch(authRepositoryProvider);
    ref.onDispose(() => _timer?.cancel());
    return const VerificationState();
  }

  void setCode(String code) => state = state.copyWith(otpCode: code);

  Future<VerificationResult?> verify() async {
    if (state.isLoading) return null;
    if (!AuthValidation.isOtp(state.otpCode)) {
      state = state.copyWith(
        feedback: AuthFeedback('Please enter your full 6-digit code.'),
      );
      return null;
    }
    if (email.trim().isEmpty) {
      state = state.copyWith(
        feedback: AuthFeedback('Email address is missing.'),
      );
      return null;
    }
    state = state.copyWith(isVerifying: true);
    try {
      final authenticated = await _repository.verifySignUpOtp(
        email: email,
        token: state.otpCode.trim(),
      );
      if (!ref.mounted) return null;
      return authenticated
          ? VerificationResult.authenticated
          : VerificationResult.needsSignIn;
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          feedback: AuthFeedback.fromError(
            error,
            'Verification failed. Please try again.',
          ),
        );
      }
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(isVerifying: false);
    }
  }

  Future<void> resend() async {
    if (state.isLoading || state.resendSeconds > 0) return;
    if (email.trim().isEmpty) {
      state = state.copyWith(
        feedback: AuthFeedback('Email address is missing.'),
      );
      return;
    }
    state = state.copyWith(isResending: true);
    try {
      await _repository.resendSignUpOtp(email);
      if (!ref.mounted) return;
      state = state.copyWith(
        otpCode: '',
        otpInputVersion: state.otpInputVersion + 1,
        feedback: AuthFeedback(
          'New verification code requested. Check your inbox and spam folder.',
          isError: false,
        ),
      );
      _startCooldown();
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          feedback: AuthFeedback.fromError(
            error,
            'Failed to resend code. Please try again.',
          ),
        );
      }
    } finally {
      if (ref.mounted) state = state.copyWith(isResending: false);
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
