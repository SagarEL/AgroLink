import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/providers.dart';
import '../../models/app_user.dart';

/// Reflects FirebaseAuth's user stream. Use this to gate widgets that don't
/// need the full profile (e.g. login-route splash).
final firebaseUserProvider = StreamProvider<fb.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Resolves the Firestore profile for the authenticated user. Returns null
/// while the user is logged out.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final fbUser = ref.watch(firebaseUserProvider).valueOrNull;
  if (fbUser == null) return Stream.value(null);
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users').doc(fbUser.uid).snapshots().map((snap) {
    if (!snap.exists) {
      return AppUser(
        uid: fbUser.uid,
        role: UserRole.admin, // bootstrap; profile should be created on first login
        name: fbUser.displayName ?? (fbUser.email?.split('@').first ?? 'User'),
        email: fbUser.email,
        phone: fbUser.phoneNumber,
        createdAt: DateTime.now(),
      );
    }
    return AppUser.fromJson(fbUser.uid, snap.data()!);
  });
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData(null));
  final Ref _ref;

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = _ref.read(authServiceProvider);
      final cred = await auth.signInWithEmail(email, password);
      await _ensureProfile(cred.user!, role: UserRole.admin);
    });
  }

  Future<void> registerAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = _ref.read(authServiceProvider);
      final cred = await auth.createWithEmail(email, password);
      await cred.user!.updateDisplayName(name);
      await _ensureProfile(cred.user!, role: UserRole.admin, name: name);
    });
  }

  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _ref.read(authServiceProvider).sendPasswordReset(email);
    });
  }

  Future<String> sendOtp(String phone) async {
    state = const AsyncLoading();
    final id = await _ref.read(authServiceProvider).sendOtp(phone);
    state = const AsyncData(null);
    return id;
  }

  Future<void> confirmOtp(String verificationId, String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = _ref.read(authServiceProvider);
      final cred = await auth.confirmOtp(verificationId, code);
      await _ensureProfile(cred.user!, role: UserRole.farmer);
    });
  }

  Future<void> signOut() async {
    await _ref.read(authServiceProvider).signOut();
  }

  Future<void> _ensureProfile(fb.User user, {required UserRole role, String? name}) async {
    final auth = _ref.read(authServiceProvider);
    final existing = await auth.fetchProfile(user.uid);
    if (existing != null) return;
    await auth.upsertProfile(user.uid, {
      'uid': user.uid,
      'role': role.key,
      'name': name ?? user.displayName ?? (user.email?.split('@').first ?? 'User'),
      'email': user.email,
      'phone': user.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) => AuthController(ref));
