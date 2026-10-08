// lib/features/auth/services/auth_service.dart
// or lib/features/auth/data/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // Private constructor (singleton)
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  // =====================================================
  // SIGN UP
  // =====================================================
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return Supabase.instance.client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {'full_name': name.trim()},
    );
  }

  // =====================================================
  // VERIFY OTP (after Sign Up)
  // =====================================================
  Future<AuthResponse> verifySignUpOtp({
    required String email,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.signup,
    );
  }

  // =====================================================
  // RESEND OTP
  // =====================================================
  Future<void> resendSignUpOtp(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email.trim());
  }

  // =====================================================
  // SIGN IN
  // =====================================================
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // =====================================================
  // SIGN OUT
  // =====================================================
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // // =====================================================
  // // HELPERS
  // // =====================================================
  // User? get currentUser => _client.auth.currentUser;

  // Session? get currentSession => _client.auth.currentSession;

  // bool get isLoggedIn => currentSession != null;

  // String? get currentUserEmail => currentUser?.email;

  // String? get currentUserName =>
  //     currentUser?.userMetadata?['full_name'] as String?;

  // ============================================
  // SEND PASSWORD RESET OTP TO EMAIL
  // ============================================
  Future<void> sendPasswordResetEmail(String email) async {
  await Supabase.instance.client.auth.resetPasswordForEmail(
    email.trim().toLowerCase(),
  );
}
  // ============================================
  // VERIFY RECOVERY OTP
  // ============================================
  Future<AuthResponse> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    return await Supabase.instance.client.auth.verifyOTP(
      email: email.trim().toLowerCase(),
      token: token.trim(),
      type: OtpType.recovery,
    );
  }

  // ============================================
  // SET NEW PASSWORD
  // ============================================
  Future<UserResponse> updatePassword({required String newPassword}) async {
    if (newPassword.length < 8) {
      throw const FormatException(
        'Password must contain at least 8 characters.',
      );
    }

    return await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
