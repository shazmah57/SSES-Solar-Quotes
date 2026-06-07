// Product lists and mounting descriptions from your Excel workbook.
class CatalogData {
  static const solarPanels = [
    'Longi Himo x10 640-650W',
    'Trina/Jinko Bifacial 700-730W',
    'Trina Bifacial 700-730W',
    'Jinko Bifacial 700-730W',
    'Aiko Bifacial 770W',
  ];

  static const solarInverters = [
    'Solax Single Phase Hybrid 6kW - IP66',
    'Solax Single Phase Hybrid 8kW - IP66',
    'Goodwe Single Phase Hybrid 6kW - IP66',
    'Goodwe Single Phase Hybrid 8kW - IP66',
    'Goodwe Single Phase Hybrid 10kW - IP66',
    'Goodwe Single Phase Hybrid 12kW - IP66',
    'Goodwe Three Phase Hybrid 10kW - IP66',
    'Goodwe Three Phase Hybrid 12kW - IP66',
    'Goodwe Three Phase Hybrid 15kW - IP66',
    'Goodwe Three Phase Hybrid 20kW - IP66',
    'Solis Single Phase Hybrid 6kW - IP66',
    'Solis Single Phase Hybrid 8kW - IP66',
    'Solis Single Phase Hybrid 10kW - IP66',
    'Solis Single Phase Hybrid 12kW - IP66',
    'Solis Three Phase Hybrid 10kW - IP66',
    'Solis Three Phase Hybrid 12kW - IP66',
    'Solis Three Phase Hybrid 15kW - IP66',
    'Solis Three Phase Hybrid 20kW - IP66',
    'Goodwe/Solis Single Phase Hybrid 6kW - IP66',
    'Goodwe/Solis Single Phase Hybrid 8kW - IP66',
    'Goodwe/Solis Single Phase Hybrid 10kW - IP66',
    'Goodwe/Solis Single Phase Hybrid 12kW - IP66',
    'Goodwe/Solis Three Phase Hybrid 10kW - IP66',
    'Goodwe/Solis Three Phase Hybrid 12kW - IP66',
    'Goodwe/Solis Three Phase Hybrid 15kW - IP66',
    'Goodwe/Solis Three Phase Hybrid 20kW - IP66',
    'Inverex Nitrox Single Phase Hybrid 6.6kW -IP66',
    'Inverex Nitrox Single Phase Hybrid 10kW -IP66',
    'Itel Single Phase Hybrid 4kW - IP54',
    'Itel Single Phase Hybrid 6kW - IP54',
  ];

  static const batteries = [
    'Itel Lithium 5kWh - IP21',
    'Solax LD51/52 Lithium 5kWh - IP21',
    'Fronus Lithium 5kWh - IP21',
    'Solax/Fronus Lithium 5kWh - IP21',
    'Fronus Brick Lithium 15kWh - IP21',
    'Invt Lithium 5kWh - IP65',
    'Sunwoda/Soluna/Pylontech Lithium 5kWh - IP65',
    'Sunwoda/Soluna/Pylontech Lithium 16kWh - IP65',
    'Sunwoda Lithium 5kWh - IP65',
    'Sunwoda Lithium 16kWh - IP65',
    'Pylontech Lithium 5kWh - IP65',
    'Pylontech Lithium 16kWh - IP65',
    'Soluna Lithium 5kWh - IP65',
    'Soluna Lithium 16kWh - IP65',
  ];

  static const mountingStructureTypes = [
    'Solar Mounting Structure (Elevated)',
    'Solar Mounting Structure (Ground Mount)',
    'Solar Mounting Structure (Semi Elevated)',
  ];

  static const elevatedStructureDescription =
      '''MS Structure: 14 swg (Double Girder)
- Girder: 2.5mm thickness, 4.5 inch
- Column: Pole 14 swg, 4 Inch 95mm
- Base Plate: 8mm thickness, 8x8
- Upper Plate: 6mm thickness, 4 inch Dia
- Bolts: S/S Nut Bolts
- Paint: Epoxy paint with grey oxide under coat
- Ladder: 18 swg''';

  static const groundMountDescription =
      'Standard Ground Mount P1 Aluminum Structure with SS nut bolts and Curbstones';

  static const semiElevatedDescription =
      'Semi Elevated Mount P1 Aluminum Structure with SS nut bolts and Curbstones';

  static const balanceOfSystemDescription =
      '''DC wire: XLPO Pakistan Cables 4mm2
AC wire: Fast Cables 6mm2
CNC Circuit Breakers''';

  static const termsAndConditions = [
    'The expected project completion time is 4-5 working days.',
    'Damaged, Burnout equipment or products are not covered in warranty.',
    'The Company shall not be liable for any loss or damage caused by events beyond its reasonable control (Force Majeure).',
  ];

  static String mountingDescription(String type) {
    switch (type) {
      case 'Solar Mounting Structure (Elevated)':
        return elevatedStructureDescription;
      case 'Solar Mounting Structure (Ground Mount)':
        return groundMountDescription;
      case 'Solar Mounting Structure (Semi Elevated)':
        return semiElevatedDescription;
      default:
        return '';
    }
  }
}
