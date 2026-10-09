class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone = '',
    this.bio = '',
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String bio;
  final String? avatarUrl;

  String get displayName => fullName.trim().isNotEmpty
      ? fullName.trim()
      : email.isNotEmpty
      ? email.split('@').first
      : 'Your account';

  String get initials {
    final words = displayName
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return (words.length > 1
            ? '${words.first[0]}${words.last[0]}'
            : words.first[0])
        .toUpperCase();
  }
}

class ProfileFailure implements Exception {
  const ProfileFailure(this.message);
  final String message;
}
