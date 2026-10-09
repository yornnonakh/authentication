import '../models/user_profile.dart';

abstract interface class ProfileRepository {
  UserProfile? get currentProfile;
  Future<UserProfile> loadProfile();
  Future<UserProfile> saveProfile({
    required String fullName,
    required String phone,
    required String bio,
  });
}
