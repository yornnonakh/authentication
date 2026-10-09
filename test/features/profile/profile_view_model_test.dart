import 'dart:async';

import 'package:authentication/features/auth/data/providers/auth_providers.dart';
import 'package:authentication/features/auth/domain/models/auth_event.dart';
import 'package:authentication/features/auth/presentation/view_models/logout_view_model.dart';
import 'package:authentication/features/profile/data/providers/profile_providers.dart';
import 'package:authentication/features/profile/domain/models/user_profile.dart';
import 'package:authentication/features/profile/presentation/view_models/profile_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/profile_fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late FakeLogoutRepository auth;
  late ProviderContainer container;

  setUp(() {
    repository = FakeProfileRepository();
    auth = FakeLogoutRepository();
    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repository),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    container.listen(profileViewModelProvider, (_, _) {});
    container.listen(logoutViewModelProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await auth.events.close();
  });

  test('loads signup identity and saves trimmed profile fields', () async {
    final initial = await container.read(profileViewModelProvider.future);
    expect(initial.profile.fullName, 'Sign Up Name');
    expect(initial.profile.email, 'user@example.com');
    final vm = container.read(profileViewModelProvider.notifier);
    expect(
      await vm.save(
        fullName: ' Updated User ',
        phone: ' +855 12345678 ',
        bio: ' My bio ',
      ),
      isTrue,
    );
    final profile = container.read(currentUserProfileProvider)!;
    expect(profile.fullName, 'Updated User');
    expect(profile.phone, '+855 12345678');
    expect(profile.bio, 'My bio');
    expect(profile.email, 'user@example.com');
    // A fresh consumer loads persisted repository data instead of resetting to demo values.
    container.invalidate(profileViewModelProvider);
    expect(
      (await container.read(profileViewModelProvider.future)).profile.fullName,
      'Updated User',
    );
  });

  test(
    'empty names, invalid phone numbers and oversized bios never save',
    () async {
      await container.read(profileViewModelProvider.future);
      final vm = container.read(profileViewModelProvider.notifier);
      expect(await vm.save(fullName: ' ', phone: '', bio: ''), isFalse);
      expect(
        await vm.save(fullName: 'User', phone: 'invalid', bio: ''),
        isFalse,
      );
      expect(
        await vm.save(fullName: 'User', phone: '', bio: 'x' * 301),
        isFalse,
      );
      expect(repository.saveCalls, 0);
      expect(
        container.read(currentUserProfileProvider)?.fullName,
        'Sign Up Name',
      );
    },
  );

  test('save failure retains saved identity and allows retry', () async {
    await container.read(profileViewModelProvider.future);
    repository.saveFailure = const ProfileFailure('Connection failed');
    final vm = container.read(profileViewModelProvider.notifier);
    expect(await vm.save(fullName: 'New User', phone: '', bio: ''), isFalse);
    final state = container.read(profileViewModelProvider).requireValue;
    expect(state.profile.fullName, 'Sign Up Name');
    expect(state.feedback?.message, 'Connection failed');
    expect(state.isSaving, isFalse);
    repository.saveFailure = null;
    expect(await vm.save(fullName: 'New User', phone: '', bio: ''), isTrue);
  });

  test(
    'duplicate save is blocked and late response after disposal is safe',
    () async {
      await container.read(profileViewModelProvider.future);
      repository.savePending = Completer<void>();
      final vm = container.read(profileViewModelProvider.notifier);
      final first = vm.save(fullName: 'New User', phone: '', bio: '');
      expect(await vm.save(fullName: 'Duplicate', phone: '', bio: ''), isFalse);
      expect(repository.saveCalls, 1);
      container.dispose();
      repository.savePending!.complete();
      expect(await first, isFalse);
    },
  );

  test('logout works when the profile failed to load', () async {
    repository.loadFailure = const ProfileFailure('Offline');
    container.invalidate(profileViewModelProvider);
    // Provider build has not yet finished; resolve the profile failure separately.
    await expectLater(
      container.read(profileViewModelProvider.future),
      throwsA(anything),
    );
    expect(
      await container.read(logoutViewModelProvider.notifier).logout(),
      isTrue,
    );
    expect(auth.signOutCalls, 1);
  });

  test('failed logout shows an error and permits another attempt', () async {
    auth.signOutFailure = const AuthFailure('Unable to sign out');
    final vm = container.read(logoutViewModelProvider.notifier);
    expect(await vm.logout(), isFalse);
    expect(container.read(logoutViewModelProvider).hasError, isTrue);
    expect(container.read(logoutViewModelProvider).isLoading, isFalse);
    auth.signOutFailure = null;
    expect(await vm.logout(), isTrue);
  });

  test('duplicate logout requests are blocked', () async {
    auth.signOutPending = Completer<void>();
    final vm = container.read(logoutViewModelProvider.notifier);
    final first = vm.logout();
    expect(await vm.logout(), isFalse);
    expect(auth.signOutCalls, 1);
    auth.signOutPending!.complete();
    expect(await first, isTrue);
  });
}
