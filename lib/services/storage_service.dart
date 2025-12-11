import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  /// 🔍 Check if onboarding completed
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("first_launch") ?? true;
  }

  /// 🏁 Call when onboarding done
  static Future<void> markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("first_launch", false);
  }
}
