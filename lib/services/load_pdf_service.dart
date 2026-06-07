import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../constants/app_text_styles.dart';
import 'catalog_service.dart';
import 'letterhead_pdf.dart';
import 'pdf_export_service.dart';

class LoadPdfService {
  static final _currency = NumberFormat('#,##0');

  static Future<String> downloadLoadPdf({
    required List<ApplianceConfig> appliances,
    required Map<String, int> counts,
    required int totalWatts,
  }) async {
    final bytes = await _buildLoadPdf(
      appliances: appliances,
      counts: counts,
      totalWatts: totalWatts,
    );
    final file = await PdfExportService.saveToDownloads(
      bytes: bytes,
      baseName: 'load-calculation',
    );
    return file.path;
  }

  static Future<String> downloadBackupPdf({
    required List<ApplianceConfig> appliances,
    required Map<String, int> availableCounts,
    required Map<String, List<(int qty, int hours)>> schedule,
    required int wattHours,
  }) async {
    final bytes = await _buildBackupPdf(
      appliances: appliances,
      availableCounts: availableCounts,
      schedule: schedule,
      wattHours: wattHours,
    );
    final file = await PdfExportService.saveToDownloads(
      bytes: bytes,
      baseName: 'battery-backup',
    );
    return file.path;
  }

  static Future<Uint8List> _buildLoadPdf({
    required List<ApplianceConfig> appliances,
    required Map<String, int> counts,
    required int totalWatts,
  }) async {
    final pageTheme = await LetterheadPdf.pageTheme();
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Load Calculation',
              style: AppTextStyles.pdf(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black),
            children: [
              pw.TableRow(
                children: [
                  _cell('Appliance', true),
                  _cell('Watts', true),
                  _cell('Qty', true),
                  _cell('Load (W)', true),
                ],
              ),
              ...appliances.map((a) {
                final qty = counts[a.id] ?? 0;
                return pw.TableRow(
                  children: [
                    _cell(a.label, false),
                    _cell('${a.watts}', false),
                    _cell(qty == 0 ? '-' : '$qty', false),
                    _cell(qty == 0 ? '-' : '${a.watts * qty}', false),
                  ],
                );
              }),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Total Load = ${_currency.format(totalWatts)} W',
            style: AppTextStyles.pdf(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
    return doc.save();
  }

  static Future<Uint8List> _buildBackupPdf({
    required List<ApplianceConfig> appliances,
    required Map<String, int> availableCounts,
    required Map<String, List<(int qty, int hours)>> schedule,
    required int wattHours,
  }) async {
    final pageTheme = await LetterheadPdf.pageTheme();
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (context) {
          final rows = <pw.TableRow>[
            pw.TableRow(
              children: [
                _cell('Appliance', true),
                _cell('Qty from load calc', true),
                _cell('Backup plan (qty x hours)', true),
              ],
            ),
          ];
          for (final a in appliances) {
            final plans = schedule[a.id] ?? const [];
            final label = plans.isEmpty
                ? '-'
                : plans.map((p) => '${p.$1} x ${p.$2}h').join(', ');
            rows.add(
              pw.TableRow(
                children: [
                  _cell(a.label, false),
                  _cell('${availableCounts[a.id] ?? 0}', false),
                  _cell(label, false),
                ],
              ),
            );
          }
          return [
            pw.Text(
              'Battery Backup Calculation',
              style: AppTextStyles.pdf(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Note: Backup window assumed from 6 PM to 8 AM (14 hours).',
              style: AppTextStyles.pdf(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black),
              children: rows,
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Total Backup Energy = ${_currency.format(wattHours)} Wh',
              style: AppTextStyles.pdf(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ];
        },
      ),
    );
    return doc.save();
  }

  static pw.Widget _cell(String text, bool header) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: AppTextStyles.pdf(
          fontSize: 10,
          fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
