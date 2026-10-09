import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/auth_event.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  // Must match the platform callbacks and Supabase redirect allowlist.
  static const googleRedirectUrl = 'com.finsight.auth://login-callback/';

  GoTrueClient get _auth => _client.auth;

  Future<T> _request<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on AuthException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  bool _hasSession(AuthResponse response) =>
      (response.session ?? _auth.currentSession) != null;

  @override
  Stream<AuthEvent> get authStateChanges => _auth.onAuthStateChange
      .map(
        (state) => AuthEvent(switch (state.event) {
          AuthChangeEvent.signedIn => AuthEventType.signedIn,
          AuthChangeEvent.signedOut => AuthEventType.signedOut,
          AuthChangeEvent.passwordRecovery => AuthEventType.passwordRecovery,
          _ => AuthEventType.other,
        }, hasSession: state.session != null),
      )
      .handleError((Object error) {
        if (error is AuthException) throw AuthFailure(error.message);
        throw error;
      });

  @override
  Future<bool> restoreSession() => _request(() async {
    final session = _auth.currentSession;
    if (session == null) return false;
    if (session.isExpired) await _auth.refreshSession();
    final restored = _auth.currentSession;
    return restored != null && !restored.isExpired;
  });

  @override
  Future<bool> signInWithGoogle() => _request(
    () => _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: googleRedirectUrl,
    ),
  );

  @override
  Future<bool> signIn({required String email, required String password}) =>
      _request(
        () async => _hasSession(
          await _auth.signInWithPassword(
            email: _normalizeEmail(email),
            password: password,
          ),
        ),
      );

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) => _request(() async {
    final response = await _auth.signUp(
      email: _normalizeEmail(email),
      password: password,
      data: {'full_name': name.trim()},
    );
    return response.session != null;
  });

  @override
  Future<bool> verifySignUpOtp({
    required String email,
    required String token,
  }) => _request(
    () async => _hasSession(
      await _auth.verifyOTP(
        email: _normalizeEmail(email),
        token: token.trim(),
        type: OtpType.email,
      ),
    ),
  );

  @override
  Future<void> resendSignUpOtp(String email) => _request(
    () => _auth.resend(type: OtpType.signup, email: _normalizeEmail(email)),
  );

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _request(() => _auth.resetPasswordForEmail(_normalizeEmail(email)));

  @override
  Future<bool> verifyRecoveryOtp({
    required String email,
    required String token,
  }) => _request(
    () async => _hasSession(
      await _auth.verifyOTP(
        email: _normalizeEmail(email),
        token: token.trim(),
        type: OtpType.recovery,
      ),
    ),
  );

  @override
  Future<void> updatePassword({required String newPassword}) =>
      _request(() async {
        await _auth.updateUser(UserAttributes(password: newPassword));
      });

  @override
  Future<void> signOut() => _request(() => _auth.signOut());
}
