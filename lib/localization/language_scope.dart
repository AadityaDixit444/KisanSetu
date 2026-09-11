import 'package:flutter/material.dart';
import 'app_language.dart';
import 'app_localizations.dart';
import 'language_controller.dart';

/// An [InheritedNotifier] that exposes the [LanguageController] across the widget tree.
/// Whenever the language is changed, dependent widgets are rebuilt automatically.
class LanguageScope extends InheritedNotifier<LanguageController> {
  const LanguageScope({
    super.key,
    required LanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Retrieves the [LanguageController] from the closest [LanguageScope] and subscribes to changes.
  static LanguageController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    assert(
      scope != null,
      'No LanguageScope found in context. Make sure KisanSetuApp wraps MaterialApp with LanguageScope.',
    );
    return scope!.notifier!;
  }

  /// Retrieves the [LanguageController] without registering a dependency.
  static LanguageController read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<LanguageScope>()
        ?.widget as LanguageScope?;
    assert(
      scope != null,
      'No LanguageScope found in context. Make sure KisanSetuApp wraps MaterialApp with LanguageScope.',
    );
    return scope!.notifier!;
  }
}

/// Convenient extensions on [BuildContext] for cleaner, concise code across all screens.
extension LanguageContextExtensions on BuildContext {
  /// Access [AppLocalizations] for the current context.
  AppLocalizations get loc => AppLocalizations.of(this);

  /// Translate a string key into active language with optional parameter replacements.
  String tr(String key, {Map<String, dynamic>? args}) =>
      AppLocalizations.of(this).translate(key, args: args);

  /// Access the active [LanguageController].
  LanguageController get languageController => LanguageScope.of(this);

  /// Currently active [AppLanguage].
  AppLanguage get currentLanguage => languageController.currentLanguage;

  /// Returns true if active language is Hindi.
  bool get isHindi => languageController.isHindi;

  /// Returns true if active language is English.
  bool get isEnglish => languageController.isEnglish;

  /// Toggles the language between English and Hindi.
  void toggleLanguage() => LanguageScope.read(this).toggleLanguage();
}
