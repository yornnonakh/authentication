class AuthValidation {
  AuthValidation._();

  static String normalizeEmail(String email) => email.trim().toLowerCase();
  static bool isEmail(String email) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  static bool isOtp(String code) => RegExp(r'^\d{6}$').hasMatch(code.trim());

  static String? passwordError(String password) => password.length < 8
      ? 'Password must contain at least 8 characters.'
      : null;
}
