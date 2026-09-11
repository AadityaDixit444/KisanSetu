import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_kisansetu/main.dart';
import 'package:flutter_application_kisansetu/localization/language_controller.dart';
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
}