import 'package:flutter/services.dart';

import '../services/branding_service.dart';

/// Letterhead image paths (first match in [candidatePaths] wins).
abstract final class AppAssets {
  static const imagesFolder = 'assets/images/';

  /// Primary letterhead file (JPG) — must live under [imagesFolder].
  static const letterhead = 'assets/images/letterhead.jpg';

  static const candidatePaths = [
    letterhead,
    'assets/images/letterhead.jpeg',
    'assets/images/company_letterhead.jpg',
  ];

  /// A4 size in PDF points (same as [PdfPageFormat.a4]).
  static const double pdfPageWidth = 595.28;
  static const double pdfPageHeight = 841.89;

  /// PDF top margin — content starts below the printed header on the letterhead.
  /// If text overlaps the logo/address, increase (e.g. 165). If too low, decrease (e.g. 140).
  static const double pdfContentTopMargin = 152;

  /// Horizontal margin for quotation text on the PDF page.
  static const double pdfContentHorizontalMargin = 36;

  /// Preview top padding for a full-page letterhead at [pageHeight] (keeps UI aligned with PDF).
  static double previewContentTopForHeight(double pageHeight) =>
      pdfContentTopMargin * (pageHeight / pdfPageHeight);

  static double previewContentHorizontalForWidth(double pageWidth) =>
      pdfContentHorizontalMargin * (pageWidth / pdfPageWidth);

  static String? _resolvedLetterheadPath;

  static Future<String?> resolveLetterheadPath({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _resolvedLetterheadPath != null) {
      return _resolvedLetterheadPath;
    }

    for (final path in candidatePaths) {
      try {
        await rootBundle.load(path);
        _resolvedLetterheadPath = path;
        return path;
      } catch (_) {
        // Try next candidate.
      }
    }

    _resolvedLetterheadPath = null;
    return null;
  }

  static Future<ByteData?> loadLetterheadBytes() async {
    final custom = await BrandingService.instance.loadLetterheadBytes();
    if (custom != null) return ByteData.sublistView(custom);

    final path = await resolveLetterheadPath();
    if (path == null) return null;
    return rootBundle.load(path);
  }
}
