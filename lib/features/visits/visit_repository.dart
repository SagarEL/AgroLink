import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../models/visit.dart';

class VisitRepository {
  VisitRepository(this._firestore, this._uploadBytes);
  final FirebaseFirestore _firestore;
  final Future<String> Function(String path, Uint8List bytes, {String contentType}) _uploadBytes;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.visits);

  Stream<List<Visit>> watchForDoctor(String doctorId, {int limit = 200}) {
    return _col
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('visitDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => Visit.fromJson(d.id, d.data())).toList());
  }

  /// Visits scheduled for a specific calendar day, regardless of status. Used
  /// by the route planner.
  Stream<List<Visit>> watchForDate(DateTime date, {String? doctorId}) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    Query<Map<String, dynamic>> q = _col
        .where('visitDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('visitDate', isLessThan: Timestamp.fromDate(end))
        .orderBy('visitDate');
    if (doctorId != null) q = q.where('doctorId', isEqualTo: doctorId);
    return q.snapshots().map((s) => s.docs.map((d) => Visit.fromJson(d.id, d.data())).toList());
  }

  Stream<List<Visit>> watchForFarmer(String farmerId) => _col
      .where('farmerId', isEqualTo: farmerId)
      .orderBy('visitDate', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Visit.fromJson(d.id, d.data())).toList());

  Stream<List<Visit>> watchForPlot(String plotId) => _col
      .where('plotId', isEqualTo: plotId)
      .orderBy('visitDate', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Visit.fromJson(d.id, d.data())).toList());

  Stream<Visit?> watchOne(String id) => _col.doc(id).snapshots().map(
        (s) => s.exists ? Visit.fromJson(s.id, s.data()!) : null,
      );

  Future<Visit> upsert(
    Visit visit, {
    List<Uint8List> newPhotos = const [],
    Uint8List? newVoiceNote,
  }) async {
    final id = visit.id.isEmpty ? const Uuid().v4() : visit.id;
    final photos = <String>[...visit.photos];
    for (var i = 0; i < newPhotos.length; i++) {
      final url = await _uploadBytes(
        '${AppConstants.storageVisitsFolder}/$id/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        newPhotos[i],
      );
      photos.add(url);
    }
    String? voiceUrl = visit.voiceNoteUrl;
    if (newVoiceNote != null) {
      voiceUrl = await _uploadBytes(
        '${AppConstants.storageVoiceNotesFolder}/$id.m4a',
        newVoiceNote,
        contentType: 'audio/m4a',
      );
    }
    final data = visit.copyWith(
      id: id,
      photos: photos,
      voiceNoteUrl: voiceUrl,
      updatedAt: DateTime.now(),
    );
    await _col.doc(id).set(data.toJson(), SetOptions(merge: true));
    return data;
  }

  Future<void> markComplete(String id) async {
    await _col.doc(id).update({
      'status': VisitStatus.completed.key,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}

final visitRepositoryProvider = Provider<VisitRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return VisitRepository(
    ref.watch(firestoreProvider),
    (path, bytes, {String contentType = 'image/jpeg'}) =>
        storage.uploadBytes(path: path, bytes: bytes, contentType: contentType),
  );
});

final visitsForDoctorProvider = StreamProvider.family<List<Visit>, String>(
  (ref, doctorId) => ref.watch(visitRepositoryProvider).watchForDoctor(doctorId),
);

final visitsForDateProvider = StreamProvider.family<List<Visit>, DateTime>(
  (ref, date) => ref.watch(visitRepositoryProvider).watchForDate(date),
);

final visitsForFarmerProvider = StreamProvider.family<List<Visit>, String>(
  (ref, farmerId) => ref.watch(visitRepositoryProvider).watchForFarmer(farmerId),
);

final visitsForPlotProvider = StreamProvider.family<List<Visit>, String>(
  (ref, plotId) => ref.watch(visitRepositoryProvider).watchForPlot(plotId),
);

final visitByIdProvider = StreamProvider.family<Visit?, String>(
  (ref, id) => ref.watch(visitRepositoryProvider).watchOne(id),
);
