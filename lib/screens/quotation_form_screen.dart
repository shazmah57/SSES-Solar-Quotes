import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../data/catalog_data.dart';
import '../models/admin_models.dart';
import '../models/quotation.dart';
import '../services/admin_data_service.dart';
import '../services/pdf_service.dart';
import '../services/quotation_calculator.dart';
import '../services/terms_service.dart';
import '../theme/app_surfaces.dart';

class QuotationFormScreen extends StatefulWidget {
  const QuotationFormScreen({super.key});

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd-MM-yyyy');

  final _quotedToCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _quotationNumCtrl = TextEditingController();
  final _projectDescCtrl = TextEditingController();

  final _panelQtyCtrl = TextEditingController();
  final _panelPriceCtrl = TextEditingController();
  final _inverterQtyCtrl = TextEditingController();
  final _inverterPriceCtrl = TextEditingController();
  final _batteryQtyCtrl = TextEditingController();
  final _batteryPriceCtrl = TextEditingController();
  final _mountingQtyCtrl = TextEditingController();
  final _mountingPriceCtrl = TextEditingController();
  final _bosPriceCtrl = TextEditingController();
  final _installPriceCtrl = TextEditingController();

  DateTime _issueDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  String? _selectedPanel;
  String? _selectedInverter;
  String? _selectedBattery;
  String? _selectedMounting;

  final _adminSvc = AdminDataService.instance;

  bool _generating = false;

  @override
  void dispose() {
    _quotedToCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _quotationNumCtrl.dispose();
    _projectDescCtrl.dispose();
    _panelQtyCtrl.dispose();
    _panelPriceCtrl.dispose();
    _inverterQtyCtrl.dispose();
    _inverterPriceCtrl.dispose();
    _batteryQtyCtrl.dispose();
    _batteryPriceCtrl.dispose();
    _mountingQtyCtrl.dispose();
    _mountingPriceCtrl.dispose();
    _bosPriceCtrl.dispose();
    _installPriceCtrl.dispose();
    super.dispose();
  }

  QuotationDraft _buildDraft() {
    return QuotationDraft(
      quotedTo: _quotedToCtrl.text.trim(),
      contactNo: _contactCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      quotationNumber: _quotationNumCtrl.text.trim(),
      issueDate: _issueDate,
      expiryDate: _expiryDate,
      projectDescription: _projectDescCtrl.text.trim(),
      panelMake: _selectedPanel,
      panelQty: int.tryParse(_panelQtyCtrl.text) ?? 0,
      panelUnitPrice: int.tryParse(_panelPriceCtrl.text) ?? 0,
      inverterMake: _selectedInverter,
      inverterQty: int.tryParse(_inverterQtyCtrl.text) ?? 0,
      inverterUnitPrice: int.tryParse(_inverterPriceCtrl.text) ?? 0,
      batteryMake: _selectedBattery,
      batteryQty: int.tryParse(_batteryQtyCtrl.text) ?? 0,
      batteryUnitPrice: int.tryParse(_batteryPriceCtrl.text) ?? 0,
      mountingType: _selectedMounting ?? CatalogData.mountingStructureTypes.first,
      mountingQty: int.tryParse(_mountingQtyCtrl.text) ?? 0,
      mountingUnitPrice: int.tryParse(_mountingPriceCtrl.text) ?? 0,
      bosUnitPrice: int.tryParse(_bosPriceCtrl.text) ?? 0,
      installationUnitPrice: int.tryParse(_installPriceCtrl.text) ?? 0,
    );
  }

  int get _grandTotal => _buildDraft().grandTotal;

  Future<void> _pickDate(BuildContext context, bool isIssue) async {
    final initial = isIssue ? _issueDate : _expiryDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.letterheadGreen,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isIssue) {
          _issueDate = picked;
          if (_expiryDate.isBefore(_issueDate)) {
            _expiryDate = _issueDate.add(const Duration(days: 7));
          }
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      final draft = _buildDraft();
      await PdfService.downloadQuotation(
        draft,
        onSaved: (path) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved: $path'),
              backgroundColor: AppColors.letterheadGreen,
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _sharePdf() async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      await PdfService.shareQuotationWhatsApp(_buildDraft());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  _sectionTitle(context, 'Client Information'),
                  const SizedBox(height: 8),
                  _textField(context, 'Quoted To', _quotedToCtrl,
                      icon: Icons.person_outline),
                  _textField(context, 'Contact No.', _contactCtrl,
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone),
                  _textField(context, 'Email', _emailCtrl,
                      icon: Icons.email_outlined,
                      keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _sectionTitle(context, 'Quotation Details'),
                  const SizedBox(height: 8),
                  _textField(
                      context, 'Quotation Number', _quotationNumCtrl,
                      icon: Icons.tag, hint: 'e.g. SSES-S-3493'),
                  _dateRow(context),
                  const SizedBox(height: 8),
                  _textField(
                      context, 'Project Description', _projectDescCtrl,
                      icon: Icons.description_outlined,
                      maxLines: 2,
                      hint:
                          'e.g. 6.16kW Solar with 8kW Hybrid Inverter & 5kWh Battery'),
                  const SizedBox(height: 16),
                  _sectionTitle(context, 'Line Items'),
                  const SizedBox(height: 8),
                  _panelCard(context),
                  _inverterCard(context),
                  _batteryCard(context),
                  _mountingCard(context),
                  _bosCard(context),
                  _installCard(context),
                  const SizedBox(height: 16),
                  _totalBar(context),
                  const SizedBox(height: 16),
                  _sectionTitle(context, 'Warranty'),
                  const SizedBox(height: 4),
                  _warrantyPreview(context),
                  const SizedBox(height: 16),
                  _sectionTitle(context, 'Terms & Conditions'),
                  const SizedBox(height: 4),
                  _termsPreview(context),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Material(
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
                      'Solar Quotation Generator',
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
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generating ? null : _generatePdf,
              icon: _generating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf, size: 20),
              label: const Text('Download PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.letterheadGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _generating ? null : _sharePdf,
              icon: const Icon(Icons.share, size: 20),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.letterheadGreen,
                side: const BorderSide(color: AppColors.letterheadGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section title ─────────────────────────────────────────────

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppDimens.formSectionTitle,
          fontWeight: FontWeight.bold,
          color: AppSurfaces.sectionHeading(context),
        ),
      ),
    );
  }

  // ─── Text field ────────────────────────────────────────────────

  Widget _textField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? hint,
  }) {
    final isDark = AppSurfaces.isDark(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: AppDimens.formFontSize,
          color: AppSurfaces.primaryText(context),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: true,
          fillColor: AppSurfaces.fieldFill(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.letterheadGreen, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ─── Numeric field (for qty / price) ───────────────────────────

  Widget _numericField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    String? prefix,
  }) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: AppDimens.formFontSize,
          color: AppSurfaces.primaryText(context),
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          filled: true,
          fillColor: AppSurfaces.fieldFill(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AppColors.letterheadGreen, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ─── Date row ──────────────────────────────────────────────────

  Widget _dateRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: _dateTile(context, 'Issue Date', _issueDate, true)),
          const SizedBox(width: 12),
          Expanded(
              child: _dateTile(context, 'Expiry Date', _expiryDate, false)),
        ],
      ),
    );
  }

  Widget _dateTile(
      BuildContext context, String label, DateTime date, bool isIssue) {
    final isDark = AppSurfaces.isDark(context);
    return InkWell(
      onTap: () => _pickDate(context, isIssue),
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          filled: true,
          fillColor: AppSurfaces.fieldFill(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        child: Text(
          _dateFormat.format(date),
          style: TextStyle(
            fontSize: AppDimens.formFontSize,
            color: AppSurfaces.primaryText(context),
          ),
        ),
      ),
    );
  }

  // ─── Solar Panel card (admin-driven) ────────────────────────────

  Widget _panelCard(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final activePanels = _adminSvc.activePanels;
    final panelNames = activePanels.map((p) => p.displayName).toList();
    final qty = int.tryParse(_panelQtyCtrl.text) ?? 0;
    final price = int.tryParse(_panelPriceCtrl.text) ?? 0;
    final lineTotal = qty * price;

    return _itemCardShell(
      context,
      serialNo: 1,
      title: 'Solar Panels',
      children: [
        _dropdown(context, 'Make / Description', _selectedPanel, panelNames,
            (v) {
          setState(() {
            _selectedPanel = v;
            final match =
                activePanels.where((p) => p.displayName == v).firstOrNull;
            if (match != null && match.unitPrice > 0) {
              _panelPriceCtrl.text = match.unitPrice.toString();
            }
          });
        }),
        const SizedBox(height: 10),
        Row(
          children: [
            _numericField(context, 'Qty', _panelQtyCtrl),
            const SizedBox(width: 12),
            _numericField(context, 'Unit Price (PKR)', _panelPriceCtrl),
          ],
        ),
        if (lineTotal > 0) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Line Total: PKR ${QuotationCalculator.formatCurrency(lineTotal)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppSurfaces.sectionHeading(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Inverter card (admin-driven) ──────────────────────────────

  Widget _inverterCard(BuildContext context) {
    final activeInverters = _adminSvc.activeInverters;
    final names = activeInverters.map((p) => p.displayName).toList();
    final qty = int.tryParse(_inverterQtyCtrl.text) ?? 0;
    final price = int.tryParse(_inverterPriceCtrl.text) ?? 0;
    final lineTotal = qty * price;

    return _itemCardShell(
      context,
      serialNo: 2,
      title: 'Solar Inverter',
      children: [
        _dropdown(context, 'Make / Description', _selectedInverter, names,
            (v) {
          setState(() {
            _selectedInverter = v;
            final match =
                activeInverters.where((p) => p.displayName == v).firstOrNull;
            if (match != null && match.unitPrice > 0) {
              _inverterPriceCtrl.text = match.unitPrice.toString();
            }
          });
        }),
        const SizedBox(height: 10),
        Row(
          children: [
            _numericField(context, 'Qty', _inverterQtyCtrl),
            const SizedBox(width: 12),
            _numericField(context, 'Unit Price (PKR)', _inverterPriceCtrl),
          ],
        ),
        if (lineTotal > 0) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Line Total: PKR ${QuotationCalculator.formatCurrency(lineTotal)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppSurfaces.sectionHeading(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Battery card (admin-driven) ───────────────────────────────

  Widget _batteryCard(BuildContext context) {
    final activeBatteries = _adminSvc.activeBatteries;
    final names = activeBatteries.map((p) => p.displayName).toList();
    final qty = int.tryParse(_batteryQtyCtrl.text) ?? 0;
    final price = int.tryParse(_batteryPriceCtrl.text) ?? 0;
    final lineTotal = qty * price;

    return _itemCardShell(
      context,
      serialNo: 3,
      title: 'Battery',
      children: [
        _dropdown(context, 'Make / Description', _selectedBattery, names, (v) {
          setState(() {
            _selectedBattery = v;
            final match =
                activeBatteries.where((p) => p.displayName == v).firstOrNull;
            if (match != null && match.unitPrice > 0) {
              _batteryPriceCtrl.text = match.unitPrice.toString();
            }
          });
        }),
        const SizedBox(height: 10),
        Row(
          children: [
            _numericField(context, 'Qty', _batteryQtyCtrl),
            const SizedBox(width: 12),
            _numericField(context, 'Unit Price (PKR)', _batteryPriceCtrl),
          ],
        ),
        if (lineTotal > 0) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Line Total: PKR ${QuotationCalculator.formatCurrency(lineTotal)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppSurfaces.sectionHeading(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Reusable card shell ───────────────────────────────────────

  Widget _itemCardShell(
    BuildContext context, {
    required int serialNo,
    required String title,
    required List<Widget> children,
  }) {
    final isDark = AppSurfaces.isDark(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF141414) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      AppColors.letterheadGreen.withOpacity(0.15),
                  child: Text(
                    '$serialNo',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.letterheadGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppDimens.formCardTitle,
                    fontWeight: FontWeight.w600,
                    color: AppSurfaces.primaryText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  // ─── Mounting structure card (admin-driven) ────────────────────

  Widget _mountingCard(BuildContext context) {
    final activeStructures = _adminSvc.activeStructures;
    final names = activeStructures.map((s) => s.structureName).toList();
    final qty = int.tryParse(_mountingQtyCtrl.text) ?? 0;
    final price = int.tryParse(_mountingPriceCtrl.text) ?? 0;
    final lineTotal = qty * price;

    String desc = '';
    if (_selectedMounting != null) {
      final match = activeStructures
          .where((s) => s.structureName == _selectedMounting)
          .firstOrNull;
      desc = match?.materialDetails ?? CatalogData.mountingDescription(_selectedMounting!);
    }

    return _itemCardShell(
      context,
      serialNo: 4,
      title: 'Solar Mounting Structure',
      children: [
        _dropdown(context, 'Structure Type', _selectedMounting, names, (v) {
          setState(() {
            _selectedMounting = v;
            final match = activeStructures
                .where((s) => s.structureName == v)
                .firstOrNull;
            if (match != null && match.unitPrice > 0) {
              _mountingPriceCtrl.text = match.unitPrice.toString();
            }
          });
        }),
        if (desc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppSurfaces.accentPanel(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                color: AppSurfaces.secondaryText(context),
                height: 1.4,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            _numericField(context, 'Qty', _mountingQtyCtrl),
            const SizedBox(width: 12),
            _numericField(context, 'Unit Price (PKR)', _mountingPriceCtrl),
          ],
        ),
        if (lineTotal > 0) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Line Total: PKR ${QuotationCalculator.formatCurrency(lineTotal)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppSurfaces.sectionHeading(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Balance of System card ────────────────────────────────────

  Widget _bosCard(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final price = int.tryParse(_bosPriceCtrl.text) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF141414) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      AppColors.letterheadGreen.withOpacity(0.15),
                  child: const Text(
                    '5',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.letterheadGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Balance of System',
                    style: TextStyle(
                      fontSize: AppDimens.formCardTitle,
                      fontWeight: FontWeight.w600,
                      color: AppSurfaces.primaryText(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppSurfaces.accentPanel(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'AC Cables & DC Cables, SPDs, Circuit Breakers, PVC pipes & Allied Accessories\n\n${CatalogData.balanceOfSystemDescription}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppSurfaces.secondaryText(context),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Qty: Estimated',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _numericField(context, 'Total Price (PKR)', _bosPriceCtrl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Installation & Transport card ─────────────────────────────

  Widget _installCard(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final price = int.tryParse(_installPriceCtrl.text) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF141414) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      AppColors.letterheadGreen.withOpacity(0.15),
                  child: const Text(
                    '6',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.letterheadGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Installation & Transport',
                  style: TextStyle(
                    fontSize: AppDimens.formCardTitle,
                    fontWeight: FontWeight.w600,
                    color: AppSurfaces.primaryText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Qty: 1 Job',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _numericField(
                    context, 'Total Price (PKR)', _installPriceCtrl),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dropdown ──────────────────────────────────────────────────

  Widget _dropdown(
    BuildContext context,
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    final isDark = AppSurfaces.isDark(context);
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppSurfaces.fieldFill(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppColors.letterheadGreen, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      style: TextStyle(
        fontSize: 15,
        color: AppSurfaces.primaryText(context),
      ),
      dropdownColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  // ─── Total bar ─────────────────────────────────────────────────

  Widget _totalBar(BuildContext context) {
    final total = _grandTotal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppSurfaces.totalPanel(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.letterheadGreen.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppSurfaces.primaryText(context),
            ),
          ),
          Text(
            'PKR ${QuotationCalculator.formatCurrency(total)}/-',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppSurfaces.sectionHeading(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Warranty preview ──────────────────────────────────────────

  Widget _warrantyPreview(BuildContext context) {
    final warranties = _buildDraft().warranties;
    if (warranties.isEmpty) {
      return Text(
        'Fill in items above to see warranty details.',
        style: TextStyle(
          fontSize: 13,
          color: AppSurfaces.secondaryText(context),
          fontStyle: FontStyle.italic,
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppSurfaces.accentPanel(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: warranties
            .map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('  •  ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        w,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppSurfaces.primaryText(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ─── Terms preview ─────────────────────────────────────────────

  Widget _termsPreview(BuildContext context) {
    return ValueListenableBuilder<List<TermsRecord>>(
      valueListenable: _adminSvc.terms,
      builder: (context, allTerms, _) {
        final active = allTerms.where((t) => t.active).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        if (active.isEmpty) {
          return Text(
            'No terms configured.',
            style: TextStyle(
              fontSize: 13,
              color: AppSurfaces.secondaryText(context),
              fontStyle: FontStyle.italic,
            ),
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppSurfaces.accentPanel(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < active.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${i + 1}.  ${active[i].description}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppSurfaces.primaryText(context),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
