import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia local de onboarding completado.
class OnboardingService {
  OnboardingService._();

  static const _key = 'onboarding_completed_v1';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
