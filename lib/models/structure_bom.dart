/// Bill of materials from structure calculator.
class StructureBom {
  const StructureBom({
    required this.rowGirderLengthFt,
    required this.rowGirderCount,
    required this.poleToPoleGirderLengthFt,
    required this.poleToPoleGirderCount,
    required this.polesPerSide,
    required this.totalPoles,
    required this.rawRowGirderSpanFt,
    required this.rawPoleToPoleSpanFt,
    required this.summaryLines,
  });

  final int rowGirderLengthFt;
  final int rowGirderCount;
  final int poleToPoleGirderLengthFt;
  final int poleToPoleGirderCount;
  final int polesPerSide;
  final int totalPoles;
  final double rawRowGirderSpanFt;
  final double rawPoleToPoleSpanFt;
  final List<String> summaryLines;
}
