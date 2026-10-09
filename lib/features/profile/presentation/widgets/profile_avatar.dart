import 'package:flutter/material.dart';
import '../../domain/models/user_profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.size = 44});
  final UserProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: const Color(0xFFE4E5EF),
      child: Text(
        profile?.initials ?? '?',
        style: TextStyle(
          color: const Color(0xFF555B73),
          fontSize: size * 0.34,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    final url = profile?.avatarUrl;
    return Semantics(
      label: 'Profile avatar',
      image: true,
      child: ClipOval(
        child: url == null || url.isEmpty
            ? fallback
            : Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );
  }
}
