import 'panel_spec.dart';

/// User inputs for elevated MS structure layout (Phase 1).
class StructureLayoutInput {
  StructureLayoutInput({
    required this.panel,
    this.panelsPerRow = 5,
    this.rowCount = 2,
    this.walkwayWidthFt = 1.5,
    this.girderMarginFt = 2,
    this.maxPoleSpacingFt = 17,
    this.poleHeightFt = 10,
    this.poleSizeLabel = '4 inch × 14 swg (95 mm)',
    this.girderSizeLabel = '4.5 inch × 2.5 mm (14 swg double girder)',
    this.projectName = '',
  });

  final PanelSpec panel;
  int panelsPerRow;
  int rowCount;
  double walkwayWidthFt;
  double girderMarginFt;
  double maxPoleSpacingFt;
  double poleHeightFt;
  String poleSizeLabel;
  String girderSizeLabel;
  String projectName;

  int get totalPanels => panelsPerRow * rowCount;
}
