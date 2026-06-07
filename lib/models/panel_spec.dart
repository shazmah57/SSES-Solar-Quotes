/// Physical panel used for structure layout and 3D (Phase 2+).
class PanelSpec {
  const PanelSpec({
    required this.id,
    required this.label,
    required this.wattMin,
    required this.wattMax,
    required this.widthFt,
    required this.lengthFt,
    this.thicknessIn = 1.4,
  });

  final String id;
  final String label;
  final int wattMin;
  final int wattMax;

  /// Width along a row (girder direction).
  final double widthFt;

  /// Length perpendicular to row (pole-to-pole direction).
  final double lengthFt;
  final double thicknessIn;

  String get wattRangeLabel => '$wattMin–$wattMax W';

  String get sizeLabel =>
      '${widthFt.toStringAsFixed(1)} × ${lengthFt.toStringAsFixed(1)} ft';
}
