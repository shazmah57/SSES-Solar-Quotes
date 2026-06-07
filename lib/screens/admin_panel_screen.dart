import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_settings_service.dart';
import '../services/branding_service.dart';
import '../services/catalog_service.dart';
import '../services/terms_service.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CatalogService.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _BrandingSection(),
          const SizedBox(height: 12),
          const _SettingsSection(),
          const SizedBox(height: 12),
          const _TermsSection(),
          const SizedBox(height: 12),
          ValueListenableBuilder<bool>(
            valueListenable: service.cloudEnabled,
            builder: (context, cloudEnabled, _) {
              if (!cloudEnabled) {
                return ValueListenableBuilder<String?>(
                  valueListenable: service.cloudInitError,
                  builder: (context, error, _) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.cloud_off,
                              size: 40,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              error ??
                                  'Cloud sync is offline. Branding, terms, and download folder still work on this device.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () => service.init(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry cloud connection'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Column(
                children: [
                  _CatalogSection(type: CatalogType.panel),
                  SizedBox(height: 12),
                  _CatalogSection(type: CatalogType.inverter),
                  SizedBox(height: 12),
                  _CatalogSection(type: CatalogType.battery),
                  SizedBox(height: 12),
                  _ApplianceSection(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatefulWidget {
  const _SettingsSection();

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  late final TextEditingController _pathCtrl;
  String _displayPath = '…';

  @override
  void initState() {
    super.initState();
    _pathCtrl = TextEditingController(
      text: AppSettingsService.instance.customDownloadPath ?? '',
    );
    _loadPath();
  }

  Future<void> _loadPath() async {
    final path = await AppSettingsService.instance.displayDownloadPath();
    if (mounted) setState(() => _displayPath = path);
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PDF download folder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Current: $_displayPath',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pathCtrl,
              decoration: const InputDecoration(
                labelText: 'Custom folder path (optional)',
                hintText: 'Leave empty for Downloads/SSES Solar Quotes Downloads',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: () async {
                    await AppSettingsService.instance.setDownloadPath(
                      _pathCtrl.text,
                    );
                    await _loadPath();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download path updated')),
                      );
                    }
                  },
                  child: const Text('Save path'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    _pathCtrl.clear();
                    await AppSettingsService.instance.setDownloadPath(null);
                    await _loadPath();
                  },
                  child: const Text('Use default folder'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection();

  @override
  Widget build(BuildContext context) {
    final terms = TermsService.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & conditions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: terms.terms,
              builder: (context, list, _) {
                return Column(
                  children: [
                    ...list.map((t) {
                      return ListTile(
                        dense: true,
                        title: Text(t.text, style: const TextStyle(fontSize: 14)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => terms.deleteTerm(t.id),
                        ),
                        onTap: () => _showInputDialog(
                          context,
                          title: 'Edit term',
                          initial: t.text,
                          onSave: (v) => terms.upsertTerm(id: t.id, text: v),
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => _showInputDialog(
                        context,
                        title: 'Add term',
                        initial: '',
                        onSave: (v) => terms.upsertTerm(text: v),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add term'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({required this.type});

  final CatalogType type;

  @override
  Widget build(BuildContext context) {
    final service = CatalogService.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: service.streamCatalogDocs(type),
              builder: (context, snap) {
                final docs = snap.data ?? const [];
                return Column(
                  children: [
                    ...docs.map((d) {
                      final name = (d.data()['name'] as String? ?? '').trim();
                      return ListTile(
                        dense: true,
                        title: Text(name),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => service.deleteCatalogItem(d.id),
                        ),
                        onTap: () => _showInputDialog(
                          context,
                          title: 'Edit ${type.title}',
                          initial: name,
                          onSave: (value) => service.upsertCatalogItem(
                            type: type,
                            id: d.id,
                            name: value,
                          ),
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _showInputDialog(
                          context,
                          title: 'Add ${type.title}',
                          initial: '',
                          onSave: (value) => service.upsertCatalogItem(
                            type: type,
                            name: value,
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add new'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandingSection extends StatelessWidget {
  const _BrandingSection();

  @override
  Widget build(BuildContext context) {
    final branding = BrandingService.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Company branding',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload letterhead (backgrounds & PDFs) and logo (white-label). '
              'Use Default for blank/SSES assets. After changing logo, rebuild the APK for the home-screen icon.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => branding.pickAndSaveLetterhead(),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload letterhead'),
                ),
                FilledButton.icon(
                  onPressed: () => branding.pickAndSaveLogo(),
                  icon: const Icon(Icons.image),
                  label: const Text('Upload logo'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await branding.useDefaultBranding();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Using default letterhead (blank custom)'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Use default (blank)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplianceSection extends StatelessWidget {
  const _ApplianceSection();

  @override
  Widget build(BuildContext context) {
    final service = CatalogService.instance;
    return ValueListenableBuilder<CatalogSnapshot>(
      valueListenable: service.snapshot,
      builder: (context, snap, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Load & backup appliances',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...snap.appliances.map((a) {
                  return ListTile(
                    title: Text(a.label),
                    subtitle: Text(
                      '${a.watts} W · ${a.backupSlots} backup boxes',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => service.deleteAppliance(a.id),
                    ),
                    onTap: () => _showApplianceDialog(
                      context,
                      initialLabel: a.label,
                      initialWatts: a.watts,
                      initialBackupSlots: a.backupSlots,
                      onSave: (label, watts, slots) => service.upsertAppliance(
                        id: a.id,
                        label: label,
                        watts: watts,
                        backupSlots: slots,
                      ),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => _showApplianceDialog(
                    context,
                    initialLabel: '',
                    initialWatts: 100,
                    initialBackupSlots: 5,
                    onSave: (label, watts, slots) => service.upsertAppliance(
                      label: label,
                      watts: watts,
                      backupSlots: slots,
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add appliance'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _showInputDialog(
  BuildContext context, {
  required String title,
  required String initial,
  required Future<void> Function(String value) onSave,
}) async {
  final controller = TextEditingController(text: initial);
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: title.contains('term') ? 4 : 1,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await onSave(controller.text);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

Future<void> _showApplianceDialog(
  BuildContext context, {
  required String initialLabel,
  required int initialWatts,
  required int initialBackupSlots,
  required Future<void> Function(String label, int watts, int backupSlots)
  onSave,
}) async {
  final labelCtrl = TextEditingController(text: initialLabel);
  final wattsCtrl = TextEditingController(text: '$initialWatts');
  final slotsCtrl = TextEditingController(text: '$initialBackupSlots');
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(initialLabel.isEmpty ? 'Add Appliance' : 'Edit Appliance'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: labelCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: wattsCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Watts'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: slotsCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'Backup boxes (1–10)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await onSave(
              labelCtrl.text,
              int.tryParse(wattsCtrl.text) ?? initialWatts,
              int.tryParse(slotsCtrl.text) ?? initialBackupSlots,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
