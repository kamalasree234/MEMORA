import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not configured');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB_AItmtJaHw8P7ua-V3SC3ZUTxuOmM8rI',
    appId: '1:829272661096:android:b7d36e8df7cea7241bafdd',
    messagingSenderId: '829272661096',
    projectId: 'memora-41709',
    storageBucket: 'memora-41709.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_AItmtJaHw8P7ua-V3SC3ZUTxuOmM8rI',
    appId: '1:829272661096:ios:PLACEHOLDER',
    messagingSenderId: '829272661096',
    projectId: 'memora-41709',
    storageBucket: 'memora-41709.firebasestorage.app',
    iosBundleId: 'com.kamalasree.memora',
  );
}
