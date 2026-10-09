import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/auth_providers.dart';
import '../../domain/models/auth_event.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_feedback.dart';
import 'auth_validation.dart';
import 'sign_in_state.dart';

final signInViewModelProvider =
    NotifierProvider.autoDispose<SignInViewModel, SignInState>(
      SignInViewModel.new,
    );

class SignInViewModel extends Notifier<SignInState> {
  late AuthRepository _repository;

  @override
  SignInState build() {
    _repository = ref.watch(authRepositoryProvider);
    ref.listen(authEventsProvider, (previous, next) {
      if (!state.waitingForGoogle || state.authenticated) return;
      next.whenData((event) {
        if (event.type == AuthEventType.signedIn && event.hasSession) {
          state = state.copyWith(waitingForGoogle: false, authenticated: true);
        }
      });
      if (next.hasError) {
        state = state.copyWith(
          waitingForGoogle: false,
          feedback: AuthFeedback.fromError(
            next.error!,
            'Google authentication failed.',
          ),
        );
      }
    });
    return const SignInState();
  }

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void cancelGoogleSignIn() => state = state.copyWith(waitingForGoogle: false);

  Future<void> signIn({required String email, required String password}) async {
    if (state.isLoading || state.authenticated) return;
    cancelGoogleSignIn();
    email = AuthValidation.normalizeEmail(email);
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        feedback: AuthFeedback('Please enter your email and password.'),
      );
      return;
    }
    if (!AuthValidation.isEmail(email)) {
      state = state.copyWith(
        feedback: AuthFeedback('Please enter a valid email address.'),
      );
      return;
    }
    state = state.copyWith(isEmailLoading: true);
    try {
      final authenticated = await _repository.signIn(
        email: email,
        password: password,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        authenticated: authenticated,
        feedback: authenticated
            ? null
            : AuthFeedback(
                'Unable to establish a session. Please verify your email.',
              ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      final feedback = AuthFeedback.fromError(
        error,
        'Sign In failed. Please try again.',
      );
      state = state.copyWith(
        feedback: feedback.message.toLowerCase().contains('email not confirmed')
            ? AuthFeedback('Please verify your email before signing in.')
            : feedback,
      );
    } finally {
      if (ref.mounted) state = state.copyWith(isEmailLoading: false);
    }
  }

  Future<void> signInWithGoogle() async {
    if (state.isLoading || state.authenticated) return;
    state = state.copyWith(isGoogleLaunching: true, waitingForGoogle: true);
    try {
      final launched = await _repository.signInWithGoogle();
      if (!ref.mounted) return;
      if (!launched) {
        state = state.copyWith(
          waitingForGoogle: false,
          feedback: AuthFeedback('Unable to open Google Sign-In.'),
        );
      }
      // A launched browser is not an authenticated session. Wait for signedIn.
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        waitingForGoogle: false,
        feedback: AuthFeedback.fromError(
          error,
          'Google Sign-In failed. Please try again.',
        ),
      );
    } finally {
      if (ref.mounted) state = state.copyWith(isGoogleLaunching: false);
    }
  }
}
