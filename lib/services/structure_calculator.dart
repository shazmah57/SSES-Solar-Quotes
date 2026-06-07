import '../models/structure_bom.dart';
import '../models/structure_layout.dart';

/// Elevated structure girder and pole calculations (your site rules).
class StructureCalculator {
  StructureCalculator._();

  static StructureBom calculate(StructureLayoutInput input) {
    final panel = input.panel;
    final rows = input.rowCount;
    final perRow = input.panelsPerRow;

    final rawRowSpan = panel.widthFt * perRow + input.girderMarginFt;
    final rowGirderLengthFt = rawRowSpan.ceil();

    final rowGirderCount = 2 * rows;

    final walkwayTotal = rows > 1 ? input.walkwayWidthFt * (rows - 1) : 0.0;
    final rawPoleSpan = panel.lengthFt * rows + walkwayTotal;
    final poleToPoleGirderLengthFt = rawPoleSpan.floor();

    const poleToPoleGirderCount = 2;

    final polesPerSide = _polesPerSide(
      poleToPoleGirderLengthFt,
      input.maxPoleSpacingFt,
    );
    final totalPoles = polesPerSide * 2;

    final summaryLines = <String>[
      'Panels: $perRow per row × $rows row(s) = ${input.totalPanels} total',
      'Panel size: ${panel.sizeLabel} (${panel.wattRangeLabel})',
      'Row girder span: ${panel.widthFt} ft × $perRow + '
          '${input.girderMarginFt} ft margin = '
          '${rawRowSpan.toStringAsFixed(1)} ft → $rowGirderLengthFt ft (round up)',
      'Row girders: $rowGirderCount × $rowGirderLengthFt ft '
          '(2 per row, along panel width)',
      'Pole-to-pole span: ${panel.lengthFt} ft × $rows'
          '${rows > 1 ? ' + ${input.walkwayWidthFt} ft walkway × ${rows - 1}' : ''} = '
          '${rawPoleSpan.toStringAsFixed(1)} ft → $poleToPoleGirderLengthFt ft (round down)',
      'Pole-to-pole girders: $poleToPoleGirderCount × $poleToPoleGirderLengthFt ft',
      'Poles: $polesPerSide per side × 2 sides = $totalPoles '
          '(max ${input.maxPoleSpacingFt.toStringAsFixed(0)} ft between poles)',
      'Pole height: ${input.poleHeightFt.toStringAsFixed(1)} ft — ${input.poleSizeLabel}',
      'Girder: ${input.girderSizeLabel}',
    ];

    return StructureBom(
      rowGirderLengthFt: rowGirderLengthFt,
      rowGirderCount: rowGirderCount,
      poleToPoleGirderLengthFt: poleToPoleGirderLengthFt,
      poleToPoleGirderCount: poleToPoleGirderCount,
      polesPerSide: polesPerSide,
      totalPoles: totalPoles,
      rawRowGirderSpanFt: rawRowSpan,
      rawPoleToPoleSpanFt: rawPoleSpan,
      summaryLines: summaryLines,
    );
  }

  /// Two poles per side when span ≤ max spacing; otherwise intermediate poles.
  static int _polesPerSide(int spanFt, double maxSpacingFt) {
    if (spanFt <= maxSpacingFt) return 2;
    final bays = (spanFt / maxSpacingFt).ceil();
    return bays + 1;
  }
}
