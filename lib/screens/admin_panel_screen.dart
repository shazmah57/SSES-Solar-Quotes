import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../constants/app_colors.dart';
import '../models/admin_models.dart';
import '../models/appliance_record.dart';
import '../models/bos_record.dart';
import '../services/admin_data_service.dart';
import '../services/app_settings_service.dart';
import '../services/quotation_save_service.dart';
import '../theme/app_surfaces.dart';

class QuoteAdminPanelScreen extends StatefulWidget {
  const QuoteAdminPanelScreen({super.key});

  @override
  State<QuoteAdminPanelScreen> createState() => _QuoteAdminPanelScreenState();
}

class _QuoteAdminPanelScreenState extends State<QuoteAdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _svc = AdminDataService.instance;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : null,
      body: Column(
        children: [
          Material(
            color: AppColors.letterheadGreen,
            elevation: 2,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quote Admin Panel',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Manage quotation master data',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabCtrl,
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Storage'),
                      Tab(text: 'Panels'),
                      Tab(text: 'Inverters'),
                      Tab(text: 'Batteries'),
                      Tab(text: 'Structures'),
                      Tab(text: 'BOS'),
                      Tab(text: 'Terms'),
                      Tab(text: 'Appliances'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                const _StorageTab(),
                _PanelsTab(svc: _svc),
                _InvertersTab(svc: _svc),
                _BatteriesTab(svc: _svc),
                _StructuresTab(svc: _svc),
                _BosTab(svc: _svc),
                _TermsTab(svc: _svc),
                _AppliancesTab(svc: _svc),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STORAGE TAB
// ═════════════════════════════════════════════════════════════

class _StorageTab extends StatefulWidget {
  const _StorageTab();

  @override
  State<_StorageTab> createState() => _StorageTabState();
}

class _StorageTabState extends State<_StorageTab> {
  late final TextEditingController _pathCtrl;
  String _displayPath = '…';
  final _saveService = QuotationSaveService.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pathCtrl = TextEditingController(text: _saveService.customPath ?? '');
    _loadPath();
  }

  Future<void> _loadPath() async {
    final dir = await _saveService.getQuotationsDirectory();
    if (mounted) setState(() => _displayPath = dir.path);
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    try {
      setState(() => _isLoading = true);
      
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Quotations Storage Folder',
      );

      if (selectedDirectory != null) {
        setState(() {
          _pathCtrl.text = selectedDirectory;
          _displayPath = selectedDirectory;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting folder: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: isDark ? const Color(0xFF1A237E) : Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Quotations Storage Folder',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select a folder where saved quotations will be stored',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: $_displayPath',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pathCtrl,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Selected folder path',
                            hintText: 'Tap "Browse" to select a folder',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _pickFolder,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.folder_open),
                        label: const Text('Browse'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () async {
                          if (_pathCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a folder first'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          await _saveService.setCustomPath(_pathCtrl.text);
                          await _loadPath();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quotation storage path updated'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text('Save path'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          _pathCtrl.clear();
                          await _saveService.setCustomPath(null);
                          await _loadPath();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Using default folder'),
                              ),
                            );
                          }
                        },
                        child: const Text('Use default folder'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PDF Download Folder',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Where downloaded PDF reports are saved',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: AppSettingsService.instance.displayDownloadPath(),
                    builder: (context, snapshot) {
                      final path = snapshot.data ?? 'Loading...';
                      return Text(
                        'Current: $path',
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// PANELS TAB
// ═════════════════════════════════════════════════════════════

class _PanelsTab extends StatelessWidget {
  const _PanelsTab({required this.svc});
  final AdminDataService svc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SolarPanelRecord>>(
      valueListenable: svc.panels,
      builder: (context, list, _) {
        return _AdminListView(
          itemCount: list.length,
          onAdd: () => _showPanelDialog(context, null),
          itemBuilder: (i) {
            final r = list[i];
            return _RecordTile(
              title: r.panelName,
              subtitle:
                  '${r.brandMake} · ${r.technology} · ${r.wattage}W · PKR ${r.unitPrice}',
              active: r.active,
              onEdit: () => _showPanelDialog(context, r),
              onDelete: () => _confirmDelete(context, r.panelName,
                  () => svc.deletePanel(r.id)),
              onToggle: () =>
                  svc.updatePanel(r.copyWith(active: !r.active)),
            );
          },
        );
      },
    );
  }

  void _showPanelDialog(BuildContext context, SolarPanelRecord? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.panelName ?? '');
    final brandCtrl =
        TextEditingController(text: existing?.brandMake ?? '');
    final techCtrl =
        TextEditingController(text: existing?.technology ?? '');
    final wattCtrl = TextEditingController(
        text: existing?.wattage.toString() ?? '');
    final priceCtrl = TextEditingController(
        text: existing?.unitPrice.toString() ?? '');
    final warrantyCtrl =
        TextEditingController(text: existing?.warranty ?? '');
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(existing == null ? 'Add Solar Panel' : 'Edit Solar Panel'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Panel Name', nameCtrl),
                _dialogField('Brand / Make', brandCtrl),
                _dialogField('Technology', techCtrl),
                _dialogField('Wattage', wattCtrl, numeric: true),
                _dialogField('Unit Price (PKR)', priceCtrl, numeric: true),
                _dialogField('Warranty', warrantyCtrl),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final record = SolarPanelRecord(
                  id: existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  panelName: nameCtrl.text.trim(),
                  brandMake: brandCtrl.text.trim(),
                  technology: techCtrl.text.trim(),
                  wattage: int.tryParse(wattCtrl.text) ?? 0,
                  unitPrice: int.tryParse(priceCtrl.text) ?? 0,
                  warranty: warrantyCtrl.text.trim(),
                  active: active,
                );
                if (existing == null) {
                  await svc.addPanel(record);
                } else {
                  await svc.updatePanel(record);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// INVERTERS TAB
// ═════════════════════════════════════════════════════════════

class _InvertersTab extends StatelessWidget {
  const _InvertersTab({required this.svc});
  final AdminDataService svc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SolarInverterRecord>>(
      valueListenable: svc.inverters,
      builder: (context, list, _) {
        return _AdminListView(
          itemCount: list.length,
          onAdd: () => _showDialog(context, null),
          itemBuilder: (i) {
            final r = list[i];
            return _RecordTile(
              title: r.inverterName,
              subtitle:
                  '${r.brandMake} · ${r.phaseType} · ${r.capacity} · ${r.ipRating} · PKR ${r.unitPrice}',
              active: r.active,
              onEdit: () => _showDialog(context, r),
              onDelete: () => _confirmDelete(context, r.inverterName,
                  () => svc.deleteInverter(r.id)),
              onToggle: () =>
                  svc.updateInverter(r.copyWith(active: !r.active)),
            );
          },
        );
      },
    );
  }

  void _showDialog(BuildContext context, SolarInverterRecord? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.inverterName ?? '');
    final brandCtrl =
        TextEditingController(text: existing?.brandMake ?? '');
    final phaseCtrl =
        TextEditingController(text: existing?.phaseType ?? '');
    final capCtrl =
        TextEditingController(text: existing?.capacity ?? '');
    final ipCtrl =
        TextEditingController(text: existing?.ipRating ?? '');
    final priceCtrl = TextEditingController(
        text: existing?.unitPrice.toString() ?? '');
    final warrantyCtrl =
        TextEditingController(text: existing?.warranty ?? '');
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title:
              Text(existing == null ? 'Add Inverter' : 'Edit Inverter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Inverter Name', nameCtrl),
                _dialogField('Brand / Make', brandCtrl),
                _dialogField('Phase Type', phaseCtrl),
                _dialogField('Capacity', capCtrl),
                _dialogField('IP Rating', ipCtrl),
                _dialogField('Unit Price (PKR)', priceCtrl, numeric: true),
                _dialogField('Warranty', warrantyCtrl),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final record = SolarInverterRecord(
                  id: existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  inverterName: nameCtrl.text.trim(),
                  brandMake: brandCtrl.text.trim(),
                  phaseType: phaseCtrl.text.trim(),
                  capacity: capCtrl.text.trim(),
                  ipRating: ipCtrl.text.trim(),
                  unitPrice: int.tryParse(priceCtrl.text) ?? 0,
                  warranty: warrantyCtrl.text.trim(),
                  active: active,
                );
                if (existing == null) {
                  await svc.addInverter(record);
                } else {
                  await svc.updateInverter(record);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// BATTERIES TAB
// ═════════════════════════════════════════════════════════════

class _BatteriesTab extends StatelessWidget {
  const _BatteriesTab({required this.svc});
  final AdminDataService svc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BatteryRecord>>(
      valueListenable: svc.batteries,
      builder: (context, list, _) {
        return _AdminListView(
          itemCount: list.length,
          onAdd: () => _showDialog(context, null),
          itemBuilder: (i) {
            final r = list[i];
            return _RecordTile(
              title: r.batteryName,
              subtitle:
                  '${r.brandMake} · ${r.batteryType} · ${r.capacity} · ${r.ipRating} · PKR ${r.unitPrice}',
              active: r.active,
              onEdit: () => _showDialog(context, r),
              onDelete: () => _confirmDelete(
                  context, r.batteryName, () => svc.deleteBattery(r.id)),
              onToggle: () =>
                  svc.updateBattery(r.copyWith(active: !r.active)),
            );
          },
        );
      },
    );
  }

  void _showDialog(BuildContext context, BatteryRecord? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.batteryName ?? '');
    final brandCtrl =
        TextEditingController(text: existing?.brandMake ?? '');
    final typeCtrl =
        TextEditingController(text: existing?.batteryType ?? '');
    final capCtrl =
        TextEditingController(text: existing?.capacity ?? '');
    final ipCtrl =
        TextEditingController(text: existing?.ipRating ?? '');
    final priceCtrl = TextEditingController(
        text: existing?.unitPrice.toString() ?? '');
    final warrantyCtrl =
        TextEditingController(text: existing?.warranty ?? '');
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(existing == null ? 'Add Battery' : 'Edit Battery'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Battery Name', nameCtrl),
                _dialogField('Brand / Make', brandCtrl),
                _dialogField('Battery Type', typeCtrl),
                _dialogField('Capacity', capCtrl),
                _dialogField('IP Rating', ipCtrl),
                _dialogField('Unit Price (PKR)', priceCtrl, numeric: true),
                _dialogField('Warranty', warrantyCtrl),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final record = BatteryRecord(
                  id: existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  batteryName: nameCtrl.text.trim(),
                  brandMake: brandCtrl.text.trim(),
                  batteryType: typeCtrl.text.trim(),
                  capacity: capCtrl.text.trim(),
                  ipRating: ipCtrl.text.trim(),
                  unitPrice: int.tryParse(priceCtrl.text) ?? 0,
                  warranty: warrantyCtrl.text.trim(),
                  active: active,
                );
                if (existing == null) {
                  await svc.addBattery(record);
                } else {
                  await svc.updateBattery(record);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STRUCTURES TAB
// ═════════════════════════════════════════════════════════════

class _StructuresTab extends StatelessWidget {
  const _StructuresTab({required this.svc});
  final AdminDataService svc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<MountingStructureRecord>>(
      valueListenable: svc.structures,
      builder: (context, list, _) {
        return _AdminListView(
          itemCount: list.length,
          onAdd: () => _showDialog(context, null),
          itemBuilder: (i) {
            final r = list[i];
            return _RecordTile(
              title: r.structureName,
              subtitle: '${r.description} · PKR ${r.unitPrice}',
              active: r.active,
              onEdit: () => _showDialog(context, r),
              onDelete: () => _confirmDelete(context, r.structureName,
                  () => svc.deleteStructure(r.id)),
              onToggle: () =>
                  svc.updateStructure(r.copyWith(active: !r.active)),
            );
          },
        );
      },
    );
  }

  void _showDialog(
      BuildContext context, MountingStructureRecord? existing) {
    final nameCtrl =
        TextEditingController(text: existing?.structureName ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    final matCtrl =
        TextEditingController(text: existing?.materialDetails ?? '');
    final priceCtrl = TextEditingController(
        text: existing?.unitPrice.toString() ?? '');
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(
              existing == null ? 'Add Structure' : 'Edit Structure'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Structure Name', nameCtrl),
                _dialogField('Description', descCtrl, maxLines: 2),
                _dialogField('Material Details', matCtrl, maxLines: 4),
                _dialogField('Unit Price (PKR)', priceCtrl, numeric: true),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final record = MountingStructureRecord(
                  id: existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  structureName: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  materialDetails: matCtrl.text.trim(),
                  unitPrice: int.tryParse(priceCtrl.text) ?? 0,
                  active: active,
                );
                if (existing == null) {
                  await svc.addStructure(record);
                } else {
                  await svc.updateStructure(record);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// BOS TAB (Balance of System)
// ═════════════════════════════════════════════════════════════

class _BosTab extends StatelessWidget {
  const _BosTab({required this.svc});
  final AdminDataService svc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BosRecord>>(
      valueListenable: svc.bosRecords,
      builder: (context, list, _) {
        if (list.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No BOS records found.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add a new BOS template',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return _AdminListView(
          itemCount: list.length,
          onAdd: () => _showDialog(context, null),
          itemBuilder: (i) {
            final r = list[i];
            return _RecordTile(
              title: r.title,
              subtitle: r.description.length > 60 
                  ? '${r.description.substring(0, 60)}...' 
                  : r.description,
              active: r.active,
              onEdit: () => _showDialog(context, r),
              onDelete: () => _confirmDelete(
                  context, r.title, () => svc.deleteBos(r.id)),
              onToggle: () =>
                  svc.updateBos(r.copyWith(active: !r.active)),
            );
          },
        );
      },
    );
  }

  void _showDialog(BuildContext context, BosRecord? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(existing == null ? 'Add BOS' : 'Edit BOS'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Description (use \\n for new lines)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final record = BosRecord(
                  id: existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  active: active,
                );
                if (existing == null) {
                  await svc.addBos(record);
                } else {
                  await svc.updateBos(record);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// TERMS TAB
// ═════════════════════════════════════════════════════════════

class _TermsTab extends StatelessWidget {
  const _TermsTab({required this.svc});
  final AdminDataService svc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TermsRecord>>(
      valueListenable: svc.terms,
      builder: (context, list, _) {
        final sorted = [...list]
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return _AdminListView(
          itemCount: sorted.length,
          onAdd: () => _showDialog(context, null, list.length),
          itemBuilder: (i) {
            final r = sorted[i];
            return _RecordTile(
              title: r.title.isEmpty ? 'Term ${i + 1}' : r.title,
              subtitle: '${r.description} · Order: ${r.sortOrder}',
              active: r.active,
              onEdit: () => _showDialog(context, r, null),
              onDelete: () => _confirmDelete(
                  context,
                  r.title.isEmpty ? 'this term' : r.title,
                  () => svc.deleteTerm(r.id)),
              onToggle: () =>
                  svc.updateTerm(r.copyWith(active: !r.active)),
            );
          },
        );
      },
    );
  }

  void _showDialog(
      BuildContext context, TermsRecord? existing, int? nextOrder) {
    final titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    final orderCtrl = TextEditingController(
        text: (existing?.sortOrder ?? nextOrder ?? 0).toString());
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(existing == null ? 'Add Term' : 'Edit Term'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Title', titleCtrl),
                _dialogField('Description', descCtrl, maxLines: 4),
                _dialogField('Sort Order', orderCtrl, numeric: true),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final record = TermsRecord(
                  id: existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  sortOrder: int.tryParse(orderCtrl.text) ?? 0,
                  active: active,
                );
                if (existing == null) {
                  await svc.addTerm(record);
                } else {
                  await svc.updateTerm(record);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// APPLIANCES TAB
// ═════════════════════════════════════════════════════════════

class _AppliancesTab extends StatelessWidget {
  const _AppliancesTab({required this.svc});
  final AdminDataService svc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ApplianceRecord>>(
      valueListenable: svc.appliances,
      builder: (context, list, _) {
        return _AdminListView(
          itemCount: list.length,
          onAdd: () => _showDialog(context, null),
          itemBuilder: (i) {
            final r = list[i];
            return _RecordTile(
              title: r.applianceName,
              subtitle: '${r.watts} W · Backup slots: ${r.backupSlots}',
              active: r.active,
              onEdit: () => _showDialog(context, r),
              onDelete: () => _confirmDelete(
                  context, r.applianceName, () => svc.deleteAppliance(r.id)),
              onToggle: () =>
                  svc.updateAppliance(r.copyWith(active: !r.active)),
            );
          },
        );
      },
    );
  }

  void _showDialog(BuildContext context, ApplianceRecord? existing) {
    final nameCtrl = TextEditingController(text: existing?.applianceName ?? '');
    final wattsCtrl = TextEditingController(text: existing?.watts.toString() ?? '');
    final slotsCtrl = TextEditingController(
        text: existing?.backupSlots.toString() ?? '5');
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: Text(existing == null ? 'Add Appliance' : 'Edit Appliance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Appliance Name', nameCtrl),
                _dialogField('Watts', wattsCtrl, numeric: true),
                _dialogField('Backup Slots (1-10)', slotsCtrl, numeric: true),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final slots = int.tryParse(slotsCtrl.text) ?? 5;
                final record = ApplianceRecord(
                  id: existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  applianceName: nameCtrl.text.trim(),
                  watts: int.tryParse(wattsCtrl.text) ?? 0,
                  backupSlots: slots.clamp(1, 10),
                  active: active,
                );
                if (existing == null) {
                  await svc.addAppliance(record);
                } else {
                  await svc.updateAppliance(record);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═════════════════════════════════════════════════════════════

class _AdminListView extends StatelessWidget {
  const _AdminListView({
    required this.itemCount,
    required this.itemBuilder,
    required this.onAdd,
  });

  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (itemCount == 0)
          const Center(
            child: Text('No records yet. Tap + to add.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
            itemCount: itemCount,
            itemBuilder: (_, i) => itemBuilder(i),
          ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: AppColors.letterheadGreen,
            foregroundColor: Colors.white,
            onPressed: onAdd,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF141414) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: active
              ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active
                ? AppSurfaces.primaryText(context)
                : AppSurfaces.secondaryText(context),
            decoration: active ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: AppSurfaces.secondaryText(context),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                active ? Icons.toggle_on : Icons.toggle_off,
                color: active ? AppColors.letterheadGreen : Colors.grey,
                size: 28,
              ),
              tooltip: active ? 'Deactivate' : 'Activate',
              onPressed: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: Colors.red),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}

Widget _dialogField(String label, TextEditingController ctrl,
    {bool numeric = false, int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      inputFormatters: numeric
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Future<void> _confirmDelete(
    BuildContext context, String name, Future<void> Function() onConfirm) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text('Are you sure you want to delete "$name"?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed == true) await onConfirm();
}