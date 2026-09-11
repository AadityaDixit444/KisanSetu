import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_kisansetu/localization/app_language.dart';
import 'package:flutter_application_kisansetu/localization/app_localizations.dart';
import 'package:flutter_application_kisansetu/localization/language_controller.dart';
import 'package:flutter_application_kisansetu/localization/language_preferences.dart';
import 'package:flutter_application_kisansetu/localization/number_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Requirement 1 & 4: LanguageController & Persistence', () {
    test('Default language starts as English', () {
      final controller = LanguageController();
      expect(controller.currentLanguage, AppLanguage.en);
      expect(controller.locale, const Locale('en'));
      expect(controller.isEnglish, isTrue);
      expect(controller.isHindi, isFalse);
    });

    test('toggleLanguage switches immediately from English to Hindi and back', () async {
      final controller = LanguageController();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      await controller.toggleLanguage();
      expect(controller.currentLanguage, AppLanguage.hi);
      expect(controller.locale, const Locale('hi'));
      expect(controller.isHindi, isTrue);
      expect(notifyCount, 1);

      await controller.toggleLanguage();
      expect(controller.currentLanguage, AppLanguage.en);
      expect(controller.locale, const Locale('en'));
      expect(controller.isEnglish, isTrue);
      expect(notifyCount, 2);
    });

    test('Language preference persists across controller initialization', () async {
      final prefs = LanguagePreferences();
      await prefs.saveLanguage(AppLanguage.hi);

      final controller = LanguageController(preferences: prefs);
      await controller.initialize();

      expect(controller.currentLanguage, AppLanguage.hi);
      expect(controller.locale, const Locale('hi'));
    });
  });

  group('Requirement 2: Localization System with String Keys', () {
    test('English dictionary contains valid translations', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.translate('app_name'), 'KisanSetu');
      expect(loc.translate('role_farmer_title'), 'I am a Farmer');
      expect(loc.translate('role_buyer_title'), 'I am a Buyer');
      expect(loc.translate('notifications_title'), 'Notifications');
    });

    test('Hindi dictionary contains valid translations', () {
      final loc = AppLocalizations(const Locale('hi'));
      expect(loc.translate('app_name'), 'किसानसेतु');
      expect(loc.translate('role_farmer_title'), 'मैं एक किसान हूँ');
      expect(loc.translate('role_buyer_title'), 'मैं एक खरीदार हूँ');
      expect(loc.translate('notifications_title'), 'सूचनाएं');
    });

    test('Interpolation with dynamic arguments works correctly', () {
      final locEn = AppLocalizations(const Locale('en'));
      expect(
        locEn.translate('distance_away', args: {'distance': '12'}),
        '12 km away',
      );

      final locHi = AppLocalizations(const Locale('hi'));
      expect(
        locHi.translate('distance_away', args: {'distance': '12'}),
        '12 किमी दूर',
      );
    });
  });

  group('Requirement 3: Number Formatting Exception in Hindi', () {
    test('Devanagari numerals are converted to English digits (0-9)', () {
      const devanagariString = '१० मिनट पहले, मूल्य ₹२,४७०/क्विंटल, मात्रा १५०';
      final sanitized = NumberFormatter.ensureEnglishDigits(devanagariString);

      expect(sanitized, '10 मिनट पहले, मूल्य ₹2,470/क्विंटल, मात्रा 150');
      // Verify no Devanagari numerals remain
      expect(RegExp(r'[०-९]').hasMatch(sanitized), isFalse);
      expect(RegExp(r'[0-9]').hasMatch(sanitized), isTrue);
    });

    test('All Hindi localization strings strictly maintain English digits (0-9)', () {
      final locHi = AppLocalizations(const Locale('hi'));

      final buyerOffer = locHi.translate('notif_buyer_offer_desc');
      expect(buyerOffer.contains('₹2,470'), isTrue);
      expect(buyerOffer.contains('10'), isTrue);
      expect(RegExp(r'[०-९]').hasMatch(buyerOffer), isFalse);

      final marketAlert = locHi.translate('notif_market_alert_desc');
      expect(marketAlert.contains('3.4%'), isTrue);
      expect(marketAlert.contains('1'), isTrue);
      expect(RegExp(r'[०-९]').hasMatch(marketAlert), isFalse);

      final offerUpdate = locHi.translate('notif_offer_update_desc');
      expect(offerUpdate.contains('150'), isTrue);
      expect(offerUpdate.contains('3'), isTrue);
      expect(RegExp(r'[०-९]').hasMatch(offerUpdate), isFalse);

      final activeLots = locHi.translate('active_lots_summary');
      expect(activeLots.contains('2'), isTrue);
      expect(activeLots.contains('180'), isTrue);
      expect(RegExp(r'[०-९]').hasMatch(activeLots), isFalse);
    });

    test('NumberFormatter utilities format with English digits', () {
      expect(NumberFormatter.formatIndianNumber(236000), '2,36,000');
      expect(NumberFormatter.formatCurrency(2450), '₹2,450');
      expect(NumberFormatter.formatQuantity(100, 'qtl'), '100 qtl');
      expect(NumberFormatter.formatPercentage(3.4), '+3.4%');
      expect(NumberFormatter.formatDate(DateTime(2026, 9, 12)), '12/09/2026');
      expect(NumberFormatter.formatTimeAgo(10, isHindi: true), '10 मिनट पहले');
      expect(NumberFormatter.formatTimeAgo(60, isHindi: true), '1 घंटा पहले');
      expect(NumberFormatter.formatTimeAgo(180, isHindi: true), '3 घंटे पहले');
    });

    test('Dynamic arguments with Devanagari numerals are sanitized on translate', () {
      final locHi = AppLocalizations(const Locale('hi'));
      // Even if someone passes Devanagari digits as argument:
      final result = locHi.translate('price_per_qtl', args: {'price': '२,४५०'});
      expect(result, '₹2,450/क्विंटल');
      expect(RegExp(r'[०-९]').hasMatch(result), isFalse);
    });
  });
}
