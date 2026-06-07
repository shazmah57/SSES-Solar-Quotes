import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/panel_catalog.dart';
import '../models/panel_spec.dart';
import '../models/structure_layout.dart';
import '../services/structure_calculator.dart';
import 'structure_result_screen.dart';

class StructureDesignScreen extends StatefulWidget {
  const StructureDesignScreen({super.key});

  @override
  State<StructureDesignScreen> createState() => _StructureDesignScreenState();
}

class _StructureDesignScreenState extends State<StructureDesignScreen> {
  final _formKey = GlobalKey<FormState>();
  late StructureLayoutInput _input;
  PanelSpec _selectedPanel = PanelCatalog.defaultPanel;

  @override
  void initState() {
    super.initState();
    _input = StructureLayoutInput(panel: _selectedPanel);
  }

  void _onPanelChanged(PanelSpec? panel) {
    if (panel == null) return;
    setState(() {
      _selectedPanel = panel;
      _input = StructureLayoutInput(
        panel: panel,
        panelsPerRow: _input.panelsPerRow,
        rowCount: _input.rowCount,
        walkwayWidthFt: _input.walkwayWidthFt,
        girderMarginFt: _input.girderMarginFt,
        maxPoleSpacingFt: _input.maxPoleSpacingFt,
        poleHeightFt: _input.poleHeightFt,
        poleSizeLabel: _input.poleSizeLabel,
        girderSizeLabel: _input.girderSizeLabel,
        projectName: _input.projectName,
      );
    });
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final bom = StructureCalculator.calculate(_input);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StructureResultScreen(input: _input, bom: bom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = StructureCalculator.calculate(_input);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Structure Designer'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Project'),
            TextFormField(
              initialValue: _input.projectName,
              decoration: const InputDecoration(
                labelText: 'Project / client name (optional)',
                border: OutlineInputBorder(),
              ),
              onSaved: (v) => _input.projectName = v?.trim() ?? '',
            ),
            const SizedBox(height: 20),
            _sectionTitle('Solar panel'),
            DropdownButtonFormField<PanelSpec>(
              initialValue: _selectedPanel,
              decoration: const InputDecoration(
                labelText: 'Panel model',
                border: OutlineInputBorder(),
              ),
              items: PanelCatalog.panels
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.label, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: _onPanelChanged,
            ),
            const SizedBox(height: 8),
            _infoChip(
              Icons.straighten,
              '${_selectedPanel.wattRangeLabel} · ${_selectedPanel.sizeLabel}',
            ),
            const SizedBox(height: 20),
            _sectionTitle('Layout'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('perRow_${_input.panelsPerRow}'),
                    initialValue: '${_input.panelsPerRow}',
                    decoration: const InputDecoration(
                      labelText: 'Panels per row',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _positiveInt,
                    onChanged: (v) => _updateLayoutInt(
                      v,
                      (n) => _input.panelsPerRow = n,
                      fallback: _input.panelsPerRow,
                    ),
                    onSaved: (v) => _input.panelsPerRow = int.parse(v!.trim()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('rows_${_input.rowCount}'),
                    initialValue: '${_input.rowCount}',
                    decoration: const InputDecoration(
                      labelText: 'Number of rows',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _positiveInt,
                    onChanged: (v) => _updateLayoutInt(
                      v,
                      (n) => _input.rowCount = n,
                      fallback: _input.rowCount,
                    ),
                    onSaved: (v) => _input.rowCount = int.parse(v!.trim()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('walk_${_input.walkwayWidthFt}'),
              initialValue: '${_input.walkwayWidthFt}',
              decoration: const InputDecoration(
                labelText: 'Walkway between rows (ft)',
                helperText: 'Used when rows > 1',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _positiveDouble,
              onChanged: (v) {
                final n = double.tryParse(v.trim());
                if (n != null && n > 0) {
                  setState(() => _input.walkwayWidthFt = n);
                }
              },
              onSaved: (v) => _input.walkwayWidthFt = double.parse(v!.trim()),
            ),
            const SizedBox(height: 8),
            _infoChip(Icons.solar_power, 'Total panels: ${_input.totalPanels}'),
            const SizedBox(height: 20),
            _sectionTitle('Structure sizes'),
            TextFormField(
              initialValue: '${_input.girderMarginFt}',
              decoration: const InputDecoration(
                labelText: 'Girder margin (ft added per row)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _positiveDouble,
              onSaved: (v) => _input.girderMarginFt = double.parse(v!.trim()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: '${_input.maxPoleSpacingFt}',
              decoration: const InputDecoration(
                labelText: 'Max pole spacing (ft)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _positiveDouble,
              onSaved: (v) => _input.maxPoleSpacingFt = double.parse(v!.trim()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: '${_input.poleHeightFt}',
              decoration: const InputDecoration(
                labelText: 'Pole height (ft)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _positiveDouble,
              onSaved: (v) => _input.poleHeightFt = double.parse(v!.trim()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _input.girderSizeLabel,
              decoration: const InputDecoration(
                labelText: 'Girder size',
                border: OutlineInputBorder(),
              ),
              onSaved: (v) => _input.girderSizeLabel = v?.trim() ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _input.poleSizeLabel,
              decoration: const InputDecoration(
                labelText: 'Pole size',
                border: OutlineInputBorder(),
              ),
              onSaved: (v) => _input.poleSizeLabel = v?.trim() ?? '',
            ),
            const SizedBox(height: 24),
            _sectionTitle('Live preview'),
            Card(
              color: const Color(0xFFE8F5E9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _previewRow(
                      'Row girders',
                      '${preview.rowGirderCount} × ${preview.rowGirderLengthFt} ft',
                    ),
                    _previewRow(
                      'Pole-to-pole girders',
                      '${preview.poleToPoleGirderCount} × ${preview.poleToPoleGirderLengthFt} ft',
                    ),
                    _previewRow(
                      'Poles',
                      '${preview.totalPoles} total (${preview.polesPerSide} per side)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calculate full BOM'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: default example is 5 panels × 2 rows with 1.5 ft walkway '
              '(700W panel → 4×20 ft + 2×16 ft girders, 4 poles).',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _previewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String? _positiveInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = int.tryParse(value.trim());
    if (n == null || n < 1) return 'Enter at least 1';
    return null;
  }

  String? _positiveDouble(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final n = double.tryParse(value.trim());
    if (n == null || n <= 0) return 'Enter a positive number';
    return null;
  }

  void _updateLayoutInt(
    String value,
    void Function(int n) apply, {
    required int fallback,
  }) {
    final n = int.tryParse(value.trim());
    if (n != null && n >= 1) {
      setState(() => apply(n));
    } else if (value.isEmpty) {
      setState(() => apply(fallback));
    }
  }
}
