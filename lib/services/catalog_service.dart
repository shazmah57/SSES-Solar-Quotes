import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../data/catalog_data.dart';
import '../firebase_options.dart';
import 'admin_data_service.dart';
import 'branding_service.dart';
import 'terms_service.dart';

enum CatalogType { panel, inverter, battery }

extension CatalogTypeX on CatalogType {
  String get value => switch (this) {
    CatalogType.panel => 'panel',
    CatalogType.inverter => 'inverter',
    CatalogType.battery => 'battery',
  };

  String get title => switch (this) {
    CatalogType.panel => 'Panels',
    CatalogType.inverter => 'Inverters',
    CatalogType.battery => 'Batteries',
  };
}

class ApplianceConfig {
  final String id;
  final String label;
  final int watts;
  final int backupSlots;

  const ApplianceConfig({
    required this.id,
    required this.label,
    required this.watts,
    this.backupSlots = 5,
  });
}

class CatalogSnapshot {
  final List<String> panels;
  final List<String> inverters;
  final List<String> batteries;
  final List<ApplianceConfig> appliances;

  const CatalogSnapshot({
    required this.panels,
    required this.inverters,
    required this.batteries,
    required this.appliances,
  });
}

class CatalogService {
  CatalogService._();
  static final CatalogService instance = CatalogService._();

  final ValueNotifier<bool> cloudEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<String?> cloudInitError = ValueNotifier<String?>(null);

  FirebaseFirestore? _firestore;
  FirebaseFirestore? get firestore => _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _catalogSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _applianceSub;
  bool _seedAttempted = false;

  final ValueNotifier<CatalogSnapshot> snapshot =
      ValueNotifier<CatalogSnapshot>(
        CatalogSnapshot(
          panels: List<String>.from(CatalogData.solarPanels),
          inverters: List<String>.from(CatalogData.solarInverters),
          batteries: List<String>.from(CatalogData.batteries),
          appliances: defaultAppliances,
        ),
      );

  static const String adminPin = '7744';

  static const List<ApplianceConfig> defaultAppliances = [
    ApplianceConfig(id: 'lights', label: 'Lights', watts: 15, backupSlots: 5),
    ApplianceConfig(id: 'fridge', label: 'Fridge', watts: 180, backupSlots: 3),
    ApplianceConfig(
      id: 'deep_freezer',
      label: 'Deep Freezer',
      watts: 220,
      backupSlots: 3,
    ),
    ApplianceConfig(
      id: 'ac_1t_inv',
      label: '1 Ton AC Inverter',
      watts: 1200,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'ac_15t_inv',
      label: '1.5 Ton AC Inverter',
      watts: 1500,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'ac_2t_inv',
      label: '2 Ton AC Inverter',
      watts: 1800,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'ac_25t_inv',
      label: '2.5 Ton AC Inverter',
      watts: 2200,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'ac_1t_non',
      label: '1 Ton AC Non Inverter',
      watts: 1500,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'ac_15t_non',
      label: '1.5 Ton AC Non Inverter',
      watts: 1900,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'ac_2t_non',
      label: '2 Ton AC Non Inverter',
      watts: 2300,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'ac_25t_non',
      label: '2.5 Ton AC Non Inverter',
      watts: 2700,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'fans_conventional',
      label: 'Fans Conventional',
      watts: 90,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'fans_ac_dc',
      label: 'Fans AC/DC',
      watts: 45,
      backupSlots: 5,
    ),
    ApplianceConfig(
      id: 'other_load',
      label: 'Other Load',
      watts: 300,
      backupSlots: 2,
    ),
  ];

  Future<void> init() async {
    cloudInitError.value = null;
    cloudEnabled.value = false;

    if (!DefaultFirebaseOptions.isConfigured) {
      cloudInitError.value =
          'Firebase options not generated.\n\n'
          '1. Add android/app/google-services.json from Firebase Console\n'
          '2. Run: dart run tool/generate_firebase_options.dart\n'
          '3. Rebuild the app';
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      cloudEnabled.value = true;
      _listenCloud();
      await _seedFirestoreIfEmpty();
      await BrandingService.instance.init();
      await BrandingService.instance.downloadFromCloud();
      await TermsService.instance.onCloudConnected();
      await AdminDataService.instance.connectCloud();
    } on FirebaseException catch (e) {
      cloudInitError.value = 'Firebase error: ${e.message ?? e.code}';
    } catch (e, st) {
      cloudInitError.value = 'Could not connect to cloud: $e';
      debugPrint('CatalogService init failed: $e\n$st');
      await BrandingService.instance.init();
    }
  }

  Future<void> _seedFirestoreIfEmpty() async {
    if (_seedAttempted) return;
    _seedAttempted = true;

    final db = _firestore;
    if (db == null) return;

    try {
      final catalogSnap = await db.collection('catalog_items').limit(1).get();
      if (catalogSnap.docs.isEmpty) {
        final batch = db.batch();
        for (final name in CatalogData.solarPanels) {
          final ref = db.collection('catalog_items').doc();
          batch.set(ref, {'type': CatalogType.panel.value, 'name': name});
        }
        for (final name in CatalogData.solarInverters) {
          final ref = db.collection('catalog_items').doc();
          batch.set(ref, {'type': CatalogType.inverter.value, 'name': name});
        }
        for (final name in CatalogData.batteries) {
          final ref = db.collection('catalog_items').doc();
          batch.set(ref, {'type': CatalogType.battery.value, 'name': name});
        }
        await batch.commit();
      }

      final applianceSnap = await db
          .collection('appliance_configs')
          .limit(1)
          .get();
      if (applianceSnap.docs.isEmpty) {
        final batch = db.batch();
        for (final a in defaultAppliances) {
          final ref = db.collection('appliance_configs').doc(a.id);
          batch.set(ref, {
            'label': a.label,
            'watts': a.watts,
            'backupSlots': a.backupSlots,
          });
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Catalog seed skipped or failed: $e');
    }
  }

  void _listenCloud() {
    final db = _firestore;
    if (db == null) return;

    _catalogSub?.cancel();
    _catalogSub = db.collection('catalog_items').snapshots().listen((snap) {
      final panels = <String>[];
      final inverters = <String>[];
      final batteries = <String>[];

      for (final doc in snap.docs) {
        final data = doc.data();
        final type = (data['type'] as String? ?? '').trim();
        final name = (data['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;
        if (type == CatalogType.panel.value) panels.add(name);
        if (type == CatalogType.inverter.value) inverters.add(name);
        if (type == CatalogType.battery.value) batteries.add(name);
      }

      snapshot.value = CatalogSnapshot(
        panels: panels.isEmpty
            ? List<String>.from(CatalogData.solarPanels)
            : panels,
        inverters: inverters.isEmpty
            ? List<String>.from(CatalogData.solarInverters)
            : inverters,
        batteries: batteries.isEmpty
            ? List<String>.from(CatalogData.batteries)
            : batteries,
        appliances: snapshot.value.appliances,
      );
    });

    _applianceSub?.cancel();
    _applianceSub = db.collection('appliance_configs').snapshots().listen((
      snap,
    ) {
      final list = <ApplianceConfig>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final label = (data['label'] as String? ?? '').trim();
        final watts = (data['watts'] as num?)?.toInt() ?? 0;
        final backupSlots = (data['backupSlots'] as num?)?.toInt() ?? 5;
        if (label.isEmpty || watts <= 0) continue;
        list.add(
          ApplianceConfig(
            id: doc.id,
            label: label,
            watts: watts,
            backupSlots: backupSlots.clamp(1, 10),
          ),
        );
      }
      snapshot.value = CatalogSnapshot(
        panels: snapshot.value.panels,
        inverters: snapshot.value.inverters,
        batteries: snapshot.value.batteries,
        appliances: list.isEmpty ? defaultAppliances : list,
      );
    });
  }

  Future<void> upsertCatalogItem({
    required CatalogType type,
    String? id,
    required String name,
  }) async {
    final db = _firestore;
    if (db == null) return;
    final cleaned = name.trim();
    if (cleaned.isEmpty) return;
    final payload = {'type': type.value, 'name': cleaned};
    if (id == null) {
      await db.collection('catalog_items').add(payload);
    } else {
      await db.collection('catalog_items').doc(id).set(payload);
    }
  }

  Future<void> deleteCatalogItem(String id) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('catalog_items').doc(id).delete();
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamCatalogDocs(
    CatalogType type,
  ) {
    final db = _firestore;
    if (db == null) return const Stream.empty();
    return db
        .collection('catalog_items')
        .where('type', isEqualTo: type.value)
        .snapshots()
        .map((e) => e.docs);
  }

  Future<void> upsertAppliance({
    String? id,
    required String label,
    required int watts,
    int backupSlots = 5,
  }) async {
    final db = _firestore;
    if (db == null) return;
    final payload = {
      'label': label.trim(),
      'watts': watts,
      'backupSlots': backupSlots.clamp(1, 10),
    };
    if (id == null) {
      await db.collection('appliance_configs').add(payload);
    } else {
      await db.collection('appliance_configs').doc(id).set(payload);
    }
  }

  Future<void> deleteAppliance(String id) async {
    final db = _firestore;
    if (db == null) return;
    await db.collection('appliance_configs').doc(id).delete();
  }
}
