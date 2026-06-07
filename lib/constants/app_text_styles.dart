import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Standard fonts for UI and PDF.
/// Avoids Helvetica/Roboto-style cap "I" (plain vertical bar) that looks odd in ALL CAPS.
abstract final class AppTextStyles {
  static const fontFamily = 'Segoe UI';
  static const fontFallback = <String>['Tahoma', 'Arial', 'sans-serif'];

  static TextStyle material({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static pw.ThemeData pdfTheme = pw.ThemeData.withFont(
    base: pw.Font.times(),
    bold: pw.Font.timesBold(),
    italic: pw.Font.timesItalic(),
    boldItalic: pw.Font.timesBoldItalic(),
  );

  static pw.TextStyle pdf({
    double fontSize = 10,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    PdfColor? color,
  }) {
    return pw.TextStyle(
      font: fontWeight == pw.FontWeight.bold
          ? pw.Font.timesBold()
          : pw.Font.times(),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
