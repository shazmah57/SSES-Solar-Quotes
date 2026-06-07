import 'package:flutter/foundation.dart';

class LoadStateService {
  LoadStateService._();
  static final LoadStateService instance = LoadStateService._();

  final ValueNotifier<Map<String, int>> applianceCounts =
      ValueNotifier<Map<String, int>>({});

  void saveCounts(Map<String, int> counts) {
    applianceCounts.value = Map<String, int>.from(counts);
  }
}
