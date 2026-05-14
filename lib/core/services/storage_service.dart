import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../utils/exceptions.dart';

/// Wraps Firebase Storage uploads. Returns the public download URL for the
/// stored file. Throws [NetworkException] / [PermissionException] on failure.
class StorageService {
  StorageService(this._storage);
  final FirebaseStorage _storage;

  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final task = await ref.putData(
        bytes,
        SettableMetadata(contentType: contentType, customMetadata: metadata),
      );
      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized') {
        throw PermissionException('Upload blocked', code: e.code, cause: e);
      }
      throw NetworkException('Upload failed', code: e.code, cause: e);
    }
  }

  Future<void> deleteAt(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      rethrow;
    }
  }
}
