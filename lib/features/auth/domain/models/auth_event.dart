enum AuthEventType { signedIn, signedOut, passwordRecovery, other }

class AuthEvent {
  const AuthEvent(this.type, {required this.hasSession});

  final AuthEventType type;
  final bool hasSession;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}
