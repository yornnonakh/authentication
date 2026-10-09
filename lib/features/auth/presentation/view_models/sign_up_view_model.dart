import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_feedback.dart';
import 'auth_validation.dart';
import 'sign_up_state.dart';

enum SignUpResult { authenticated, needsVerification }

final signUpViewModelProvider =
    NotifierProvider.autoDispose<SignUpViewModel, SignUpState>(
      SignUpViewModel.new,
    );

class SignUpViewModel extends Notifier<SignUpState> {
  late AuthRepository _repository;

  @override
  SignUpState build() {
    _repository = ref.watch(authRepositoryProvider);
    return const SignUpState();
  }

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  void setAgreeTerms(bool value) => state = state.copyWith(agreeTerms: value);

  Future<SignUpResult?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return null;
    email = AuthValidation.normalizeEmail(email);
    String? error;
    if (!state.agreeTerms) {
      error = 'Please agree to Terms & Condition';
    } else if (name.trim().isEmpty || email.isEmpty || password.isEmpty) {
      error = 'Please fill all fields';
    } else if (!AuthValidation.isEmail(email)) {
      error = 'Please enter a valid email address.';
    } else {
      error = AuthValidation.passwordError(password);
    }
    if (error != null) {
      state = state.copyWith(feedback: AuthFeedback(error));
      return null;
    }
    state = state.copyWith(isLoading: true);
    try {
      final authenticated = await _repository.signUp(
        email: email,
        password: password,
        name: name.trim(),
      );
      if (!ref.mounted) return null;
      return authenticated
          ? SignUpResult.authenticated
          : SignUpResult.needsVerification;
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          feedback: AuthFeedback.fromError(
            error,
            'Something went wrong. Please try again.',
          ),
        );
      }
      return null;
    } finally {
      if (ref.mounted) state = state.copyWith(isLoading: false);
    }
  }
}
