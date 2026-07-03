import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../data/catalog_data.dart';
import '../models/admin_models.dart';
import '../models/bos_record.dart';
import '../models/quotation.dart';
import '../services/admin_data_service.dart';
import '../services/pdf_service.dart';
import '../services/quotation_calculator.dart';
import '../services/quotation_save_service.dart';
import '../services/terms_service.dart';
import '../theme/app_surfaces.dart';

class QuotationFormScreen extends StatefulWidget {
  final QuotationDraft? initialDraft;
  final bool isEditing;
  final String? editId;

  const QuotationFormScreen({
    super.key,
    this.initialDraft,
    this.isEditing = false,
    this.editId,
  });

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
  final _batteryWarrantyCtrl = TextEditingController();
  final _mountingQtyCtrl = TextEditingController();
  final _mountingPriceCtrl = TextEditingController();
  final _bosPriceCtrl = TextEditingController();
  final _earthingQtyCtrl = TextEditingController();
  final _earthingPriceCtrl = TextEditingController();
  final _installPriceCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  DateTime _issueDate = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));

  String? _selectedPanel;
  String? _selectedInverter;
  String? _selectedBattery;
  String? _selectedMounting;
  String? _selectedEarthingQty;
  String? _selectedBos;  // ← NEW: Selected BOS ID

  final _adminSvc = AdminDataService.instance;
  final _saveService = QuotationSaveService.instance;

  bool _generating = false;
  String? _editId;

  @override
  void initState() {
    super.initState();
    _editId = widget.editId;
    
    _selectedEarthingQty = '0';
    _earthingQtyCtrl.text = '0';
    _earthingPriceCtrl.text = '30000';
    _batteryWarrantyCtrl.text = '5';
    
    // Set default BOS selection
    if (_adminSvc.activeBosRecords.isNotEmpty) {
      _selectedBos = _adminSvc.activeBosRecords.first.id;
    }
    
    if (widget.initialDraft != null) {
      _populateFields(widget.initialDraft!);
    }
  }

  void _populateFields(QuotationDraft draft) {
    _quotedToCtrl.text = draft.quotedTo;
    _contactCtrl.text = draft.contactNo;
    _emailCtrl.text = draft.email;
    _quotationNumCtrl.text = draft.quotationNumber;
    _projectDescCtrl.text = draft.projectDescription;
    _issueDate = draft.issueDate;
    _expiryDate = draft.expiryDate;
    _selectedPanel = draft.panelMake;
    _selectedInverter = draft.inverterMake;
    _selectedBattery = draft.batteryMake;
    _selectedMounting = draft.mountingType;
    _panelQtyCtrl.text = draft.panelQty > 0 ? draft.panelQty.toString() : '';
    _panelPriceCtrl.text = draft.panelUnitPrice > 0 ? draft.panelUnitPrice.toString() : '';
    _inverterQtyCtrl.text = draft.inverterQty > 0 ? draft.inverterQty.toString() : '';
    _inverterPriceCtrl.text = draft.inverterUnitPrice > 0 ? draft.inverterUnitPrice.toString() : '';
    _batteryQtyCtrl.text = draft.batteryQty > 0 ? draft.batteryQty.toString() : '';
    _batteryPriceCtrl.text = draft.batteryUnitPrice > 0 ? draft.batteryUnitPrice.toString() : '';
    _batteryWarrantyCtrl.text = draft.batteryWarranty.isNotEmpty ? draft.batteryWarranty : '5';
    _mountingQtyCtrl.text = draft.mountingQty > 0 ? draft.mountingQty.toString() : '';
    _mountingPriceCtrl.text = draft.mountingUnitPrice > 0 ? draft.mountingUnitPrice.toString() : '';
    _bosPriceCtrl.text = draft.bosUnitPrice > 0 ? draft.bosUnitPrice.toString() : '';
    _earthingQtyCtrl.text = draft.earthingQty > 0 ? draft.earthingQty.toString() : '0';
    _earthingPriceCtrl.text = draft.earthingUnitPrice > 0 ? draft.earthingUnitPrice.toString() : '30000';
    _selectedEarthingQty = draft.earthingQty > 0 ? draft.earthingQty.toString() : '0';
    _installPriceCtrl.text = draft.installationUnitPrice > 0 ? draft.installationUnitPrice.toString() : '';
    _discountCtrl.text = draft.discountedPrice > 0 ? draft.discountedPrice.toString() : '';
    
    // Load selected BOS
    _selectedBos = draft.bosId;
    if (_selectedBos == null || _selectedBos!.isEmpty) {
      if (_adminSvc.activeBosRecords.isNotEmpty) {
        _selectedBos = _adminSvc.activeBosRecords.first.id;
      }
    }
  }

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
    _batteryWarrantyCtrl.dispose();
    _mountingQtyCtrl.dispose();
    _mountingPriceCtrl.dispose();
    _bosPriceCtrl.dispose();
    _earthingQtyCtrl.dispose();
    _earthingPriceCtrl.dispose();
    _installPriceCtrl.dispose();
    _discountCtrl.dispose();
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
      batteryWarranty: _batteryWarrantyCtrl.text.trim().isNotEmpty ? _batteryWarrantyCtrl.text.trim() : '5',
      mountingType: _selectedMounting ?? CatalogData.mountingStructureTypes.first,
      mountingQty: int.tryParse(_mountingQtyCtrl.text) ?? 0,
      mountingUnitPrice: int.tryParse(_mountingPriceCtrl.text) ?? 0,
      bosUnitPrice: int.tryParse(_bosPriceCtrl.text) ?? 0,
      bosId: _selectedBos,
      earthingQty: int.tryParse(_earthingQtyCtrl.text) ?? 0,
      earthingUnitPrice: int.tryParse(_earthingPriceCtrl.text) ?? 30000,
      installationUnitPrice: int.tryParse(_installPriceCtrl.text) ?? 0,
      discountedPrice: int.tryParse(_discountCtrl.text) ?? 0,
    );
  }

  int get _grandTotal => _buildDraft().grandTotal;
  int get _discountedTotal => _buildDraft().discountedPrice;

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

  void _showPreview() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final draft = _buildDraft();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _QuotationPreviewDialog(draft: draft),
    );
  }

  Future<void> _saveDraft() async {
    if (_generating) return;
    
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    
    setState(() => _generating = true);
    try {
      final draft = _buildDraft();
      await _saveService.saveQuotation(draft, customId: _editId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quotation saved successfully!'),
          backgroundColor: AppColors.letterheadGreen,
        ),
      );
      if (widget.isEditing) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
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
                  _earthingCard(context),
                  _installCard(context),
                  const SizedBox(height: 16),
                  _totalBar(context),
                  const SizedBox(height: 12),
                  _discountCard(context),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SSES Solar Quotes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isEditing ? 'Edit Quotation' : 'Solar Quotation Generator',
                      style: const TextStyle(
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
          8, 10, 8, MediaQuery.of(context).padding.bottom + 10),
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
            child: OutlinedButton.icon(
              onPressed: _generating ? null : _showPreview,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Preview'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generating ? null : _saveDraft,
              icon: _generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generating ? null : _generatePdf,
              icon: _generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.letterheadGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _generating ? null : _sharePdf,
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.letterheadGreen,
                side: const BorderSide(color: AppColors.letterheadGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _panelCard(BuildContext context) {
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
        const SizedBox(height: 8),
        // Battery Warranty Input
        Row(
          children: [
            const Text(
              'Warranty (years): ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _batteryWarrantyCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 14,
                  color: AppSurfaces.primaryText(context),
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.letterheadGreen, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: AppSurfaces.fieldFill(context),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
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

  // ─── Balance of System card with dropdown ────────────────────────

  Widget _bosCard(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final bosList = _adminSvc.activeBosRecords;
    
    // Find the selected BOS record
    BosRecord? selectedRecord;
    if (_selectedBos != null) {
      selectedRecord = bosList.where((r) => r.id == _selectedBos).firstOrNull;
    }
    
    // Use the first active BOS as default if nothing selected
    if (selectedRecord == null && bosList.isNotEmpty) {
      selectedRecord = bosList.first;
      _selectedBos = selectedRecord.id;
    }

    final description = selectedRecord?.description ?? '';

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
            const SizedBox(height: 8),
            // BOS Dropdown
            if (bosList.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedBos,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select BOS Type',
                  filled: true,
                  fillColor: AppSurfaces.fieldFill(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppSurfaces.fieldBorder(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.letterheadGreen, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: AppSurfaces.primaryText(context),
                ),
                dropdownColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                items: bosList.map((bos) {
                  return DropdownMenuItem<String>(
                    value: bos.id,
                    child: Text(bos.title),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBos = value;
                  });
                },
              ),
            const SizedBox(height: 8),
            // BOS Description
            if (description.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppSurfaces.accentPanel(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  description,
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

  Widget _earthingCard(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final qty = int.tryParse(_earthingQtyCtrl.text) ?? 0;
    final price = int.tryParse(_earthingPriceCtrl.text) ?? 30000;
    final lineTotal = qty * price;

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
                Expanded(
                  child: Text(
                    'Earthing (Optional)',
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
              child: const Text(
                'Less than 5ohms',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _dropdownQty(
                    context,
                    'Qty',
                    _selectedEarthingQty,
                    ['0', '1', '2', '3'],
                    (v) {
                      setState(() {
                        _selectedEarthingQty = v;
                        _earthingQtyCtrl.text = v ?? '0';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _numericField(context, 'Unit Price (PKR)', _earthingPriceCtrl),
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
        ),
      ),
    );
  }

  Widget _dropdownQty(
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
          .map((e) => DropdownMenuItem(
            value: e,
            child: e == '0' 
                ? const Text('0 Job')
                : Text('$e ${int.parse(e) == 1 ? "Job" : "Jobs"}'),
          ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _installCard(BuildContext context) {
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
                  child: const Text(
                    '7',
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

  Widget _discountCard(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final total = _grandTotal;
    final discountText = _discountCtrl.text.trim();
    final discountValue = int.tryParse(discountText) ?? 0;

    return Card(
      elevation: isDark ? 0 : 1,
      color: isDark ? const Color(0xFF141414) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: discountValue > 0 
              ? Colors.green.withOpacity(0.5) 
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.discount_outlined,
                  color: discountValue > 0 ? Colors.green : Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Discount',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: discountValue > 0 ? Colors.green : Colors.grey.shade600,
                  ),
                ),
                if (discountValue > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the discounted total amount (leave blank if no discount)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Original Total: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  'PKR ${QuotationCalculator.formatCurrency(total)}/-',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppSurfaces.primaryText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Discounted Price: ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _discountCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: discountValue > 0 ? Colors.green : AppSurfaces.primaryText(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixText: 'PKR ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: discountValue > 0 ? Colors.green : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: discountValue > 0 ? Colors.green : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.letterheadGreen, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: discountValue > 0 
                          ? Colors.green.withOpacity(0.05) 
                          : AppSurfaces.fieldFill(context),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            if (discountValue > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Savings:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'PKR ${QuotationCalculator.formatCurrency(total - discountValue)}/-',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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

// ═════════════════════════════════════════════════════════════
// QUOTATION PREVIEW DIALOG
// ═════════════════════════════════════════════════════════════

class _QuotationPreviewDialog extends StatelessWidget {
  final QuotationDraft draft;

  const _QuotationPreviewDialog({required this.draft});

  @override
  Widget build(BuildContext context) {
    final isDark = AppSurfaces.isDark(context);
    final lines = draft.lines;
    final total = draft.grandTotal;
    final discounted = draft.discountedPrice;
    final hasDiscount = discounted > 0;
    final warranties = draft.warranties;
    final currency = NumberFormat('#,##0', 'en_US');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header - matches PDF header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Quotation Preview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Body - matches PDF content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Information - matches PDF
                    _previewField('Quoted To:', draft.quotedTo.isNotEmpty ? draft.quotedTo.toUpperCase() : '-'),
                    _previewField('Contact No.:', draft.contactNo.isNotEmpty ? draft.contactNo : '-'),
                    _previewField('Email:', draft.email.isNotEmpty ? draft.email : '-'),
                    _previewField('Quotation Number:', draft.quotationNumber.isNotEmpty ? draft.quotationNumber : '-'),
                    _previewField('Issue Date:', DateFormat('dd-MM-yyyy').format(draft.issueDate)),
                    _previewField('Expiry Date:', DateFormat('dd-MM-yyyy').format(draft.expiryDate)),
                    if (draft.projectDescription.isNotEmpty)
                      _previewField('Project Description:', draft.projectDescription),
                    
                    const Divider(height: 24),
                    
                    // Title - matches PDF
                    Center(
                      child: Text(
                        'Sales Quotation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.letterheadGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Table - matches PDF table style
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          // Table Header - matches PDF
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 35, child: Text('Sr#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                                Expanded(flex: 2, child: Text('Item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                                Expanded(flex: 2, child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                                const SizedBox(width: 50, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                                const SizedBox(width: 70, child: Text('Unit Price', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                                const SizedBox(width: 70, child: Text('Line Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                              ],
                            ),
                          ),
                          // Table Rows - matches PDF
                          ...lines.map((line) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 35,
                                  child: Text(
                                    '${line.serialNo}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppSurfaces.primaryText(context),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    line.item,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppSurfaces.primaryText(context),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    line.makeDescription,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppSurfaces.secondaryText(context),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    line.quantityLabel,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppSurfaces.primaryText(context),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    line.unitPrice > 0 ? currency.format(line.unitPrice) : '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppSurfaces.primaryText(context),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    line.lineTotal > 0 ? currency.format(line.lineTotal) : '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppSurfaces.primaryText(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Total Amount - Green background, Black text
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total Amount = ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'PKR ${currency.format(total)}/-',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: hasDiscount ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Discounted Total - Green background, Black text
                    if (hasDiscount) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Discounted Total = ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'PKR ${currency.format(discounted)}/-',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Warranty - matches PDF
                    if (warranties.isNotEmpty) ...[
                      Text(
                        'Warranty:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppSurfaces.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...warranties.map((w) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 2),
                        child: Text(
                          '- $w',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppSurfaces.secondaryText(context),
                          ),
                        ),
                      )),
                      const SizedBox(height: 12),
                    ],
                    
                    // Terms - matches PDF
                    Text(
                      'Terms and Condition:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppSurfaces.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...AdminDataService.instance.activeTerms.take(3).map((term) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '- ${term.description}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppSurfaces.secondaryText(context),
                        ),
                      ),
                    )),
                    if (AdminDataService.instance.activeTerms.length > 3)
                      Text(
                        '... and ${AdminDataService.instance.activeTerms.length - 3} more terms',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: AppSurfaces.secondaryText(context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Footer buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}