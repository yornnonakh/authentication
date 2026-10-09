import '../../domain/models/auth_event.dart';

class AuthFeedback {
  const AuthFeedback(this.message, {this.isError = true});

  final String message;
  final bool isError;

  static AuthFeedback fromError(Object error, String fallback) =>
      AuthFeedback(error is AuthFailure ? error.message : fallback);
}
