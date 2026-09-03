import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_kisansetu/main.dart';

void main() {
  testWidgets('KisanSetu app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const KisanSetuApp());

    expect(find.text('KisanSetu'), findsOneWidget);
    expect(find.text('Farmer'), findsOneWidget);
    expect(find.text('Buyer'), findsOneWidget);
  });
}