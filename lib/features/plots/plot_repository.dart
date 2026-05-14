import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../models/plot.dart';

class PlotRepository {
  PlotRepository(this._firestore, this._uploadImage);
  final FirebaseFirestore _firestore;
  final Future<String> Function(String path, Uint8List bytes) _uploadImage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.plots);

  Stream<List<Plot>> watchForFarmer(String farmerId) {
    return _col
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Plot.fromJson(d.id, d.data())).toList());
  }

  Stream<List<Plot>> watchAll({int limit = 200, String? cropType, PriorityLevel? priority}) {
    Query<Map<String, dynamic>> q = _col.orderBy('createdAt', descending: true).limit(limit);
    if (cropType != null) q = q.where('cropType', isEqualTo: cropType);
    if (priority != null) q = q.where('priorityLevel', isEqualTo: priority.key);
    return q.snapshots().map((s) => s.docs.map((d) => Plot.fromJson(d.id, d.data())).toList());
  }

  Stream<Plot?> watchOne(String id) => _col.doc(id).snapshots().map(
        (s) => s.exists ? Plot.fromJson(s.id, s.data()!) : null,
      );

  Future<Plot> upsert(Plot plot, {List<Uint8List> newImages = const []}) async {
    final id = plot.id.isEmpty ? const Uuid().v4() : plot.id;
    final urls = <String>[...plot.images];
    for (var i = 0; i < newImages.length; i++) {
      final url = await _uploadImage(
        '${AppConstants.storagePlotsFolder}/$id/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        newImages[i],
      );
      urls.add(url);
    }
    final data = plot.copyWith(id: id, images: urls, updatedAt: DateTime.now());
    await _col.doc(id).set(data.toJson(), SetOptions(merge: true));
    return data;
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}

final plotRepositoryProvider = Provider<PlotRepository>((ref) {
  return PlotRepository(
    ref.watch(firestoreProvider),
    (path, bytes) => ref.watch(storageServiceProvider).uploadBytes(path: path, bytes: bytes),
  );
});

final plotsForFarmerProvider = StreamProvider.family<List<Plot>, String>(
  (ref, farmerId) => ref.watch(plotRepositoryProvider).watchForFarmer(farmerId),
);

final plotByIdProvider = StreamProvider.family<Plot?, String>(
  (ref, id) => ref.watch(plotRepositoryProvider).watchOne(id),
);

final allPlotsProvider = StreamProvider<List<Plot>>(
  (ref) => ref.watch(plotRepositoryProvider).watchAll(),
);
