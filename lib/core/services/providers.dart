import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'connectivity_service.dart';
import 'messaging_service.dart';
import 'storage_service.dart';

/// Roots — single instances of each Firebase SDK.
final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((_) => FirebaseStorage.instance);
final firebaseMessagingProvider = Provider<FirebaseMessaging>((_) => FirebaseMessaging.instance);
final connectivityProvider = Provider<Connectivity>((_) => Connectivity());

/// Service providers — Riverpod injection points for repositories.
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider)),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.watch(firebaseStorageProvider)),
);

final messagingServiceProvider = Provider<MessagingService>(
  (ref) => MessagingService(ref.watch(firebaseMessagingProvider)),
);

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(ref.watch(connectivityProvider)),
);

final connectivityStreamProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectivityServiceProvider).onStatusChange(),
);
