import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';

/// Service responsible for persisting and restoring the user's language preference locally.
class LanguagePreferences {
  static const String _prefKey = 'kisan_setu_language_code';
  AppLanguage _cachedLanguage = AppLanguage.en;

  AppLanguage get cachedLanguage => _cachedLanguage;

  /// Loads the saved language from persistent storage.
  /// Falls back to English ('en') if not set or on storage error.
  Future<AppLanguage> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && code.isNotEmpty) {
        _cachedLanguage = AppLanguage.fromCode(code);
        return _cachedLanguage;
      }
    } catch (_) {
      // Gracefully fallback to cached/default in testing or storage failure
    }
    return _cachedLanguage;
  }

  /// Saves the user's language preference locally so it persists across restarts.
  Future<void> saveLanguage(AppLanguage language) async {
    _cachedLanguage = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (_) {
      // In-memory preference is already updated
    }
  }
}
