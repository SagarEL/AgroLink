import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_constants.dart';
import '../utils/exceptions.dart';
import '../utils/logger.dart';

/// Thin wrapper around FirebaseAuth — translates platform exceptions into
/// AppException subtypes and exposes a small profile read/write helper.
class AuthService {
  AuthService(this._auth, this._firestore);
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(describeAuthError(e.code), code: e.code, cause: e);
    }
  }

  Future<UserCredential> createWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(describeAuthError(e.code), code: e.code, cause: e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(describeAuthError(e.code), code: e.code, cause: e);
    }
  }

  /// Sends an SMS OTP. Returns the verificationId to be used with [confirmOtp].
  /// On web, FirebaseAuth wires reCAPTCHA automatically.
  Future<String> sendOtp(String phone) async {
    final completer = Completer<String>();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (cred) async {
          try {
            await _auth.signInWithCredential(cred);
            if (!completer.isCompleted) completer.complete('auto');
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          }
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              AuthException(describeAuthError(e.code), code: e.code, cause: e),
            );
          }
        },
        codeSent: (verificationId, _) {
          if (!completer.isCompleted) completer.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
      return await completer.future;
    } catch (e) {
      appLog.e('sendOtp failed', error: e);
      rethrow;
    }
  }

  Future<UserCredential> confirmOtp(String verificationId, String code) async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );
      return await _auth.signInWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      throw AuthException(describeAuthError(e.code), code: e.code, cause: e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    final snap = await _firestore.collection(FirestorePaths.users).doc(uid).get();
    return snap.data();
  }

  Future<void> upsertProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection(FirestorePaths.users).doc(uid).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }
}
