import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../services/catalog_service.dart';
import '../theme/app_surfaces.dart';
import '../services/load_pdf_service.dart';
import '../services/load_state_service.dart';

class LoadCalculationScreen extends StatefulWidget {
  const LoadCalculationScreen({super.key});

  @override
  State<LoadCalculationScreen> createState() => _LoadCalculationScreenState();
}

class _LoadCalculationScreenState extends State<LoadCalculationScreen> {
  final Map<String, TextEditingController> _qtyControllers = {};

  @override
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String id) {
    return _qtyControllers.putIfAbsent(id, () => TextEditingController());
  }

  Map<String, int> _readCounts(List<ApplianceConfig> appliances) {
    final map = <String, int>{};
    for (final a in appliances) {
      final text = _controllerFor(a.id).text.trim();
      if (text.isEmpty) continue;
      final n = int.tryParse(text);
      if (n != null && n > 0) map[a.id] = n;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);

    return ValueListenableBuilder<CatalogSnapshot>(
      valueListenable: CatalogService.instance.snapshot,
      builder: (context, snap, _) {
        final counts = _readCounts(snap.appliances);
        final total = snap.appliances.fold<int>(
          0,
          (sum, a) => sum + a.watts * (counts[a.id] ?? 0),
        );

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF000000) : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FIXED GREEN BRAND HEADER BAR
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
                                'Load Calculation',
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

              // GRID AND FIXED METRIC STACK WORKSPACE
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                      children: [
                        Card(
                          elevation: 0,
                          color: isDark ? const Color(0xFF141414) : AppSurfaces.card(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Appliance Data Grid
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const _TableHeading('Appliances'),
                                      const SizedBox(height: 16),
                                      ...snap.appliances.map(
                                        (a) => Container(
                                          height: 48,
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            '${a.label} (${a.watts} W)',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: AppSurfaces.primaryText(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Quantitative Input Matrix
                                Expanded(
                                  child: Column(
                                    children: [
                                      const _TableHeading('Qty'),
                                      const SizedBox(height: 16),
                                      ...snap.appliances.map((a) {
                                        final ctrl = _controllerFor(a.id);
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: SizedBox(
                                            height: 48,
                                            child: TextField(
                                              controller: ctrl,
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
                                              onChanged: (_) => setState(() {}),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                isDense: true,
                                                filled: true,
                                                fillColor: AppSurfaces.fieldFill(context),
                                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // STICKY PREMIUM FROSTED METRICS PANEL
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
                              color: isDark ? Colors.black.withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.85),
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
                                      'Total Connected Load',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AppSurfaces.secondaryText(context),
                                      ),
                                    ),
                                    Text(
                                      '$total W',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                        color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text(
                                    'Download Load Report',
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
                                    final saved = _readCounts(snap.appliances);
                                    LoadStateService.instance.saveCounts(saved);
                                    try {
                                      final path = await LoadPdfService.downloadLoadPdf(
                                        appliances: snap.appliances,
                                        counts: saved,
                                        totalWatts: total,
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
}

class _TableHeading extends StatelessWidget {
  const _TableHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppSurfaces.isDark(context) ? Colors.white70 : AppSurfaces.sectionHeading(context),
        letterSpacing: 0.5,
      ),
    );
  }
}