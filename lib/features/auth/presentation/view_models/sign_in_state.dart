import 'auth_feedback.dart';

class SignInState {
  const SignInState({
    this.obscurePassword = true,
    this.isEmailLoading = false,
    this.isGoogleLaunching = false,
    this.waitingForGoogle = false,
    this.authenticated = false,
    this.feedback,
  });

  final bool obscurePassword;
  final bool isEmailLoading;
  final bool isGoogleLaunching;
  final bool waitingForGoogle;
  final bool authenticated;
  final AuthFeedback? feedback;

  bool get isLoading => isEmailLoading || isGoogleLaunching;

  SignInState copyWith({
    bool? obscurePassword,
    bool? isEmailLoading,
    bool? isGoogleLaunching,
    bool? waitingForGoogle,
    bool? authenticated,
    AuthFeedback? feedback,
  }) => SignInState(
    obscurePassword: obscurePassword ?? this.obscurePassword,
    isEmailLoading: isEmailLoading ?? this.isEmailLoading,
    isGoogleLaunching: isGoogleLaunching ?? this.isGoogleLaunching,
    waitingForGoogle: waitingForGoogle ?? this.waitingForGoogle,
    authenticated: authenticated ?? this.authenticated,
    feedback: feedback ?? this.feedback,
  );
}
