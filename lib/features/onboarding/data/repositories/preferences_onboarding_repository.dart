import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_repository.dart';

class PreferencesOnboardingRepository implements OnboardingRepository {
  PreferencesOnboardingRepository(this._preferences);
  final SharedPreferencesAsync _preferences;
  static const completedKey = 'finsight.onboarding.completed.v1';

  @override
  Future<bool> hasCompleted() async =>
      await _preferences.getBool(completedKey) ?? false;

  @override
  Future<void> complete() => _preferences.setBool(completedKey, true);
}
