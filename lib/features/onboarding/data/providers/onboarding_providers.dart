import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_repository.dart';
import '../repositories/preferences_onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => PreferencesOnboardingRepository(SharedPreferencesAsync()),
);
