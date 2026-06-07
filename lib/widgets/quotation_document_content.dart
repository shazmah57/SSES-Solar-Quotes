import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';
import '../models/quotation.dart';
import '../services/quotation_calculator.dart';
import '../services/terms_service.dart';

/// Quotation body (client block, table, totals, warranty, terms) for on-screen preview.
class QuotationDocumentContent extends StatelessWidget {
  const QuotationDocumentContent({
    super.key,
    required this.draft,
    this.compact = false,
  });

  final QuotationDraft draft;
  final bool compact;

  static final _dateFormat = DateFormat('dd-MM-yyyy');
  static final _currency = NumberFormat('#,##0', 'en_US');

  TextStyle _text(
    double size, {
    FontWeight weight = FontWeight.normal,
    Color? color,
  }) {
    return AppTextStyles.material(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = draft.lines;
    final total = draft.grandTotal;
    final base = compact ? AppDimens.previewCompact : AppDimens.previewBase;

    return DefaultTextStyle(
      style: _text(base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _clientBlock(base),
          SizedBox(height: compact ? 8 : 12),
          Center(
            child: Text(
              'Sales Quotation',
              style: _text(base + 2, weight: FontWeight.bold),
            ),
          ),
          if (draft.projectDescription.trim().isNotEmpty) ...[
            SizedBox(height: compact ? 6 : 8),
            Center(
              child: Text(
                'Project Description: ${draft.projectDescription.trim()}',
                style: _text(base - 1, weight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          SizedBox(height: compact ? 8 : 12),
          _itemsTable(lines, base),
          SizedBox(height: compact ? 6 : 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tableTotalFill,
                border: Border.all(color: AppColors.tableBorder, width: 0.75),
              ),
              child: Text(
                'Total Amount = PKR ${_currency.format(total)}/-',
                style: _text(
                  base,
                  weight: FontWeight.bold,
                  color: AppColors.tableTextOnFill,
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text('Warranty:', style: _text(base, weight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...draft.warranties.map(
            (w) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text('- $w', style: _text(base - 1)),
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          Text(
            'Terms and Condition:',
            style: _text(base, weight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder(
            valueListenable: TermsService.instance.terms,
            builder: (context, terms, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < terms.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        '${i + 1}- ${terms[i].text}',
                        style: _text(base - 1),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _clientBlock(double base) {
    Widget inlineField(
      String label,
      String value, {
      TextAlign align = TextAlign.left,
    }) {
      final display = value.trim().isEmpty
          ? '-'
          : (label == 'QUOTED TO' ? value.trim().toUpperCase() : value.trim());
      final style = _text(base - 1);
      final labelStyle = _text(base - 1, weight: FontWeight.bold);

      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: labelStyle),
            TextSpan(text: display, style: style),
          ],
        ),
        textAlign: align,
      );
    }

    Widget pairRow({
      required String leftLabel,
      required String leftValue,
      required String rightLabel,
      required String rightValue,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: inlineField(leftLabel, leftValue)),
            const SizedBox(width: 16),
            Expanded(
              child: inlineField(
                rightLabel,
                rightValue,
                align: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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

  Widget _itemsTable(List<QuotationLine> lines, double base) {
    final headerStyle = _text(base - 2, weight: FontWeight.bold);
    final cellStyle = _text(base - 2);

    final headerCellStyle = headerStyle.copyWith(
      color: AppColors.tableTextOnFill,
    );

    TableRow headerRow() => TableRow(
      decoration: BoxDecoration(
        color: AppColors.tableHeaderFill,
        border: Border.all(color: AppColors.tableBorder, width: 0.75),
      ),
      children: [
        _tableCell('Sr.\nNo', headerCellStyle, TextAlign.center),
        _tableCell('Item', headerCellStyle, TextAlign.center),
        _tableCell('Make/Description', headerCellStyle, TextAlign.center),
        _tableCell('Qty', headerCellStyle, TextAlign.center),
        _tableCell('Unit Price\nPKR', headerCellStyle, TextAlign.center),
        _tableCell('Line Total\nPKR', headerCellStyle, TextAlign.center),
      ],
    );

    return Table(
      border: TableBorder.all(color: AppColors.tableBorder, width: 0.75),
      columnWidths: const {
        0: FixedColumnWidth(28),
        1: FlexColumnWidth(1.3),
        2: FlexColumnWidth(2.2),
        3: FixedColumnWidth(44),
        4: FixedColumnWidth(62),
        5: FixedColumnWidth(68),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      children: [
        headerRow(),
        ...lines.map(
          (line) => TableRow(
            children: [
              _tableCell('${line.serialNo}', cellStyle, TextAlign.center),
              _tableCell(line.item, cellStyle),
              _tableCell(line.makeDescription, cellStyle),
              _tableCell(line.quantityLabel, cellStyle, TextAlign.center),
              _tableCell(
                line.unitPrice > 0
                    ? QuotationCalculator.formatCurrency(line.unitPrice)
                    : '-',
                cellStyle,
                TextAlign.right,
              ),
              _tableCell(
                line.lineTotal > 0
                    ? QuotationCalculator.formatCurrency(line.lineTotal)
                    : '-',
                cellStyle,
                TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableCell(
    String text,
    TextStyle style, [
    TextAlign align = TextAlign.left,
  ]) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Text(text, style: style, textAlign: align),
    );
  }
}
