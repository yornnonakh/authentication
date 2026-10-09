import 'auth_feedback.dart';

enum RecoveryStep { email, otp, password }

class RecoveryState {
  const RecoveryState({
    this.step = RecoveryStep.email,
    this.isLoading = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.resendSeconds = 0,
    this.email = '',
    this.feedback,
  });

  final RecoveryStep step;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final int resendSeconds;
  final String email;
  final AuthFeedback? feedback;

  RecoveryState copyWith({
    RecoveryStep? step,
    bool? isLoading,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    int? resendSeconds,
    String? email,
    AuthFeedback? feedback,
  }) => RecoveryState(
    step: step ?? this.step,
    isLoading: isLoading ?? this.isLoading,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    obscureConfirmPassword:
        obscureConfirmPassword ?? this.obscureConfirmPassword,
    resendSeconds: resendSeconds ?? this.resendSeconds,
    email: email ?? this.email,
    feedback: feedback ?? this.feedback,
  );
}
