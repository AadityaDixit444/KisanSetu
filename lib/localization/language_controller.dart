import 'package:flutter/material.dart';
import 'app_language.dart';
import 'language_preferences.dart';

/// State management controller managing the active global language and its persistence.
/// Notifies listeners immediately whenever the language is toggled or updated,
/// triggering real-time UI rebuilds across the entire application.
class LanguageController extends ChangeNotifier {
  final LanguagePreferences _preferences;
  AppLanguage _currentLanguage;

  LanguageController({
    LanguagePreferences? preferences,
    AppLanguage initialLanguage = AppLanguage.en,
  })  : _preferences = preferences ?? LanguagePreferences(),
        _currentLanguage = initialLanguage;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _currentLanguage.locale;
  bool get isHindi => _currentLanguage == AppLanguage.hi;
  bool get isEnglish => _currentLanguage == AppLanguage.en;

  /// Loads stored language preference on application startup.
  Future<void> initialize() async {
    final saved = await _preferences.getSavedLanguage();
    if (saved != _currentLanguage) {
      _currentLanguage = saved;
      notifyListeners();
    }
  }

  /// Changes the application's active language and persists the selection.
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    notifyListeners();
    await _preferences.saveLanguage(language);
  }

  /// Toggles between English ('en') and Hindi ('hi').
  Future<void> toggleLanguage() async {
    final next = _currentLanguage == AppLanguage.en
        ? AppLanguage.hi
        : AppLanguage.en;
    await setLanguage(next);
  }
}
