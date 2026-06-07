import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/app_assets.dart';
import '../services/branding_service.dart';

/// Shared letterhead page theme for all PDF exports.
class LetterheadPdf {
  static Future<pw.MemoryImage?> loadLetterheadImage() async {
    final custom = await BrandingService.instance.loadLetterheadBytes();
    if (custom != null) return pw.MemoryImage(custom);

    final bytes = await AppAssets.loadLetterheadBytes();
    if (bytes == null) return null;
    return pw.MemoryImage(bytes.buffer.asUint8List());
  }

  static Future<pw.PageTheme> pageTheme() async {
    final letterhead = await loadLetterheadImage();
    final topMargin = letterhead != null ? AppAssets.pdfContentTopMargin : 36.0;

    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.fromLTRB(
        AppAssets.pdfContentHorizontalMargin,
        topMargin,
        AppAssets.pdfContentHorizontalMargin,
        36,
      ),
      buildBackground: (context) {
        if (letterhead == null) return pw.SizedBox();
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Image(letterhead, fit: pw.BoxFit.fill),
        );
      },
    );
  }
}
