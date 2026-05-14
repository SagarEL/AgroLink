import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolink/models/user_model.dart';
import 'package:agrolink/core/constants/app_constants.dart';

/// ─────────────────────────────────────────────────────────────
/// Authentication Service — Firebase Auth + Firestore user mgmt
/// ─────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.read(authServiceProvider).getUserData(user.uid);
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password (Doctor/Admin)
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _updateLastLogin(credential.user!.uid);
        return getUserData(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Register new user
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserModel(
          uid: credential.user!.uid,
          role: role,
          name: name,
          phone: phone,
          email: email,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(user.toMap());

        return user;
      }
      return null;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Stream user data for real-time updates
  Stream<UserModel?> streamUserData(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'lastLogin': Timestamp.fromDate(DateTime.now())});
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }
}
