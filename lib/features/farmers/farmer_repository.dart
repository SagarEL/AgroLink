import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../models/farmer.dart';

class FarmerRepository {
  FarmerRepository(this._firestore, this._uploadImage);
  final FirebaseFirestore _firestore;
  final Future<String> Function(String path, Uint8List bytes) _uploadImage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.farmers);

  /// Real-time stream of farmers ordered by most recently updated. The
  /// dashboard consumes this; do not use for large lists — paginate instead.
  Stream<List<Farmer>> watchAll({String? village, String? search, int limit = 100}) {
    Query<Map<String, dynamic>> q = _col.orderBy('createdAt', descending: true).limit(limit);
    if (village != null && village.isNotEmpty) {
      q = q.where('village_lower', isEqualTo: village.toLowerCase());
    }
    return q.snapshots().map((snap) {
      var items = snap.docs.map((d) => Farmer.fromJson(d.id, d.data())).toList();
      if (search != null && search.trim().isNotEmpty) {
        final s = search.toLowerCase();
        items = items.where((f) =>
            f.name.toLowerCase().contains(s) ||
            f.village.toLowerCase().contains(s) ||
            f.phone.contains(s)).toList();
      }
      return items;
    });
  }

  Stream<Farmer?> watchOne(String farmerId) {
    return _col.doc(farmerId).snapshots().map(
          (snap) => snap.exists ? Farmer.fromJson(snap.id, snap.data()!) : null,
        );
  }

  Future<Farmer> upsert(Farmer farmer, {Uint8List? newProfileImage}) async {
    final id = farmer.id.isEmpty ? const Uuid().v4() : farmer.id;
    var data = farmer.copyWith(id: id, updatedAt: DateTime.now());

    if (newProfileImage != null) {
      final url = await _uploadImage(
        '${AppConstants.storageFarmersFolder}/$id/profile.jpg',
        newProfileImage,
      );
      data = data.copyWith(profileImage: url);
    }
    await _col.doc(id).set(data.toJson(), SetOptions(merge: true));
    return data;
  }

  Future<void> delete(String farmerId) async {
    await _col.doc(farmerId).delete();
  }

  Future<List<Farmer>> searchOnce(String query, {int limit = 25}) async {
    final q = query.toLowerCase();
    final snap = await _col
        .orderBy('name_lower')
        .startAt([q])
        .endAt(['$q'])
        .limit(limit)
        .get();
    return snap.docs.map((d) => Farmer.fromJson(d.id, d.data())).toList();
  }
}

final farmerRepositoryProvider = Provider<FarmerRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(storageServiceProvider);
  return FarmerRepository(firestore, (path, bytes) => storage.uploadBytes(path: path, bytes: bytes));
});

final farmersStreamProvider = StreamProvider.family<List<Farmer>, FarmerFilter>((ref, f) {
  return ref
      .watch(farmerRepositoryProvider)
      .watchAll(village: f.village, search: f.search, limit: f.limit);
});

final farmerByIdProvider = StreamProvider.family<Farmer?, String>((ref, id) {
  return ref.watch(farmerRepositoryProvider).watchOne(id);
});

class FarmerFilter {
  final String? village;
  final String? search;
  final int limit;
  const FarmerFilter({this.village, this.search, this.limit = 100});

  @override
  bool operator ==(Object other) =>
      other is FarmerFilter &&
      other.village == village &&
      other.search == search &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(village, search, limit);
}
