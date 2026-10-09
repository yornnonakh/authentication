import 'auth_feedback.dart';

class VerificationState {
  const VerificationState({
    this.otpCode = '',
    this.isVerifying = false,
    this.isResending = false,
    this.resendSeconds = 0,
    this.otpInputVersion = 0,
    this.feedback,
  });

  final String otpCode;
  final bool isVerifying;
  final bool isResending;
  final int resendSeconds;
  final int otpInputVersion;
  final AuthFeedback? feedback;

  bool get isLoading => isVerifying || isResending;

  VerificationState copyWith({
    String? otpCode,
    bool? isVerifying,
    bool? isResending,
    int? resendSeconds,
    int? otpInputVersion,
    AuthFeedback? feedback,
  }) => VerificationState(
    otpCode: otpCode ?? this.otpCode,
    isVerifying: isVerifying ?? this.isVerifying,
    isResending: isResending ?? this.isResending,
    resendSeconds: resendSeconds ?? this.resendSeconds,
    otpInputVersion: otpInputVersion ?? this.otpInputVersion,
    feedback: feedback ?? this.feedback,
  );
}
