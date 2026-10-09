import 'dart:async';

import 'package:authentication/features/auth/domain/models/auth_event.dart';
import 'package:authentication/features/auth/domain/repositories/auth_repository.dart';
import 'package:authentication/features/profile/domain/models/user_profile.dart';
import 'package:authentication/features/profile/domain/repositories/profile_repository.dart';
import 'package:authentication/features/onboarding/domain/repositories/onboarding_repository.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  bool completed = true;
  int readCalls = 0;
  int saveCalls = 0;
  Object? readFailure;
  Object? saveFailure;
  Completer<void>? savePending;

  @override
  Future<bool> hasCompleted() async {
    readCalls++;
    if (readFailure != null) throw readFailure!;
    return completed;
  }

  @override
  Future<void> complete() async {
    saveCalls++;
    if (savePending != null) await savePending!.future;
    if (saveFailure != null) throw saveFailure!;
    completed = true;
  }
}

class FakeProfileRepository implements ProfileRepository {
  UserProfile profile = const UserProfile(
    id: 'user-1',
    email: 'user@example.com',
    fullName: 'Sign Up Name',
  );
  int saveCalls = 0;
  Object? loadFailure;
  Object? saveFailure;
  Completer<void>? savePending;

  @override
  UserProfile? get currentProfile => profile;

  @override
  Future<UserProfile> loadProfile() async {
    if (loadFailure != null) throw loadFailure!;
    return profile;
  }

  @override
  Future<UserProfile> saveProfile({
    required String fullName,
    required String phone,
    required String bio,
  }) async {
    saveCalls++;
    if (savePending != null) await savePending!.future;
    if (saveFailure != null) throw saveFailure!;
    profile = UserProfile(
      id: profile.id,
      email: profile.email,
      fullName: fullName,
      phone: phone,
      bio: bio,
      avatarUrl: profile.avatarUrl,
    );
    return profile;
  }
}

class FakeLogoutRepository implements AuthRepository {
  final events = StreamController<AuthEvent>.broadcast();
  bool hasSavedSession = false;
  Object? restoreFailure;
  int restoreCalls = 0;
  int signOutCalls = 0;
  Object? signOutFailure;
  Completer<void>? signOutPending;

  @override
  Stream<AuthEvent> get authStateChanges => events.stream;

  @override
  Future<bool> restoreSession() async {
    restoreCalls++;
    if (restoreFailure != null) throw restoreFailure!;
    return hasSavedSession;
  }

  @override
  Future<bool> signIn({required String email, required String password}) async {
    hasSavedSession = true;
    events.add(const AuthEvent(AuthEventType.signedIn, hasSession: true));
    return true;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutPending != null) await signOutPending!.future;
    if (signOutFailure != null) throw signOutFailure!;
    hasSavedSession = false;
    events.add(const AuthEvent(AuthEventType.signedOut, hasSession: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
