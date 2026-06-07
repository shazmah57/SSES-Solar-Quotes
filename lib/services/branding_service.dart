import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog_service.dart';

class BrandingState {
  final bool useDefaultAssets;
  final String? letterheadPath;
  final String? logoPath;

  const BrandingState({
    this.useDefaultAssets = true,
    this.letterheadPath,
    this.logoPath,
  });
}

class BrandingService {
  BrandingService._();
  static final BrandingService instance = BrandingService._();

  final ValueNotifier<BrandingState> state = ValueNotifier(
    const BrandingState(),
  );

  static const _prefUseDefault = 'branding_use_default';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final useDefault = prefs.getBool(_prefUseDefault) ?? true;
    if (useDefault) {
      state.value = const BrandingState();
      return;
    }
    final dir = await _brandingDir();
    final letterhead = File('${dir.path}/letterhead.jpg');
    final logo = File('${dir.path}/logo.png');
    state.value = BrandingState(
      useDefaultAssets: false,
      letterheadPath: letterhead.existsSync() ? letterhead.path : null,
      logoPath: logo.existsSync() ? logo.path : null,
    );
    await downloadFromCloud();
  }

  /// Pull letterhead/logo from Firebase Storage (other phones).
  Future<void> downloadFromCloud() async {
    if (!CatalogService.instance.cloudEnabled.value) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefUseDefault) ?? true) return;
    await _downloadFromCloudIfNeeded();
  }

  Future<Directory> _brandingDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/branding');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<void> useDefaultBranding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefUseDefault, true);
    state.value = const BrandingState();
  }

  Future<void> pickAndSaveLetterhead() async {
    final file = await _pickImage();
    if (file == null) return;
    final dir = await _brandingDir();
    final dest = File('${dir.path}/letterhead.jpg');
    await File(file.path).copy(dest.path);
    await _setCustom();
    state.value = BrandingState(
      useDefaultAssets: false,
      letterheadPath: dest.path,
      logoPath: state.value.logoPath,
    );
    await _uploadToCloud(dest, 'branding/letterhead.jpg');
  }

  Future<void> pickAndSaveLogo() async {
    final file = await _pickImage();
    if (file == null) return;
    final dir = await _brandingDir();
    final dest = File('${dir.path}/logo.png');
    await File(file.path).copy(dest.path);
    await _setCustom();
    state.value = BrandingState(
      useDefaultAssets: false,
      letterheadPath: state.value.letterheadPath,
      logoPath: dest.path,
    );
    await _uploadToCloud(dest, 'branding/logo.png');
  }

  Future<void> _setCustom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefUseDefault, false);
  }

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    return picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
  }

  Future<void> _uploadToCloud(File file, String storagePath) async {
    if (!CatalogService.instance.cloudEnabled.value) return;
    try {
      await FirebaseStorage.instance.ref(storagePath).putFile(file);
    } catch (e) {
      debugPrint('Branding upload failed: $e');
    }
  }

  Future<void> _downloadFromCloudIfNeeded() async {
    if (!CatalogService.instance.cloudEnabled.value) return;
    try {
      final dir = await _brandingDir();
      final letterhead = File('${dir.path}/letterhead.jpg');
      final logo = File('${dir.path}/logo.png');
      if (!letterhead.existsSync()) {
        await _downloadFile('branding/letterhead.jpg', letterhead);
      }
      if (!logo.existsSync()) {
        await _downloadFile('branding/logo.png', logo);
      }
      state.value = BrandingState(
        useDefaultAssets: false,
        letterheadPath: letterhead.existsSync() ? letterhead.path : null,
        logoPath: logo.existsSync() ? logo.path : null,
      );
    } catch (e) {
      debugPrint('Branding download failed: $e');
    }
  }

  Future<void> _downloadFile(String path, File dest) async {
    final ref = FirebaseStorage.instance.ref(path);
    final data = await ref.getData();
    if (data != null) await dest.writeAsBytes(data);
  }

  Future<Uint8List?> loadLetterheadBytes() async {
    final branding = state.value;
    if (!branding.useDefaultAssets && branding.letterheadPath != null) {
      return File(branding.letterheadPath!).readAsBytes();
    }
    return null;
  }
}
