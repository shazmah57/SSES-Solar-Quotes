import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog_data.dart';
import '../models/admin_models.dart';
import 'catalog_service.dart';

class AdminDataService {
  AdminDataService._();
  static final AdminDataService instance = AdminDataService._();

  static const _colPanels = 'quote_panels';
  static const _colInverters = 'quote_inverters';
  static const _colBatteries = 'quote_batteries';
  static const _colStructures = 'quote_structures';
  static const _colTerms = 'quote_terms';

  static const _keyPanels = 'admin_panels';
  static const _keyInverters = 'admin_inverters';
  static const _keyBatteries = 'admin_batteries';
  static const _keyStructures = 'admin_structures';
  static const _keyTerms = 'admin_terms';

  final ValueNotifier<List<SolarPanelRecord>> panels = ValueNotifier([]);
  final ValueNotifier<List<SolarInverterRecord>> inverters = ValueNotifier([]);
  final ValueNotifier<List<BatteryRecord>> batteries = ValueNotifier([]);
  final ValueNotifier<List<MountingStructureRecord>> structures =
      ValueNotifier([]);
  final ValueNotifier<List<TermsRecord>> terms = ValueNotifier([]);

  StreamSubscription? _panelSub;
  StreamSubscription? _inverterSub;
  StreamSubscription? _batterySub;
  StreamSubscription? _structureSub;
  StreamSubscription? _termsSub;

  FirebaseFirestore? get _db => CatalogService.instance.firestore;
  bool get _cloudOn => CatalogService.instance.cloudEnabled.value;

  List<SolarPanelRecord> get activePanels =>
      panels.value.where((r) => r.active).toList();
  List<SolarInverterRecord> get activeInverters =>
      inverters.value.where((r) => r.active).toList();
  List<BatteryRecord> get activeBatteries =>
      batteries.value.where((r) => r.active).toList();
  List<MountingStructureRecord> get activeStructures =>
      structures.value.where((r) => r.active).toList();
  List<TermsRecord> get activeTerms {
    final list = terms.value.where((r) => r.active).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<void> init() async {
    await _loadLocalCache();
    if (_cloudOn) {
      _listenFirestore();
      await _seedFirestoreIfEmpty();
    } else {
      if (panels.value.isEmpty) await _seedLocalDefaults();
    }
  }

  Future<void> connectCloud() async {
    _listenFirestore();
    await _seedFirestoreIfEmpty();
  }

  // ═════════════════════════════════════════════════════════════
  // PANELS
  // ═════════════════════════════════════════════════════════════

  Future<void> addPanel(SolarPanelRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colPanels).doc(r.id).set(_panelToMap(r));
    } else {
      panels.value = [...panels.value, r];
      await _cacheList(_keyPanels, panels.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> updatePanel(SolarPanelRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colPanels).doc(r.id).set(_panelToMap(r));
    } else {
      panels.value = [
        for (final p in panels.value) if (p.id == r.id) r else p
      ];
      await _cacheList(_keyPanels, panels.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deletePanel(String id) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colPanels).doc(id).delete();
    } else {
      panels.value = panels.value.where((p) => p.id != id).toList();
      await _cacheList(_keyPanels, panels.value.map((e) => e.toJson()).toList());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // INVERTERS
  // ═════════════════════════════════════════════════════════════

  Future<void> addInverter(SolarInverterRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colInverters).doc(r.id).set(_inverterToMap(r));
    } else {
      inverters.value = [...inverters.value, r];
      await _cacheList(
          _keyInverters, inverters.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> updateInverter(SolarInverterRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colInverters).doc(r.id).set(_inverterToMap(r));
    } else {
      inverters.value = [
        for (final p in inverters.value) if (p.id == r.id) r else p
      ];
      await _cacheList(
          _keyInverters, inverters.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteInverter(String id) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colInverters).doc(id).delete();
    } else {
      inverters.value = inverters.value.where((p) => p.id != id).toList();
      await _cacheList(
          _keyInverters, inverters.value.map((e) => e.toJson()).toList());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // BATTERIES
  // ═════════════════════════════════════════════════════════════

  Future<void> addBattery(BatteryRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colBatteries).doc(r.id).set(_batteryToMap(r));
    } else {
      batteries.value = [...batteries.value, r];
      await _cacheList(
          _keyBatteries, batteries.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> updateBattery(BatteryRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colBatteries).doc(r.id).set(_batteryToMap(r));
    } else {
      batteries.value = [
        for (final p in batteries.value) if (p.id == r.id) r else p
      ];
      await _cacheList(
          _keyBatteries, batteries.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteBattery(String id) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colBatteries).doc(id).delete();
    } else {
      batteries.value = batteries.value.where((p) => p.id != id).toList();
      await _cacheList(
          _keyBatteries, batteries.value.map((e) => e.toJson()).toList());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // STRUCTURES
  // ═════════════════════════════════════════════════════════════

  Future<void> addStructure(MountingStructureRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colStructures).doc(r.id).set(_structureToMap(r));
    } else {
      structures.value = [...structures.value, r];
      await _cacheList(
          _keyStructures, structures.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> updateStructure(MountingStructureRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colStructures).doc(r.id).set(_structureToMap(r));
    } else {
      structures.value = [
        for (final p in structures.value) if (p.id == r.id) r else p
      ];
      await _cacheList(
          _keyStructures, structures.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteStructure(String id) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colStructures).doc(id).delete();
    } else {
      structures.value = structures.value.where((p) => p.id != id).toList();
      await _cacheList(
          _keyStructures, structures.value.map((e) => e.toJson()).toList());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // TERMS
  // ═════════════════════════════════════════════════════════════

  Future<void> addTerm(TermsRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colTerms).doc(r.id).set(_termToMap(r));
    } else {
      terms.value = [...terms.value, r];
      await _cacheList(_keyTerms, terms.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> updateTerm(TermsRecord r) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colTerms).doc(r.id).set(_termToMap(r));
    } else {
      terms.value = [
        for (final p in terms.value) if (p.id == r.id) r else p
      ];
      await _cacheList(_keyTerms, terms.value.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteTerm(String id) async {
    final db = _db;
    if (db != null && _cloudOn) {
      await db.collection(_colTerms).doc(id).delete();
    } else {
      terms.value = terms.value.where((p) => p.id != id).toList();
      await _cacheList(_keyTerms, terms.value.map((e) => e.toJson()).toList());
    }
  }

  // ═════════════════════════════════════════════════════════════
  // FIRESTORE LISTENERS (real-time sync)
  // ═════════════════════════════════════════════════════════════

  void _listenFirestore() {
    final db = _db;
    if (db == null) return;

    _panelSub?.cancel();
    _panelSub = db.collection(_colPanels).snapshots().listen((snap) {
      final list = snap.docs.map((d) => _panelFromDoc(d)).toList();
      panels.value = list;
      _cacheList(_keyPanels, list.map((e) => e.toJson()).toList());
    });

    _inverterSub?.cancel();
    _inverterSub = db.collection(_colInverters).snapshots().listen((snap) {
      final list = snap.docs.map((d) => _inverterFromDoc(d)).toList();
      inverters.value = list;
      _cacheList(_keyInverters, list.map((e) => e.toJson()).toList());
    });

    _batterySub?.cancel();
    _batterySub = db.collection(_colBatteries).snapshots().listen((snap) {
      final list = snap.docs.map((d) => _batteryFromDoc(d)).toList();
      batteries.value = list;
      _cacheList(_keyBatteries, list.map((e) => e.toJson()).toList());
    });

    _structureSub?.cancel();
    _structureSub = db.collection(_colStructures).snapshots().listen((snap) {
      final list = snap.docs.map((d) => _structureFromDoc(d)).toList();
      structures.value = list;
      _cacheList(_keyStructures, list.map((e) => e.toJson()).toList());
    });

    _termsSub?.cancel();
    _termsSub = db.collection(_colTerms).snapshots().listen((snap) {
      final list = snap.docs.map((d) => _termFromDoc(d)).toList();
      terms.value = list;
      _cacheList(_keyTerms, list.map((e) => e.toJson()).toList());
    });
  }

  // ═════════════════════════════════════════════════════════════
  // FIRESTORE SEED (first-time only)
  // ═════════════════════════════════════════════════════════════

  bool _seedAttempted = false;

  Future<void> _seedFirestoreIfEmpty() async {
    if (_seedAttempted) return;
    _seedAttempted = true;
    final db = _db;
    if (db == null) return;

    try {
      final check = await db.collection(_colPanels).limit(1).get();
      if (check.docs.isNotEmpty) return;

      final batch = db.batch();

      for (final name in CatalogData.solarPanels) {
        final id = db.collection(_colPanels).doc().id;
        batch.set(db.collection(_colPanels).doc(id), _panelToMap(SolarPanelRecord(
          id: id,
          panelName: name,
          brandMake: _extractBrand(name),
          technology: name.contains('Bifacial') ? 'Bifacial' : '',
          wattage: _extractWattage(name),
          warranty: '12 years replaceable- 25 years life',
        )));
      }

      for (final name in CatalogData.solarInverters) {
        final id = db.collection(_colInverters).doc().id;
        batch.set(db.collection(_colInverters).doc(id), _inverterToMap(SolarInverterRecord(
          id: id,
          inverterName: name,
          brandMake: _extractInverterBrand(name),
          phaseType: name.contains('Three Phase') ? 'Three Phase' : 'Single Phase',
          capacity: _extractCapacity(name),
          ipRating: _extractIpRating(name),
          warranty: name.contains('IP66') ? '5 years' : '3 years',
        )));
      }

      for (final name in CatalogData.batteries) {
        final id = db.collection(_colBatteries).doc().id;
        batch.set(db.collection(_colBatteries).doc(id), _batteryToMap(BatteryRecord(
          id: id,
          batteryName: name,
          brandMake: _extractBatteryBrand(name),
          batteryType: 'Lithium',
          capacity: _extractBatteryCapacity(name),
          ipRating: _extractIpRating(name),
          warranty: '5 years',
        )));
      }

      final structureSeeds = [
        ('Solar Mounting Structure (Elevated)', 'Elevated MS Structure with Double Girder', CatalogData.elevatedStructureDescription),
        ('Solar Mounting Structure (Ground Mount)', 'Standard Ground Mount', CatalogData.groundMountDescription),
        ('Solar Mounting Structure (Semi Elevated)', 'Semi Elevated Mount', CatalogData.semiElevatedDescription),
      ];
      for (final (sName, sDesc, sMat) in structureSeeds) {
        final id = db.collection(_colStructures).doc().id;
        batch.set(db.collection(_colStructures).doc(id), _structureToMap(MountingStructureRecord(
          id: id,
          structureName: sName,
          description: sDesc,
          materialDetails: sMat,
        )));
      }

      for (var i = 0; i < CatalogData.termsAndConditions.length; i++) {
        final id = db.collection(_colTerms).doc().id;
        batch.set(db.collection(_colTerms).doc(id), _termToMap(TermsRecord(
          id: id,
          title: 'Term ${i + 1}',
          description: CatalogData.termsAndConditions[i],
          sortOrder: i,
        )));
      }

      await batch.commit();
      debugPrint('AdminDataService: seeded Firestore with defaults');
    } catch (e) {
      debugPrint('AdminDataService seed failed: $e');
    }
  }

  // ═════════════════════════════════════════════════════════════
  // LOCAL CACHE (SharedPreferences fallback)
  // ═════════════════════════════════════════════════════════════

  Future<void> _cacheList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> _loadCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _loadLocalCache() async {
    panels.value =
        (await _loadCache(_keyPanels)).map(SolarPanelRecord.fromJson).toList();
    inverters.value = (await _loadCache(_keyInverters))
        .map(SolarInverterRecord.fromJson)
        .toList();
    batteries.value = (await _loadCache(_keyBatteries))
        .map(BatteryRecord.fromJson)
        .toList();
    structures.value = (await _loadCache(_keyStructures))
        .map(MountingStructureRecord.fromJson)
        .toList();
    terms.value =
        (await _loadCache(_keyTerms)).map(TermsRecord.fromJson).toList();
  }

  Future<void> _seedLocalDefaults() async {
    final seedPanels = <SolarPanelRecord>[];
    for (final name in CatalogData.solarPanels) {
      seedPanels.add(SolarPanelRecord(
        id: _newId(),
        panelName: name,
        brandMake: _extractBrand(name),
        technology: name.contains('Bifacial') ? 'Bifacial' : '',
        wattage: _extractWattage(name),
        warranty: '12 years replaceable- 25 years life',
      ));
      await Future.delayed(const Duration(microseconds: 1));
    }
    panels.value = seedPanels;

    final seedInverters = <SolarInverterRecord>[];
    for (final name in CatalogData.solarInverters) {
      seedInverters.add(SolarInverterRecord(
        id: _newId(),
        inverterName: name,
        brandMake: _extractInverterBrand(name),
        phaseType:
            name.contains('Three Phase') ? 'Three Phase' : 'Single Phase',
        capacity: _extractCapacity(name),
        ipRating: _extractIpRating(name),
        warranty: name.contains('IP66') ? '5 years' : '3 years',
      ));
      await Future.delayed(const Duration(microseconds: 1));
    }
    inverters.value = seedInverters;

    final seedBatteries = <BatteryRecord>[];
    for (final name in CatalogData.batteries) {
      seedBatteries.add(BatteryRecord(
        id: _newId(),
        batteryName: name,
        brandMake: _extractBatteryBrand(name),
        batteryType: 'Lithium',
        capacity: _extractBatteryCapacity(name),
        ipRating: _extractIpRating(name),
        warranty: '5 years',
      ));
      await Future.delayed(const Duration(microseconds: 1));
    }
    batteries.value = seedBatteries;

    structures.value = [
      MountingStructureRecord(
        id: _newId(),
        structureName: 'Solar Mounting Structure (Elevated)',
        description: 'Elevated MS Structure with Double Girder',
        materialDetails: CatalogData.elevatedStructureDescription,
      ),
      MountingStructureRecord(
        id: '${_newId()}1',
        structureName: 'Solar Mounting Structure (Ground Mount)',
        description: 'Standard Ground Mount',
        materialDetails: CatalogData.groundMountDescription,
      ),
      MountingStructureRecord(
        id: '${_newId()}2',
        structureName: 'Solar Mounting Structure (Semi Elevated)',
        description: 'Semi Elevated Mount',
        materialDetails: CatalogData.semiElevatedDescription,
      ),
    ];

    final seedTerms = <TermsRecord>[];
    for (var i = 0; i < CatalogData.termsAndConditions.length; i++) {
      seedTerms.add(TermsRecord(
        id: _newId(),
        title: 'Term ${i + 1}',
        description: CatalogData.termsAndConditions[i],
        sortOrder: i,
      ));
      await Future.delayed(const Duration(microseconds: 1));
    }
    terms.value = seedTerms;

    await _cacheList(_keyPanels, panels.value.map((e) => e.toJson()).toList());
    await _cacheList(
        _keyInverters, inverters.value.map((e) => e.toJson()).toList());
    await _cacheList(
        _keyBatteries, batteries.value.map((e) => e.toJson()).toList());
    await _cacheList(
        _keyStructures, structures.value.map((e) => e.toJson()).toList());
    await _cacheList(_keyTerms, terms.value.map((e) => e.toJson()).toList());
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ═════════════════════════════════════════════════════════════
  // FIRESTORE ↔ MODEL CONVERTERS
  // ═════════════════════════════════════════════════════════════

  static Map<String, dynamic> _panelToMap(SolarPanelRecord r) => {
        'panelName': r.panelName,
        'brandMake': r.brandMake,
        'technology': r.technology,
        'wattage': r.wattage,
        'unitPrice': r.unitPrice,
        'warranty': r.warranty,
        'active': r.active,
      };

  static SolarPanelRecord _panelFromDoc(
          DocumentSnapshot<Map<String, dynamic>> d) =>
      SolarPanelRecord(
        id: d.id,
        panelName: d.data()?['panelName'] as String? ?? '',
        brandMake: d.data()?['brandMake'] as String? ?? '',
        technology: d.data()?['technology'] as String? ?? '',
        wattage: (d.data()?['wattage'] as num?)?.toInt() ?? 0,
        unitPrice: (d.data()?['unitPrice'] as num?)?.toInt() ?? 0,
        warranty: d.data()?['warranty'] as String? ?? '',
        active: d.data()?['active'] as bool? ?? true,
      );

  static Map<String, dynamic> _inverterToMap(SolarInverterRecord r) => {
        'inverterName': r.inverterName,
        'brandMake': r.brandMake,
        'phaseType': r.phaseType,
        'capacity': r.capacity,
        'ipRating': r.ipRating,
        'unitPrice': r.unitPrice,
        'warranty': r.warranty,
        'active': r.active,
      };

  static SolarInverterRecord _inverterFromDoc(
          DocumentSnapshot<Map<String, dynamic>> d) =>
      SolarInverterRecord(
        id: d.id,
        inverterName: d.data()?['inverterName'] as String? ?? '',
        brandMake: d.data()?['brandMake'] as String? ?? '',
        phaseType: d.data()?['phaseType'] as String? ?? '',
        capacity: d.data()?['capacity'] as String? ?? '',
        ipRating: d.data()?['ipRating'] as String? ?? '',
        unitPrice: (d.data()?['unitPrice'] as num?)?.toInt() ?? 0,
        warranty: d.data()?['warranty'] as String? ?? '',
        active: d.data()?['active'] as bool? ?? true,
      );

  static Map<String, dynamic> _batteryToMap(BatteryRecord r) => {
        'batteryName': r.batteryName,
        'brandMake': r.brandMake,
        'batteryType': r.batteryType,
        'capacity': r.capacity,
        'ipRating': r.ipRating,
        'unitPrice': r.unitPrice,
        'warranty': r.warranty,
        'active': r.active,
      };

  static BatteryRecord _batteryFromDoc(
          DocumentSnapshot<Map<String, dynamic>> d) =>
      BatteryRecord(
        id: d.id,
        batteryName: d.data()?['batteryName'] as String? ?? '',
        brandMake: d.data()?['brandMake'] as String? ?? '',
        batteryType: d.data()?['batteryType'] as String? ?? '',
        capacity: d.data()?['capacity'] as String? ?? '',
        ipRating: d.data()?['ipRating'] as String? ?? '',
        unitPrice: (d.data()?['unitPrice'] as num?)?.toInt() ?? 0,
        warranty: d.data()?['warranty'] as String? ?? '',
        active: d.data()?['active'] as bool? ?? true,
      );

  static Map<String, dynamic> _structureToMap(MountingStructureRecord r) => {
        'structureName': r.structureName,
        'description': r.description,
        'materialDetails': r.materialDetails,
        'unitPrice': r.unitPrice,
        'active': r.active,
      };

  static MountingStructureRecord _structureFromDoc(
          DocumentSnapshot<Map<String, dynamic>> d) =>
      MountingStructureRecord(
        id: d.id,
        structureName: d.data()?['structureName'] as String? ?? '',
        description: d.data()?['description'] as String? ?? '',
        materialDetails: d.data()?['materialDetails'] as String? ?? '',
        unitPrice: (d.data()?['unitPrice'] as num?)?.toInt() ?? 0,
        active: d.data()?['active'] as bool? ?? true,
      );

  static Map<String, dynamic> _termToMap(TermsRecord r) => {
        'title': r.title,
        'description': r.description,
        'sortOrder': r.sortOrder,
        'active': r.active,
      };

  static TermsRecord _termFromDoc(
          DocumentSnapshot<Map<String, dynamic>> d) =>
      TermsRecord(
        id: d.id,
        title: d.data()?['title'] as String? ?? '',
        description: d.data()?['description'] as String? ?? '',
        sortOrder: (d.data()?['sortOrder'] as num?)?.toInt() ?? 0,
        active: d.data()?['active'] as bool? ?? true,
      );

  // ═════════════════════════════════════════════════════════════
  // HELPERS
  // ═════════════════════════════════════════════════════════════

  static String _extractBrand(String name) {
    final parts = name.split(' ');
    if (parts.isNotEmpty) return parts[0];
    return '';
  }

  static int _extractWattage(String name) {
    final match = RegExp(r'(\d+)W').firstMatch(name);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  static String _extractInverterBrand(String name) {
    final idx = name.indexOf(' ');
    return idx > 0 ? name.substring(0, idx) : name;
  }

  static String _extractCapacity(String name) {
    final match = RegExp(r'(\d+\.?\d*kW)').firstMatch(name);
    return match?.group(1) ?? '';
  }

  static String _extractIpRating(String name) {
    final match = RegExp(r'(IP\d+)').firstMatch(name);
    return match?.group(1) ?? '';
  }

  static String _extractBatteryBrand(String name) {
    final idx = name.indexOf(' Lithium');
    if (idx > 0) return name.substring(0, idx);
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts[0] : '';
  }

  static String _extractBatteryCapacity(String name) {
    final match = RegExp(r'(\d+kWh)').firstMatch(name);
    return match?.group(1) ?? '';
  }

  void dispose() {
    _panelSub?.cancel();
    _inverterSub?.cancel();
    _batterySub?.cancel();
    _structureSub?.cancel();
    _termsSub?.cancel();
  }
}
