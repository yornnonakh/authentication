import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/profile_providers.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

final profileViewModelProvider =
    AsyncNotifierProvider.autoDispose<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
      retry: (retryCount, error) => null,
    );

// Use the cached authenticated identity while the server profile loads.
final currentUserProfileProvider = Provider.autoDispose<UserProfile?>(
  (ref) =>
      ref.watch(profileViewModelProvider).value?.profile ??
      ref.watch(profileRepositoryProvider).currentProfile,
);

class ProfileViewModel extends AsyncNotifier<ProfileState> {
  late ProfileRepository _repository;

  @override
  Future<ProfileState> build() async {
    _repository = ref.watch(profileRepositoryProvider);
    return ProfileState(profile: await _repository.loadProfile());
  }

  Future<bool> save({
    required String fullName,
    required String phone,
    required String bio,
  }) async {
    final current = state.value;
    if (current == null || current.isSaving) return false;
    fullName = fullName.trim();
    phone = phone.trim();
    bio = bio.trim();
    String? error;
    if (fullName.isEmpty) {
      error = 'Please enter your full name.';
    } else if (fullName.length > 80) {
      error = 'Full name must be 80 characters or fewer.';
    } else if (phone.isNotEmpty &&
        (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(phone) ||
            phone.replaceAll(RegExp(r'\D'), '').length < 7 ||
            phone.replaceAll(RegExp(r'\D'), '').length > 15)) {
      error = 'Please enter a valid contact phone number.';
    } else if (bio.length > 300) {
      error = 'Bio must be 300 characters or fewer.';
    }
    if (error != null) {
      state = AsyncData(current.copyWith(feedback: ProfileFeedback(error)));
      return false;
    }
    state = AsyncData(current.copyWith(isSaving: true));
    try {
      final profile = await _repository.saveProfile(
        fullName: fullName,
        phone: phone,
        bio: bio,
      );
      if (!ref.mounted) return false;
      state = AsyncData(
        ProfileState(
          profile: profile,
          feedback: ProfileFeedback('Profile saved.', isError: false),
        ),
      );
      return true;
    } catch (error) {
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(
            isSaving: false,
            feedback: ProfileFeedback(
              error is ProfileFailure
                  ? error.message
                  : 'Unable to save your profile. Please try again.',
            ),
          ),
        );
      }
      return false;
    }
  }
}
