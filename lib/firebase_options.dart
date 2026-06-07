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
          'Firebase is configured for Android/iOS only. Platform: $defaultTargetPlatform',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBS6XQbBCqW7pEtDzWl4us9Awrwjya_dsE',
    appId: '1:283004439034:android:f02fa23f3c15c7fd397c43',
    messagingSenderId: '283004439034',
    projectId: 'sses-solar-quote',
    storageBucket: 'sses-solar-quote.firebasestorage.app',
  );

  /// Add iOS app in Firebase Console and run flutterfire configure for real iOS keys.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBS6XQbBCqW7pEtDzWl4us9Awrwjya_dsE',
    appId: '1:283004439034:android:f02fa23f3c15c7fd397c43',
    messagingSenderId: '283004439034',
    projectId: 'sses-solar-quote',
    storageBucket: 'sses-solar-quote.firebasestorage.app',
    iosBundleId: 'com.solarquotation.solarQuotationApp',
  );
}
