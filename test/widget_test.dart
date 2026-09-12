import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_kisansetu/localization/app_language.dart';
import 'package:flutter_application_kisansetu/localization/app_localizations.dart';
import 'package:flutter_application_kisansetu/localization/language_controller.dart';
import 'package:flutter_application_kisansetu/localization/language_scope.dart';
import 'package:flutter_application_kisansetu/screens/auth/intro_screen.dart';
import 'package:flutter_application_kisansetu/screens/farmer_dashboard.dart';
import 'package:flutter_application_kisansetu/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps a screen with the localization stack, without booting Supabase.
Widget _wrap(LanguageController controller, Widget child) {
  return LanguageScope(
    controller: controller,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          locale: controller.locale,
          // Without this, MaterialApp falls back to en and the Hindi
          // locale never reaches Localizations.
          supportedLocales: const [Locale('en'), Locale('hi')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: child,
        );
      },
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Intro screen shows the brand and both entry buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(LanguageController(), const IntroScreen()));
    await tester.pumpAndSettle();

    expect(find.text('KisanSetu'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('हि'), findsOneWidget);
  });

  testWidgets('Toggling language switches the intro screen to Hindi and back',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(LanguageController(), const IntroScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('हि'));
    await tester.pumpAndSettle();

    expect(find.text('किसानसेतु'), findsOneWidget);
    expect(find.text('शुरू करें'), findsOneWidget);
    expect(find.text('मेरा खाता पहले से है'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('KisanSetu'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets(
      'FarmerDashboard translates all cards and preserves English digits in Hindi',
      (WidgetTester tester) async {
    // The dashboard is a long list; give the test a tall window so every
    // card is built (a ListView does not build off-screen children).
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final controller = LanguageController();
    await tester.pumpWidget(_wrap(controller, const FarmerDashboard()));
    await tester.pumpAndSettle();

    expect(find.text('Meerut Mandi Rate'), findsOneWidget);
    expect(find.text('Market Recommendation'), findsOneWidget);
    expect(find.text('Post New Produce Lot'), findsOneWidget);
    expect(find.text('My Active Lots'), findsOneWidget);
    expect(find.text('Buyer Demand Board'), findsOneWidget);
    expect(find.text('Dispatches & Deals'), findsOneWidget);

    controller.setLanguage(AppLanguage.hi);
    await tester.pumpAndSettle();

    expect(find.text('मेरठ मंडी दर'), findsOneWidget);
    expect(find.text('बाज़ार अनुशंसा'), findsOneWidget);
    expect(find.text('नया उत्पाद लॉट पोस्ट करें'), findsOneWidget);
    expect(find.text('मेरे सक्रिय लॉट'), findsOneWidget);
    expect(find.text('खरीदार मांग बोर्ड'), findsOneWidget);
    expect(find.text('डिस्पैच और सौदे'), findsOneWidget);

    // English digits are preserved in Hindi.
    expect(find.text('₹2,450'), findsOneWidget);
    expect(find.text('+4.2% आज'), findsOneWidget);
  });

  testWidgets('Every translation key exists in both English and Hindi',
      (WidgetTester tester) async {
    final en = AppLocalizations(const Locale('en'));
    final hi = AppLocalizations(const Locale('hi'));

    // Keys added for the auth / intro / voice work must resolve in both
    // languages (translate() returns the key itself when it is missing).
    const keys = [
      'app_name',
      'intro_headline',
      'intro_get_started',
      'auth_sign_in_title',
      'auth_create_account_title',
      'auth_sign_out',
      'auth_err_invalid_credentials',
      'voice_tap_to_speak',
      'voice_nothing_heard',
    ];
    for (final key in keys) {
      expect(en.translate(key), isNot(key), reason: 'missing en: $key');
      expect(hi.translate(key), isNot(key), reason: 'missing hi: $key');
    }
  });
}
