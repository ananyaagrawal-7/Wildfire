import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyOnboardingDone = 'onboarding_done';
  static const String _keySelectedPresetIndex = 'selected_preset_index';
  static const String _keyCustomApiUrl = 'custom_api_url';

  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, value);
  }

  static Future<int> getSelectedPresetIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySelectedPresetIndex) ?? 0;
  }

  static Future<void> setSelectedPresetIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySelectedPresetIndex, index);
  }

  static Future<String?> getCustomApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomApiUrl);
  }

  static Future<void> setCustomApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomApiUrl, url);
  }
}
