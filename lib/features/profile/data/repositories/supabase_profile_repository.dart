import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);
  final SupabaseClient _client;

  UserProfile _mapUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    String text(String key) =>
        metadata[key] is String ? metadata[key] as String : '';
    final fullName = text('full_name').trim();
    final avatarUrl = text('avatar_url').trim();
    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: fullName.isNotEmpty ? fullName : text('name'),
      phone: text('contact_phone'),
      bio: text('bio'),
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
    );
  }

  @override
  UserProfile? get currentProfile {
    final user = _client.auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  Future<UserProfile> _request(Future<UserResponse> Function() action) async {
    if (_client.auth.currentUser == null) {
      throw const ProfileFailure('Please sign in to view your profile.');
    }
    try {
      final response = await action();
      final user = response.user;
      if (user == null) {
        throw const ProfileFailure('Unable to load your profile.');
      }
      return _mapUser(user);
    } on AuthException catch (error) {
      throw ProfileFailure(error.message);
    }
  }

  @override
  Future<UserProfile> loadProfile() => _request(() => _client.auth.getUser());

  @override
  Future<UserProfile> saveProfile({
    required String fullName,
    required String phone,
    required String bio,
  }) => _request(
    () => _client.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': fullName.trim(),
          'contact_phone': phone.trim(),
          'bio': bio.trim(),
        },
      ),
    ),
  );
}
