import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog_data.dart';
import '../models/quotation.dart';

class SavedQuotation {
  final String id;
  final String label;
  final DateTime savedAt;
  final QuotationDraft draft;

  const SavedQuotation({
    required this.id,
    required this.label,
    required this.savedAt,
    required this.draft,
  });
}

class QuotationStorageService {
  QuotationStorageService._();
  static final QuotationStorageService instance = QuotationStorageService._();

  static const _prefKey = 'saved_quotations_v1';

  final ValueNotifier<List<SavedQuotation>> saved = ValueNotifier([]);

  Future<void> init() async {
    await reload();
  }

  Future<void> reload() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null || raw.isEmpty) {
      saved.value = [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      saved.value = [
        for (final item in list)
          _fromMap(item as Map<String, dynamic>),
      ]..sort((a, b) => b.savedAt.compareTo(a.savedAt));
    } catch (e) {
      debugPrint('Load quotations failed: $e');
      saved.value = [];
    }
  }

  Future<void> saveDraft(QuotationDraft draft) async {
    final id = draft.quotationNumber.trim().isEmpty
        ? 'q_${DateTime.now().millisecondsSinceEpoch}'
        : draft.quotationNumber.trim();
    final label = draft.quotedTo.trim().isEmpty
        ? (draft.quotationNumber.trim().isEmpty ? 'Untitled quote' : draft.quotationNumber.trim())
        : draft.quotedTo.trim();
    final entry = SavedQuotation(
      id: id,
      label: label,
      savedAt: DateTime.now(),
      draft: draft,
    );
    final list = [...saved.value];
    list.removeWhere((e) => e.id == id);
    list.insert(0, entry);
    saved.value = list;
    await _persist();
  }

  Future<void> delete(String id) async {
    saved.value = saved.value.where((e) => e.id != id).toList();
    await _persist();
  }

  /// Returns a detached copy so edits do not mutate the saved list entry.
  QuotationDraft cloneDraft(QuotationDraft draft) =>
      _draftFromMap(_draftToMap(draft));

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode([
      for (final s in saved.value) _toMap(s),
    ]);
    await prefs.setString(_prefKey, encoded);
  }

  static Map<String, dynamic> _toMap(SavedQuotation s) => {
    'id': s.id,
    'label': s.label,
    'savedAt': s.savedAt.toIso8601String(),
    'draft': _draftToMap(s.draft),
  };

  static SavedQuotation _fromMap(Map<String, dynamic> m) => SavedQuotation(
    id: m['id'] as String,
    label: m['label'] as String? ?? 'Quote',
    savedAt: DateTime.parse(m['savedAt'] as String),
    draft: _draftFromMap(m['draft'] as Map<String, dynamic>),
  );

  static Map<String, dynamic> _draftToMap(QuotationDraft d) => {
    'quotedTo': d.quotedTo,
    'contactNo': d.contactNo,
    'email': d.email,
    'quotationNumber': d.quotationNumber,
    'issueDate': d.issueDate.toIso8601String(),
    'expiryDate': d.expiryDate.toIso8601String(),
    'projectDescription': d.projectDescription,
    'panelMake': d.panelMake,
    'panelQty': d.panelQty,
    'panelUnitPrice': d.panelUnitPrice,
    'inverterMake': d.inverterMake,
    'inverterQty': d.inverterQty,
    'inverterUnitPrice': d.inverterUnitPrice,
    'batteryMake': d.batteryMake,
    'batteryQty': d.batteryQty,
    'batteryUnitPrice': d.batteryUnitPrice,
    'mountingType': d.mountingType,
    'mountingQty': d.mountingQty,
    'mountingUnitPrice': d.mountingUnitPrice,
    'bosUnitPrice': d.bosUnitPrice,
    'installationUnitPrice': d.installationUnitPrice,
  };

  static QuotationDraft _draftFromMap(Map<String, dynamic> m) => QuotationDraft(
    quotedTo: m['quotedTo'] as String? ?? '',
    contactNo: m['contactNo'] as String? ?? '',
    email: m['email'] as String? ?? '',
    quotationNumber: m['quotationNumber'] as String? ?? '',
    issueDate: DateTime.tryParse(m['issueDate'] as String? ?? '') ?? DateTime.now(),
    expiryDate: DateTime.tryParse(m['expiryDate'] as String? ?? '') ??
        DateTime.now().add(const Duration(days: 7)),
    projectDescription: m['projectDescription'] as String? ?? '',
    panelMake: m['panelMake'] as String?,
    panelQty: (m['panelQty'] as num?)?.toInt() ?? 0,
    panelUnitPrice: (m['panelUnitPrice'] as num?)?.toInt() ?? 0,
    inverterMake: m['inverterMake'] as String?,
    inverterQty: (m['inverterQty'] as num?)?.toInt() ?? 0,
    inverterUnitPrice: (m['inverterUnitPrice'] as num?)?.toInt() ?? 0,
    batteryMake: m['batteryMake'] as String?,
    batteryQty: (m['batteryQty'] as num?)?.toInt() ?? 0,
    batteryUnitPrice: (m['batteryUnitPrice'] as num?)?.toInt() ?? 0,
    mountingType: m['mountingType'] as String? ??
        CatalogData.mountingStructureTypes.first,
    mountingQty: (m['mountingQty'] as num?)?.toInt() ?? 0,
    mountingUnitPrice: (m['mountingUnitPrice'] as num?)?.toInt() ?? 0,
    bosUnitPrice: (m['bosUnitPrice'] as num?)?.toInt() ?? 0,
    installationUnitPrice: (m['installationUnitPrice'] as num?)?.toInt() ?? 0,
  );
}
