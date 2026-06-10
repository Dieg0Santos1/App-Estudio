import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _onboardingSeenKey = 'onboarding_seen';

final initialOnboardingSeenProvider = Provider<bool>((ref) => false);

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return const OnboardingRepository();
});

class OnboardingRepository {
  const OnboardingRepository();

  static Future<bool> loadSeen() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onboardingSeenKey) ?? false;
  }

  Future<void> markSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingSeenKey, true);
  }
}
