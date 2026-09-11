import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_kisansetu/main.dart';
import 'package:flutter_application_kisansetu/localization/app_language.dart';
import 'package:flutter_application_kisansetu/localization/app_localizations.dart';
import 'package:flutter_application_kisansetu/localization/language_controller.dart';
import 'package:flutter_application_kisansetu/localization/language_scope.dart';
import 'package:flutter_application_kisansetu/screens/farmer_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('KisanSetu app loads and displays initial English content', (WidgetTester tester) async {
    final controller = LanguageController();
    await tester.pumpWidget(KisanSetuApp(languageController: controller));
    await tester.pumpAndSettle();

    expect(find.text('KisanSetu'), findsOneWidget);
    expect(find.text('I am a Farmer'), findsOneWidget);
    expect(find.text('I am a Buyer'), findsOneWidget);
    expect(find.text('Choose how you want to continue:'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    expect(find.text('हि'), findsOneWidget);
  });

  testWidgets('Toggling language switches UI globally to Hindi and back immediately', (WidgetTester tester) async {
    final controller = LanguageController();
    await tester.pumpWidget(KisanSetuApp(languageController: controller));
    await tester.pumpAndSettle();

    // Verify initial English
    expect(find.text('KisanSetu'), findsOneWidget);
    expect(find.text('I am a Farmer'), findsOneWidget);

    // Tap on the Hindi toggle segment 'हि'
    await tester.tap(find.text('हि'));
    await tester.pumpAndSettle();

    // Verify immediate global Hindi translation
    expect(find.text('किसानसेतु'), findsOneWidget);
    expect(find.text('मैं एक किसान हूँ'), findsOneWidget);
    expect(find.text('मैं एक खरीदार हूँ'), findsOneWidget);
    expect(find.text('चुनें कि आप कैसे जारी रखना चाहते हैं:'), findsOneWidget);

    // Tap on the English toggle segment 'EN'
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    // Verify immediate global switch back to English
    expect(find.text('KisanSetu'), findsOneWidget);
    expect(find.text('I am a Farmer'), findsOneWidget);
    expect(find.text('I am a Buyer'), findsOneWidget);
  });

  testWidgets('FarmerDashboard translates all cards and preserves English digits in Hindi', (WidgetTester tester) async {
    final controller = LanguageController();
    await tester.pumpWidget(
      LanguageScope(
        controller: controller,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return MaterialApp(
              locale: controller.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const FarmerDashboard(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify English initial
    expect(find.text('Meerut Mandi Rate'), findsOneWidget);
    expect(find.text('Market Recommendation'), findsOneWidget);
    expect(find.text('Post New Produce Lot'), findsOneWidget);
    expect(find.text('My Active Lots'), findsOneWidget);
    expect(find.text('Buyer Demand Board'), findsOneWidget);
    expect(find.text('Dispatches & Deals'), findsOneWidget);

    // Switch to Hindi
    controller.setLanguage(AppLanguage.hi);
    await tester.pumpAndSettle();

    // Verify Hindi translations
    expect(find.text('मेरठ मंडी दर'), findsOneWidget);
    expect(find.text('बाज़ार अनुशंसा'), findsOneWidget);
    expect(find.text('नया उत्पाद लॉट पोस्ट करें'), findsOneWidget);
    expect(find.text('मेरे सक्रिय लॉट'), findsOneWidget);
    expect(find.text('खरीदार मांग बोर्ड'), findsOneWidget);
    expect(find.text('डिस्पैच और सौदे'), findsOneWidget);

    // Verify English digits preservation
    expect(find.text('₹2,450'), findsOneWidget);
    expect(find.text('+4.2% आज'), findsOneWidget);
  });
}