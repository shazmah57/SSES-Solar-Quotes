import 'package:flutter_test/flutter_test.dart';
import 'package:solar_quotation_app/data/panel_catalog.dart';
import 'package:solar_quotation_app/models/structure_layout.dart';
import 'package:solar_quotation_app/services/structure_calculator.dart';

void main() {
  test('example: 5+5 panels, 3.5×7.5 ft, 1.5 ft walkway', () {
    final input = StructureLayoutInput(
      panel: PanelCatalog.byId('bifacial_700')!,
      panelsPerRow: 5,
      rowCount: 2,
      walkwayWidthFt: 1.5,
    );

    final bom = StructureCalculator.calculate(input);

    expect(bom.rowGirderLengthFt, 20);
    expect(bom.rowGirderCount, 4);
    expect(bom.poleToPoleGirderLengthFt, 16);
    expect(bom.poleToPoleGirderCount, 2);
    expect(bom.polesPerSide, 2);
    expect(bom.totalPoles, 4);
  });

  test('long span adds intermediate poles', () {
    final input = StructureLayoutInput(
      panel: PanelCatalog.byId('bifacial_700')!,
      panelsPerRow: 5,
      rowCount: 4,
      walkwayWidthFt: 1.5,
      maxPoleSpacingFt: 17,
    );

    final bom = StructureCalculator.calculate(input);
    expect(bom.poleToPoleGirderLengthFt, greaterThan(17));
    expect(bom.polesPerSide, greaterThan(2));
  });
}
