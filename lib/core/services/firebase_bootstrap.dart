import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../firebase_options.dart';
import '../config/env.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// One-time application bootstrap. Call from main() before runApp.
class AppBootstrap {
  AppBootstrap._();

  static Future<void> initialize() async {
    await _initFirebase();
    await _initHive();
    appLog.i('Agrolink bootstrap complete');
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Enable Firestore offline persistence on web (default-on for mobile).
      if (kIsWeb) {
        try {
          await FirebaseFirestore.instance.enablePersistence(
            const PersistenceSettings(synchronizeTabs: true),
          );
        } catch (e) {
          appLog.w('Firestore web persistence not enabled: $e');
        }
      } else {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }

      if (Env.useEmulators) {
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
        appLog.i('Connected to Firebase emulators');
      }
    } catch (e, st) {
      appLog.e('Firebase init failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  static Future<void> _initHive() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(AppConstants.boxAuth),
      Hive.openBox<dynamic>(AppConstants.boxCache),
      Hive.openBox<dynamic>(AppConstants.boxSyncQueue),
      Hive.openBox<dynamic>(AppConstants.boxSettings),
    ]);
    appLog.i('Hive ready');
  }
}
