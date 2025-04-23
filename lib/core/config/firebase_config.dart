import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> init() async {
    try {
      // Initialize Firebase with default options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase: $e');
      }
      rethrow;
    }
  }
}

// Firebase options configuration (platform-specific)
class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );
}
