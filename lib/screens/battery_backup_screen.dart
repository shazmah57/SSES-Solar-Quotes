import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../services/catalog_service.dart';
import '../theme/app_surfaces.dart';
import '../services/load_pdf_service.dart';
import '../services/load_state_service.dart';

class BatteryBackupScreen extends StatefulWidget {
  const BatteryBackupScreen({super.key});

  @override
  State<BatteryBackupScreen> createState() => _BatteryBackupScreenState();
}

class _BatteryBackupScreenState extends State<BatteryBackupScreen> {
  final Map<String, List<(TextEditingController qty, TextEditingController hrs)>> _slotControllers = {};

  @override
  void dispose() {
    for (final slots in _slotControllers.values) {
      for (final pair in slots) {
        pair.$1.dispose();
        pair.$2.dispose();
      }
    }
    super.dispose();
  }

  List<(TextEditingController, TextEditingController)> _slotsFor(ApplianceConfig appliance) {
    final existing = _slotControllers[appliance.id];
    if (existing != null && existing.length == appliance.backupSlots) {
      return existing;
    }
    for (final pair in existing ?? const []) {
      pair.$1.dispose();
      pair.$2.dispose();
    }
    final list = List.generate(
      appliance.backupSlots,
      (_) => (TextEditingController(), TextEditingController()),
    );
    _slotControllers[appliance.id] = list;
    return list;
  }

  Map<String, List<(int qty, int hours)>> _readPlans(List<ApplianceConfig> appliances) {
    final out = <String, List<(int, int)>>{};
    for (final a in appliances) {
      final rows = <(int, int)>[];
      for (final pair in _slotsFor(a)) {
        final q = int.tryParse(pair.$1.text.trim()) ?? 0;
        final h = int.tryParse(pair.$2.text.trim()) ?? 0;
        if (q > 0 && h > 0) rows.add((q, h));
      }
      out[a.id] = rows;
    }
    return out;
  }

  int _calculateWh(List<ApplianceConfig> appliances) {
    final plans = _readPlans(appliances);
    var sum = 0;
    for (final a in appliances) {
      for (final p in plans[a.id] ?? const []) {
        final qty = p.$1;
        final hours = p.$2;
        sum += (a.watts * qty * hours).toInt();
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final counts = LoadStateService.instance.applianceCounts.value;

    return ValueListenableBuilder<CatalogSnapshot>(
      valueListenable: CatalogService.instance.snapshot,
      builder: (context, snap, _) {
        final totalWh = _calculateWh(snap.appliances);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF000000) : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FIXED BRANDED HEADER
              Material(
                color: AppColors.letterheadGreen,
                elevation: 1,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SSES Solar Quotes',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Battery Backup Calculator',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // LIST OVERLAY AND STICKY FOOTER WRAPPER
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
                      children: [
                        Text(
                          'Note: Backup window is from 6 PM to 8 AM (14 hours).',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white60 : AppSurfaces.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...snap.appliances.map(
                          (a) => _applianceCard(a, counts[a.id] ?? 0),
                        ),
                      ],
                    ),

                    // STICKY BOTTOM BAR CONTAINER WITH EMBEDDED MICRO ANIMATION
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.75) : Colors.white.withOpacity(0.85),
                              border: Border(
                                top: BorderSide(
                                  color: isDark ? Colors.white10 : Colors.black12,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Required Energy Storage',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppSurfaces.secondaryText(context),
                                      ),
                                    ),
                                    // FADE AND SLIDE ROLL EFFECTS ON CHANGE
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 220),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0.0, 0.2),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        '$totalWh Wh',
                                        key: ValueKey<int>(totalWh),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                          color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text(
                                    'Download Backup Analysis',
                                    style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.2),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final path = await LoadPdfService.downloadBackupPdf(
                                        appliances: snap.appliances,
                                        availableCounts: counts,
                                        schedule: _readPlans(snap.appliances),
                                        wattHours: totalWh,
                                      );
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Saved to $path')),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not save PDF: $e')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _applianceCard(ApplianceConfig appliance, int availableQty) {
    final slots = _slotsFor(appliance);
    final isDark = AppSurfaces.isDark(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: isDark ? const Color(0xFF141414) : AppSurfaces.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${appliance.label} (${appliance.watts} W) — Connected Qty: $availableQty',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppSurfaces.primaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Quantity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppSurfaces.sectionHeading(context),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hours',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppSurfaces.sectionHeading(context),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...slots.map((pair) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: pair.$1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppSurfaces.primaryText(context),
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                            filled: true,
                            fillColor: AppSurfaces.fieldFill(context),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: pair.$2,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppSurfaces.primaryText(context),
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                            filled: true,
                            fillColor: AppSurfaces.fieldFill(context),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}