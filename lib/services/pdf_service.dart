import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import 'admin_data_service.dart';
import 'letterhead_pdf.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../models/quotation.dart';
import 'pdf_export_service.dart';
import 'terms_service.dart';

class PdfService {
  static final _dateFormat = DateFormat('dd-MM-yyyy');
  static final _currency = NumberFormat('#,##0', 'en_US');

  static List<String> get _activeTermTexts {
    final adminTerms = AdminDataService.instance.activeTerms;
    if (adminTerms.isNotEmpty) {
      return adminTerms.map((t) => t.description).toList();
    }
    return TermsService.instance.texts;
  }

  static Future<Uint8List> buildQuotationPdf(QuotationDraft draft) async {
    final pdf = pw.Document();
    final letterhead = await LetterheadPdf.loadLetterheadImage();
    final lines = draft.lines;
    final total = draft.grandTotal;
    final warranties = draft.warranties;

    final topMargin = letterhead != null ? AppAssets.pdfContentTopMargin : 36.0;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.fromLTRB(
            AppAssets.pdfContentHorizontalMargin,
            topMargin,
            AppAssets.pdfContentHorizontalMargin,
            36,
          ),
          theme: AppTextStyles.pdfTheme,
          buildBackground: (context) {
            if (letterhead == null) return pw.SizedBox();
            // Full-page letterhead (image is already A4); no extra stretch logic needed.
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(letterhead, fit: pw.BoxFit.fill),
            );
          },
        ),
        build: (context) => [
          _clientBlock(draft),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'Sales Quotation',
              style: AppTextStyles.pdf(
                fontSize: AppDimens.pdfTitle,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          if (draft.projectDescription.trim().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Project Description: ${draft.projectDescription.trim()}',
                style: AppTextStyles.pdf(
                  fontSize: AppDimens.pdfBody,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
          pw.SizedBox(height: 10),
          _itemsTable(lines),
          pw.SizedBox(height: 8),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: pw.BoxDecoration(
                color: AppColors.pdfTableTotalFill,
                border: pw.Border.all(
                  color: AppColors.pdfTableBorder,
                  width: 0.75,
                ),
              ),
              child: pw.Text(
                'Total Amount = PKR ${_currency.format(total)}/-',
                style: AppTextStyles.pdf(
                  fontSize: AppDimens.pdfTotal,
                  fontWeight: pw.FontWeight.bold,
                  color: AppColors.pdfTableTextOnFill,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Warranty:',
            style: AppTextStyles.pdf(
              fontSize: AppDimens.pdfBody,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          ...warranties.map(
            (w) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
              child: pw.Text(
                '- $w',
                style: AppTextStyles.pdf(fontSize: AppDimens.pdfSmall),
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Terms and Condition:',
            style: AppTextStyles.pdf(
              fontSize: AppDimens.pdfBody,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          for (var i = 0; i < _activeTermTexts.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                '${i + 1}- ${_activeTermTexts[i]}',
                style: AppTextStyles.pdf(fontSize: AppDimens.pdfSmall),
              ),
            ),
        ],
      ),
    );

    return pdf.save();
  }

  static String _fileBaseName(QuotationDraft draft) {
    return draft.quotationNumber.trim().isEmpty
        ? 'solar-quotation'
        : draft.quotationNumber.trim();
  }

  static Future<void> downloadQuotation(
    QuotationDraft draft, {
    required void Function(String path) onSaved,
  }) async {
    final bytes = await buildQuotationPdf(draft);
    final file = await PdfExportService.saveToDownloads(
      bytes: bytes,
      baseName: _fileBaseName(draft),
    );
    onSaved(file.path);
  }

  static Future<void> shareQuotationWhatsApp(QuotationDraft draft) async {
    final bytes = await buildQuotationPdf(draft);
    await PdfExportService.shareForWhatsApp(
      bytes: bytes,
      baseName: _fileBaseName(draft),
    );
  }

  /// Optional print preview (not used for default download flow).
  static Future<void> previewPrint(QuotationDraft draft) async {
    final bytes = await buildQuotationPdf(draft);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: _fileBaseName(draft),
    );
  }

  static pw.Widget _clientBlock(QuotationDraft draft) {
    pw.Widget inlineField(String label, String value) {
      final display = value.trim().isEmpty
          ? '-'
          : (label == 'QUOTED TO' ? value.trim().toUpperCase() : value.trim());
      final labelStyle = AppTextStyles.pdf(
        fontSize: AppDimens.pdfClient,
        fontWeight: pw.FontWeight.bold,
      );
      final valueStyle = AppTextStyles.pdf(fontSize: AppDimens.pdfClient);

      return pw.Wrap(
        children: [
          pw.Text('$label: ', style: labelStyle),
          pw.Text(display, style: valueStyle),
        ],
      );
    }

    pw.Widget pairRow({
      required String leftLabel,
      required String leftValue,
      required String rightLabel,
      required String rightValue,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: inlineField(leftLabel, leftValue)),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: pw.Align(
                alignment: pw.Alignment.topRight,
                child: inlineField(rightLabel, rightValue),
              ),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pairRow(
          leftLabel: 'QUOTED TO',
          leftValue: draft.quotedTo,
          rightLabel: 'QUOTATION NUMBER',
          rightValue: draft.quotationNumber,
        ),
        pairRow(
          leftLabel: 'CONTACT NO.',
          leftValue: draft.contactNo,
          rightLabel: 'ISSUE DATE',
          rightValue: _dateFormat.format(draft.issueDate),
        ),
        pairRow(
          leftLabel: 'EMAIL',
          leftValue: draft.email,
          rightLabel: 'EXPIRY DATE',
          rightValue: _dateFormat.format(draft.expiryDate),
        ),
      ],
    );
  }

  static pw.Widget _itemsTable(List<QuotationLine> lines) {
    final headerStyle = AppTextStyles.pdf(
      fontSize: AppDimens.pdfTableHeader,
      fontWeight: pw.FontWeight.bold,
      color: AppColors.pdfTableTextOnFill,
    );
    final cellStyle = AppTextStyles.pdf(fontSize: AppDimens.pdfTableCell);

    return pw.Table(
      border: pw.TableBorder.all(color: AppColors.pdfTableBorder, width: 0.75),
      columnWidths: {
        0: const pw.FixedColumnWidth(22),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(2.4),
        3: const pw.FixedColumnWidth(42),
        4: const pw.FixedColumnWidth(58),
        5: const pw.FixedColumnWidth(62),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: AppColors.pdfTableHeaderFill,
            border: pw.Border.all(color: AppColors.pdfTableBorder, width: 0.75),
          ),
          children: [
            _cell('Sr.\nNo', style: headerStyle, align: pw.TextAlign.center),
            _cell('Item', style: headerStyle, align: pw.TextAlign.center),
            _cell(
              'Make/Description',
              style: headerStyle,
              align: pw.TextAlign.center,
            ),
            _cell('Qty', style: headerStyle, align: pw.TextAlign.center),
            _cell(
              'Unit Price\nPKR',
              style: headerStyle,
              align: pw.TextAlign.center,
            ),
            _cell(
              'Line Total\nPKR',
              style: headerStyle,
              align: pw.TextAlign.center,
            ),
          ],
        ),
        ...lines.map(
          (line) => pw.TableRow(
            children: [
              _cell(
                '${line.serialNo}',
                style: cellStyle,
                align: pw.TextAlign.center,
              ),
              _cell(line.item, style: cellStyle),
              _cell(line.makeDescription, style: cellStyle),
              _cell(
                line.quantityLabel,
                style: cellStyle,
                align: pw.TextAlign.center,
              ),
              _cell(
                line.unitPrice > 0 ? _currency.format(line.unitPrice) : '-',
                style: cellStyle,
                align: pw.TextAlign.right,
              ),
              _cell(
                line.lineTotal > 0 ? _currency.format(line.lineTotal) : '-',
                style: cellStyle,
                align: pw.TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    required pw.TextStyle style,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: style, textAlign: align),
    );
  }
}
