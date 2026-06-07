import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_settings_service.dart';

class PdfExportService {
  static String _safeFileName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'document';
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  /// Saves PDF to the configured download folder (no system picker).
  static Future<File> saveToDownloads({
    required Uint8List bytes,
    required String baseName,
  }) async {
    final dir = await AppSettingsService.instance.ensureDownloadDir();
    final file = File('${dir.path}/${_safeFileName(baseName)}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Opens the share sheet (user can pick WhatsApp) without saving to downloads.
  static Future<void> shareForWhatsApp({
    required Uint8List bytes,
    required String baseName,
  }) async {
    final temp = await getTemporaryDirectory();
    final file = File('${temp.path}/${_safeFileName(baseName)}.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: _safeFileName(baseName),
      ),
    );
  }
}
