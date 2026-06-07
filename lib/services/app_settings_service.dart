import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode and PDF download folder (configurable in admin).
class AppSettingsService {
  AppSettingsService._();
  static final AppSettingsService instance = AppSettingsService._();

  static const _prefThemeMode = 'settings_theme_mode';
  static const _prefDownloadPath = 'settings_download_path';
  static const defaultDownloadFolderName = 'SSES Solar Quotes Downloads';

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  String? _customDownloadPath;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_prefThemeMode) ?? ThemeMode.light.index;
    themeMode.value = ThemeMode.values[themeIndex.clamp(0, 2)];
    _customDownloadPath = prefs.getString(_prefDownloadPath);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefThemeMode, mode.index);
  }

  void toggleTheme() {
    final next = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setThemeMode(next);
  }

  String? get customDownloadPath => _customDownloadPath;

  Future<void> setDownloadPath(String? path) async {
    final trimmed = path?.trim();
    _customDownloadPath = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    final prefs = await SharedPreferences.getInstance();
    if (_customDownloadPath == null) {
      await prefs.remove(_prefDownloadPath);
    } else {
      await prefs.setString(_prefDownloadPath, _customDownloadPath!);
    }
  }

  /// Ensures the download directory exists and returns it.
  Future<Directory> ensureDownloadDir() async {
    if (_customDownloadPath != null) {
      final dir = Directory(_customDownloadPath!);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      return dir;
    }
    final downloads = await getDownloadsDirectory();
    final base = downloads ?? await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$defaultDownloadFolderName');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<String> displayDownloadPath() async {
    if (_customDownloadPath != null) return _customDownloadPath!;
    final dir = await ensureDownloadDir();
    return dir.path;
  }
}
