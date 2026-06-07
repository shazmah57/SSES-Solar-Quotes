// Generates lib/firebase_options.dart from android/app/google-services.json
//
// Usage (after downloading google-services.json from Firebase Console):
//   dart run tool/generate_firebase_options.dart

import 'dart:convert';
import 'dart:io';

void main() {
  final jsonFile = File('android/app/google-services.json');
  if (!jsonFile.existsSync()) {
    stderr.writeln(
      'Missing android/app/google-services.json\n'
      '1. Create a Firebase project at https://console.firebase.google.com\n'
      '2. Add Android app with package: com.solarquotation.solar_quotation_app\n'
      '3. Download google-services.json into android/app/\n'
      '4. Run this script again.',
    );
    exit(1);
  }

  final root = jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
  final projectInfo = root['project_info'] as Map<String, dynamic>;
  final projectId = projectInfo['project_id'] as String;
  final messagingSenderId = projectInfo['project_number'] as String;
  final storageBucket =
      (projectInfo['storage_bucket'] as String?) ?? '$projectId.appspot.com';

  final clients = root['client'] as List<dynamic>;
  Map<String, dynamic>? androidClient;
  for (final c in clients) {
    final map = c as Map<String, dynamic>;
    final pkg = map['client_info']?['android_client_info']?['package_name'];
    if (pkg == 'com.solarquotation.solar_quotation_app') {
      androidClient = map;
      break;
    }
  }
  androidClient ??= clients.first as Map<String, dynamic>;

  final clientInfo = androidClient['client_info'] as Map<String, dynamic>;
  final appId = clientInfo['mobilesdk_app_id'] as String;
  final apiKeys = androidClient['api_key'] as List<dynamic>;
  final apiKey =
      (apiKeys.first as Map<String, dynamic>)['current_key'] as String;

  final out = File('lib/firebase_options.dart');
  out.writeAsStringSync('''
// GENERATED FILE — do not edit by hand.
// Regenerate: dart run tool/generate_firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options for SSES Solar Quotes.
class DefaultFirebaseOptions {
  static bool get isConfigured => true;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured. Use Android build.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is configured for Android/iOS only. Platform: \$defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '$apiKey',
    appId: '$appId',
    messagingSenderId: '$messagingSenderId',
    projectId: '$projectId',
    storageBucket: '$storageBucket',
  );

  /// Add iOS app in Firebase Console and run flutterfire configure for real iOS keys.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '$apiKey',
    appId: '$appId',
    messagingSenderId: '$messagingSenderId',
    projectId: '$projectId',
    storageBucket: '$storageBucket',
    iosBundleId: 'com.solarquotation.solarQuotationApp',
  );
}
''');

  stdout.writeln('Wrote lib/firebase_options.dart for project: $projectId');
}
