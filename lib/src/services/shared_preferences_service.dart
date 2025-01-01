import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String onboardingCompleteKey = 'onboardingComplete';

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompleteKey, value);
  }
}
