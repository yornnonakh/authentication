import '../models/auth_event.dart';

abstract interface class AuthRepository {
  Stream<AuthEvent> get authStateChanges;

  /// Restores the SDK-persisted session and refreshes an expired access token.
  Future<bool> restoreSession();
  Future<bool> signInWithGoogle();

  /// Returns whether the request established an authenticated session.
  Future<bool> signIn({required String email, required String password});
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<bool> verifySignUpOtp({required String email, required String token});
  Future<void> resendSignUpOtp(String email);
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> verifyRecoveryOtp({
    required String email,
    required String token,
  });
  Future<void> updatePassword({required String newPassword});
  Future<void> signOut();
}
