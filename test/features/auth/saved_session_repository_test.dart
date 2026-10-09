import 'dart:convert';

import 'package:authentication/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:authentication/features/profile/data/repositories/supabase_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _SessionStorage extends LocalStorage {
  _SessionStorage(this.saved);
  String? saved;
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => saved != null;
  @override
  Future<String?> accessToken() async => saved;
  @override
  Future<void> persistSession(String persistSessionString) async =>
      saved = persistSessionString;
  @override
  Future<void> removePersistedSession() async => saved = null;
}

class _PkceStorage extends GotrueAsyncStorage {
  final values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => values[key];
  @override
  Future<void> setItem({required String key, required String value}) async =>
      values[key] = value;
  @override
  Future<void> removeItem({required String key}) async => values.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Supabase? activeSupabase;
  tearDown(() async {
    await activeSupabase?.dispose();
    activeSupabase = null;
  });

  test(
    'the production adapters restore the stored account, name, and email across startup',
    () async {
      final expiresAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
      String encode(Map<String, Object> part) =>
          base64Url.encode(utf8.encode(jsonEncode(part))).replaceAll('=', '');
      // A local fixture token is used only for decoding; no authenticated HTTP requests are made.
      final token =
          '${encode({'alg': 'HS256', 'typ': 'JWT'})}.${encode({'sub': 'user-1', 'exp': expiresAt})}.fixture';
      final storage = _SessionStorage(
        jsonEncode({
          'access_token': token,
          'refresh_token': 'fixture-refresh-token',
          'token_type': 'bearer',
          'expires_in': 3600,
          'user': {
            'id': 'user-1',
            'aud': 'authenticated',
            'email': 'saved@example.com',
            'created_at': '2026-01-01T00:00:00Z',
            'app_metadata': {'provider': 'email'},
            'user_metadata': {
              'full_name': 'Saved Name',
              'contact_phone': '+85512345678',
              'bio': 'Saved bio',
            },
          },
        }),
      );
      for (var startup = 0; startup < 2; startup++) {
        activeSupabase = await Supabase.initialize(
          url: 'https://example.supabase.co',
          publishableKey: 'fixture-key',
          authOptions: FlutterAuthClientOptions(
            localStorage: storage,
            pkceAsyncStorage: _PkceStorage(),
            autoRefreshToken: false,
            detectSessionInUri: false,
          ),
        );
        final client = Supabase.instance.client;
        expect(await SupabaseAuthRepository(client).restoreSession(), isTrue);
        final profile = SupabaseProfileRepository(client).currentProfile!;
        expect(profile.id, 'user-1');
        expect(profile.fullName, 'Saved Name');
        expect(profile.email, 'saved@example.com');
        expect(profile.phone, '+85512345678');
        expect(profile.bio, 'Saved bio');
        await Future<void>.delayed(Duration.zero);
        await activeSupabase!.dispose();
        activeSupabase = null;
      }
    },
  );
}
