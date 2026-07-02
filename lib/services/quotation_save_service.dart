import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_quotation.dart';
import '../models/quotation.dart';

class QuotationSaveService {
  QuotationSaveService._();
  static final QuotationSaveService instance = QuotationSaveService._();

  static const String _prefKey = 'saved_quotations';
  static const String _customPathKey = 'quotations_custom_path';
  
  String? _customPath;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _customPath = prefs.getString(_customPathKey);
  }

  Future<void> setCustomPath(String? path) async {
    final trimmed = path?.trim();
    _customPath = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    final prefs = await SharedPreferences.getInstance();
    if (_customPath == null) {
      await prefs.remove(_customPathKey);
    } else {
      await prefs.setString(_customPathKey, _customPath!);
    }
  }

  String? get customPath => _customPath;

  Future<Directory> getQuotationsDirectory() async {
    // For web, use a different approach
    if (kIsWeb) {
      // On web, we store in memory and use SharedPreferences
      final docsDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${docsDir.path}/SSES_Quotations');
      return dir;
    }
    
    if (_customPath != null) {
      final dir = Directory(_customPath!);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docsDir.path}/SSES_Quotations');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> getCurrentPath() async {
    final dir = await getQuotationsDirectory();
    return dir.path;
  }

  Future<void> saveQuotation(QuotationDraft draft, {String? customId}) async {
    final savedQuotation = SavedQuotation(
      id: customId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      quotationNumber: draft.quotationNumber.trim().isEmpty 
          ? 'Q-${DateTime.now().millisecondsSinceEpoch}' 
          : draft.quotationNumber.trim(),
      quotedTo: draft.quotedTo,
      contactNo: draft.contactNo,
      email: draft.email,
      issueDate: draft.issueDate,
      expiryDate: draft.expiryDate,
      projectDescription: draft.projectDescription,
      panelMake: draft.panelMake,
      panelQty: draft.panelQty,
      panelUnitPrice: draft.panelUnitPrice,
      inverterMake: draft.inverterMake,
      inverterQty: draft.inverterQty,
      inverterUnitPrice: draft.inverterUnitPrice,
      batteryMake: draft.batteryMake,
      batteryQty: draft.batteryQty,
      batteryUnitPrice: draft.batteryUnitPrice,
      batteryWarranty: draft.batteryWarranty,
      mountingType: draft.mountingType,
      mountingQty: draft.mountingQty,
      mountingUnitPrice: draft.mountingUnitPrice,
      bosUnitPrice: draft.bosUnitPrice,
      earthingQty: draft.earthingQty,
      earthingUnitPrice: draft.earthingUnitPrice,
      installationUnitPrice: draft.installationUnitPrice,
      discountedPrice: draft.discountedPrice,
      savedAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    // Save to SharedPreferences as well (for web support)
    final allQuotes = await getAllQuotations();
    final existingIndex = allQuotes.indexWhere((q) => q.id == savedQuotation.id);
    
    List<SavedQuotation> newList;
    if (existingIndex >= 0) {
      newList = [...allQuotes];
      newList[existingIndex] = savedQuotation;
    } else {
      newList = [savedQuotation, ...allQuotes];
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(newList.map((q) => q.toJson()).toList()));

    // Also try to save to file system (if not web)
    if (!kIsWeb) {
      try {
        final dir = await getQuotationsDirectory();
        final file = File('${dir.path}/${savedQuotation.id}.json');
        await file.writeAsString(jsonEncode(savedQuotation.toJson()));
      } catch (e) {
        // File system error - but we already saved to SharedPreferences
        print('File save error (ignored): $e');
      }
    }
  }

  Future<void> _updateIndex(SavedQuotation quote) async {
    final index = await getAllQuotations();
    final existingIndex = index.indexWhere((q) => q.id == quote.id);
    
    List<SavedQuotation> newIndex;
    if (existingIndex >= 0) {
      newIndex = [...index];
      newIndex[existingIndex] = quote;
    } else {
      newIndex = [quote, ...index];
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(newIndex.map((q) => q.toJson()).toList()));
  }

  Future<List<SavedQuotation>> getAllQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null || raw.isEmpty) return [];
    
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((json) => SavedQuotation.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<SavedQuotation?> getQuotation(String id) async {
    // Try to get from SharedPreferences first
    final all = await getAllQuotations();
    final found = all.where((q) => q.id == id).firstOrNull;
    if (found != null) return found;
    
    // If not found, try file system (for non-web)
    if (!kIsWeb) {
      try {
        final dir = await getQuotationsDirectory();
        final file = File('${dir.path}/$id.json');
        if (!await file.exists()) return null;
        
        final content = await file.readAsString();
        return SavedQuotation.fromJson(jsonDecode(content));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> deleteQuotation(String id) async {
    // Remove from SharedPreferences
    final index = await getAllQuotations();
    final newIndex = index.where((q) => q.id != id).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(newIndex.map((q) => q.toJson()).toList()));
    
    // Also delete from file system (if not web)
    if (!kIsWeb) {
      try {
        final dir = await getQuotationsDirectory();
        final file = File('${dir.path}/$id.json');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore file system errors
      }
    }
  }

  Future<void> updateQuotation(SavedQuotation quote) async {
    final updatedQuote = quote.copyWith(lastModified: DateTime.now());
    
    // Update SharedPreferences
    await _updateIndex(updatedQuote);
    
    // Update file system (if not web)
    if (!kIsWeb) {
      try {
        final dir = await getQuotationsDirectory();
        final file = File('${dir.path}/${quote.id}.json');
        await file.writeAsString(jsonEncode(updatedQuote.toJson()));
      } catch (e) {
        // Ignore file system errors
      }
    }
  }

  QuotationDraft toDraft(SavedQuotation saved) {
    return QuotationDraft(
      quotedTo: saved.quotedTo,
      contactNo: saved.contactNo,
      email: saved.email,
      quotationNumber: saved.quotationNumber,
      issueDate: saved.issueDate,
      expiryDate: saved.expiryDate,
      projectDescription: saved.projectDescription,
      panelMake: saved.panelMake,
      panelQty: saved.panelQty,
      panelUnitPrice: saved.panelUnitPrice,
      inverterMake: saved.inverterMake,
      inverterQty: saved.inverterQty,
      inverterUnitPrice: saved.inverterUnitPrice,
      batteryMake: saved.batteryMake,
      batteryQty: saved.batteryQty,
      batteryUnitPrice: saved.batteryUnitPrice,
      batteryWarranty: saved.batteryWarranty ?? '5',
      mountingType: saved.mountingType,
      mountingQty: saved.mountingQty,
      mountingUnitPrice: saved.mountingUnitPrice,
      bosUnitPrice: saved.bosUnitPrice,
      earthingQty: saved.earthingQty,
      earthingUnitPrice: saved.earthingUnitPrice,
      installationUnitPrice: saved.installationUnitPrice,
      discountedPrice: saved.discountedPrice,
    );
  }
}