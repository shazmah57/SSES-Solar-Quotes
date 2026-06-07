import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

/// Brand colors shared by UI preview and PDF export.
abstract final class AppColors {
  /// Dark green — accents and text on medium green fills.
  static const brandGreen = Color(0xFF2E7D32);

  /// Green accent on letterhead (top-left stripe).
  static const letterheadGreen = Color(0xFF1B7A3D);

  /// Table header row fill (Sr. No., Item, …) — darker green.
  static const tableHeaderFill = Color(0xFF4CAF50);

  /// Total amount box fill — darker than before, slightly lighter than header.
  static const tableTotalFill = Color(0xFF66BB6A);

  static const tableBorder = Colors.black;

  static final pdfBrandGreen = PdfColor.fromHex('2E7D32');
  static final pdfTableHeaderFill = PdfColor.fromHex('4CAF50');
  static final pdfTableTotalFill = PdfColor.fromHex('66BB6A');
  static const pdfTableBorder = PdfColors.black;
  static const tableTextOnFill = Colors.black;
  static const pdfTableTextOnFill = PdfColors.black;
}
