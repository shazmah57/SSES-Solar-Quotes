import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/structure_bom.dart';
import '../models/structure_layout.dart';

class StructureResultScreen extends StatelessWidget {
  const StructureResultScreen({
    super.key,
    required this.input,
    required this.bom,
  });

  final StructureLayoutInput input;
  final StructureBom bom;

  @override
  Widget build(BuildContext context) {
    final title = input.projectName.isNotEmpty
        ? input.projectName
        : 'Structure BOM';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _bomTable(context),
          const SizedBox(height: 20),
          _sectionTitle('Calculation details'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bom.summaryLines
                    .map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(line)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _copyBom(context),
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy BOM to clipboard'),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.view_in_ar, color: Color(0xFF1565C0)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Phase 2 will add a 3D view with realistic panel, '
                    'girder, and pole models on this layout.',
                    style: TextStyle(color: Color(0xFF0D47A1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bomTable(BuildContext context) {
    return Card(
      elevation: 2,
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1.2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.green.shade600),
            children: _headerCells(['Item', 'Qty', 'Length']),
          ),
          _dataRow(
            'Row girder (${input.girderSizeLabel.split(',').first})',
            '${bom.rowGirderCount}',
            '${bom.rowGirderLengthFt} ft',
          ),
          _dataRow(
            'Pole-to-pole girder',
            '${bom.poleToPoleGirderCount}',
            '${bom.poleToPoleGirderLengthFt} ft',
          ),
          _dataRow('Pole (${input.poleSizeLabel})', '${bom.totalPoles}', '—'),
          _dataRow(
            'Pole height',
            '—',
            '${input.poleHeightFt.toStringAsFixed(1)} ft',
          ),
          _dataRow(
            'Solar panel (${input.panel.label})',
            '${input.totalPanels}',
            input.panel.sizeLabel,
          ),
          if (input.rowCount > 1)
            _dataRow(
              'Walkway (between rows)',
              '${input.rowCount - 1}',
              '${input.walkwayWidthFt} ft wide',
            ),
        ],
      ),
    );
  }

  List<Widget> _headerCells(List<String> labels) {
    return labels
        .map(
          (l) => Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              l,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        )
        .toList();
  }

  TableRow _dataRow(String item, String qty, String length) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(10), child: Text(item)),
        Padding(padding: const EdgeInsets.all(10), child: Text(qty)),
        Padding(padding: const EdgeInsets.all(10), child: Text(length)),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _copyBom(BuildContext context) async {
    final buffer = StringBuffer()
      ..writeln('Elevated structure BOM')
      ..writeln('Panel: ${input.panel.label} (${input.panel.sizeLabel})')
      ..writeln('Layout: ${input.panelsPerRow} × ${input.rowCount} rows')
      ..writeln()
      ..writeln(
        'Row girders: ${bom.rowGirderCount} × ${bom.rowGirderLengthFt} ft',
      )
      ..writeln(
        'Pole-to-pole girders: ${bom.poleToPoleGirderCount} × '
        '${bom.poleToPoleGirderLengthFt} ft',
      )
      ..writeln('Poles: ${bom.totalPoles} (${bom.polesPerSide} per side)')
      ..writeln('Pole height: ${input.poleHeightFt} ft')
      ..writeln()
      ..writeln('Details:')
      ..write(bom.summaryLines.map((l) => '• $l').join('\n'));

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('BOM copied to clipboard')));
  }
}
