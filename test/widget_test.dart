import 'package:flutter_test/flutter_test.dart';
import 'package:solar_quotation_app/main.dart';

void main() {
  testWidgets('App loads home with tools', (tester) async {
    await tester.pumpWidget(const SolarQuotationApp());
    expect(find.text('SSES Solar Quotes'), findsOneWidget);
    expect(find.text('Solar Quotation'), findsOneWidget);
  });
}
