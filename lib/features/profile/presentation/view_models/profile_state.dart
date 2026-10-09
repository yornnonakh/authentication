import '../../domain/models/user_profile.dart';

class ProfileFeedback {
  const ProfileFeedback(this.message, {this.isError = true});
  final String message;
  final bool isError;
}

class ProfileState {
  const ProfileState({
    required this.profile,
    this.isSaving = false,
    this.feedback,
  });
  final UserProfile profile;
  final bool isSaving;
  final ProfileFeedback? feedback;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isSaving,
    ProfileFeedback? feedback,
  }) => ProfileState(
    profile: profile ?? this.profile,
    isSaving: isSaving ?? this.isSaving,
    feedback: feedback ?? this.feedback,
  );
}
