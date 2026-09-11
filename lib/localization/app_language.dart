import 'package:flutter/material.dart';

enum AppLanguage {
  en('en', 'English', 'EN'),
  hi('hi', 'हिन्दी', 'हि');

  final String code;
  final String displayName;
  final String shortCode;

  const AppLanguage(this.code, this.displayName, this.shortCode);

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.en;
    return AppLanguage.values.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.en,
    );
  }
}
