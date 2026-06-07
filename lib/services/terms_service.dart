import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog_data.dart';
import 'catalog_service.dart';

class TermEntry {
  final String id;
  final String text;

  const TermEntry({required this.id, required this.text});
}

/// Terms & conditions for quotations (local + Firestore when cloud is on).
class TermsService {
  TermsService._();
  static final TermsService instance = TermsService._();

  static const _prefTermsJson = 'terms_local_json';

  final ValueNotifier<List<TermEntry>> terms = ValueNotifier([]);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  bool _seedAttempted = false;

  Future<void> init() async {
    await _loadLocal();
    if (CatalogService.instance.cloudEnabled.value) {
      _listenCloud();
      await _seedFirestoreIfEmpty();
    }
  }

  List<String> get texts => terms.value.map((e) => e.text).toList();

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefTermsJson);
    if (raw != null && raw.isNotEmpty) {
      terms.value = [
        for (var i = 0; i < raw.length; i++)
          TermEntry(id: 'local_$i', text: raw[i]),
      ];
      return;
    }
    terms.value = [
      for (var i = 0; i < CatalogData.termsAndConditions.length; i++)
        TermEntry(
          id: 'default_$i',
          text: CatalogData.termsAndConditions[i],
        ),
    ];
    await _persistLocal();
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefTermsJson,
      terms.value.map((e) => e.text).toList(),
    );
  }

  void _listenCloud() {
    final db = CatalogService.instance.firestore;
    if (db == null) return;
    _sub?.cancel();
    _sub = db.collection('terms').snapshots().listen((snap) {
      if (snap.docs.isEmpty) return;
      final list = <({int order, TermEntry entry})>[];
      for (final doc in snap.docs) {
        final text = (doc.data()['text'] as String? ?? '').trim();
        if (text.isEmpty) continue;
        final order = (doc.data()['sortOrder'] as num?)?.toInt() ?? 0;
        list.add((order: order, entry: TermEntry(id: doc.id, text: text)));
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      terms.value = [for (final item in list) item.entry];
      _persistLocal();
    });
  }

  Future<void> onCloudConnected() async {
    _listenCloud();
    await _seedFirestoreIfEmpty();
  }

  Future<void> _seedFirestoreIfEmpty() async {
    if (_seedAttempted) return;
    _seedAttempted = true;
    final db = CatalogService.instance.firestore;
    if (db == null) return;
    try {
      final snap = await db.collection('terms').limit(1).get();
      if (snap.docs.isNotEmpty) return;
      final batch = db.batch();
      for (var i = 0; i < terms.value.length; i++) {
        final ref = db.collection('terms').doc();
        batch.set(ref, {'text': terms.value[i].text, 'sortOrder': i});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Terms seed failed: $e');
    }
  }

  Future<void> upsertTerm({String? id, required String text}) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    final db = CatalogService.instance.firestore;
    if (db != null && CatalogService.instance.cloudEnabled.value) {
      final payload = {
        'text': cleaned,
        'sortOrder': terms.value.length,
      };
      if (id == null || id.startsWith('local_') || id.startsWith('default_')) {
        await db.collection('terms').add(payload);
      } else {
        await db.collection('terms').doc(id).set(payload, SetOptions(merge: true));
      }
      return;
    }
    final list = [...terms.value];
    if (id != null) {
      final idx = list.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        list[idx] = TermEntry(id: id, text: cleaned);
      } else {
        list.add(TermEntry(id: 'local_${DateTime.now().millisecondsSinceEpoch}', text: cleaned));
      }
    } else {
      list.add(
        TermEntry(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          text: cleaned,
        ),
      );
    }
    terms.value = list;
    await _persistLocal();
  }

  Future<void> deleteTerm(String id) async {
    final db = CatalogService.instance.firestore;
    if (db != null &&
        CatalogService.instance.cloudEnabled.value &&
        !id.startsWith('local_') &&
        !id.startsWith('default_')) {
      await db.collection('terms').doc(id).delete();
      return;
    }
    terms.value = terms.value.where((e) => e.id != id).toList();
    await _persistLocal();
  }

  void dispose() => _sub?.cancel();
}
