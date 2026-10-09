import 'auth_feedback.dart';

class SignUpState {
  const SignUpState({
    this.obscurePassword = true,
    this.agreeTerms = false,
    this.isLoading = false,
    this.feedback,
  });

  final bool obscurePassword;
  final bool agreeTerms;
  final bool isLoading;
  final AuthFeedback? feedback;

  SignUpState copyWith({
    bool? obscurePassword,
    bool? agreeTerms,
    bool? isLoading,
    AuthFeedback? feedback,
  }) => SignUpState(
    obscurePassword: obscurePassword ?? this.obscurePassword,
    agreeTerms: agreeTerms ?? this.agreeTerms,
    isLoading: isLoading ?? this.isLoading,
    feedback: feedback ?? this.feedback,
  );
}
