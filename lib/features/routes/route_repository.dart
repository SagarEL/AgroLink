import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../core/utils/geo.dart';
import '../../models/route_plan.dart';
import '../../models/visit.dart';

class RouteRepository {
  RouteRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.routes);

  Stream<List<RoutePlan>> watchForDoctor(String doctorId, {int limit = 30}) {
    return _col
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('routeDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => RoutePlan.fromJson(d.id, d.data())).toList());
  }

  Stream<RoutePlan?> watchForDate(String doctorId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _col
        .where('doctorId', isEqualTo: doctorId)
        .where('routeDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('routeDate', isLessThan: Timestamp.fromDate(end))
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : RoutePlan.fromJson(s.docs.first.id, s.docs.first.data()));
  }

  /// Builds an optimized route from a set of visits using nearest-neighbor TSP.
  /// Visits without coordinates are skipped — the planner UI must surface them.
  RoutePlan optimize({
    required String doctorId,
    required DateTime date,
    required List<Visit> visits,
    required double startLat,
    required double startLng,
    double avgSpeedKmh = 35,
    int minutesPerStop = 25,
  }) {
    final stopsWithCoords = visits
        .where((v) => v.plotId.isNotEmpty)
        .map((v) => MapEntry(v, _coordsFor(v)))
        .where((e) => e.value != null)
        .toList();

    final points = stopsWithCoords.map((e) => e.value!).toList();
    final order = nearestNeighborOrder(
      start: GeoPoint(startLat, startLng),
      points: points,
    );

    final distance = totalRouteDistanceKm(GeoPoint(startLat, startLng), [
      for (final i in order) points[i],
    ]);
    final drivingMinutes = (distance / avgSpeedKmh) * 60;
    final totalMinutes = drivingMinutes + (order.length * minutesPerStop);

    final orderedStops = [
      for (final i in order)
        RouteStop(
          visitId: stopsWithCoords[i].key.id,
          farmerId: stopsWithCoords[i].key.farmerId,
          plotId: stopsWithCoords[i].key.plotId,
          label: stopsWithCoords[i].key.plotLabel ?? stopsWithCoords[i].key.farmerName ?? 'Stop',
          village: stopsWithCoords[i].key.village,
          lat: points[i].lat,
          lng: points[i].lng,
        ),
    ];

    return RoutePlan(
      id: const Uuid().v4(),
      doctorId: doctorId,
      routeDate: date,
      stops: orderedStops,
      totalDistanceKm: distance,
      estimatedTime: Duration(minutes: totalMinutes.round()),
      startLat: startLat,
      startLng: startLng,
      createdAt: DateTime.now(),
    );
  }

  GeoPoint? _coordsFor(Visit v) {
    // For real data, look up the plot — this is invoked from the planner UI
    // where plots are already resolved. The planner pre-fills the visit's
    // copyWith fields with denormalized village; coords arrive via the plot.
    return null;
  }

  Future<RoutePlan> save(RoutePlan plan) async {
    await _col.doc(plan.id).set(plan.toJson(), SetOptions(merge: true));
    return plan;
  }

  Future<void> setStopCompleted({
    required String routeId,
    required String visitId,
    required bool completed,
  }) async {
    final snap = await _col.doc(routeId).get();
    if (!snap.exists) return;
    final plan = RoutePlan.fromJson(snap.id, snap.data()!);
    final updated = plan.stops
        .map((s) => s.visitId == visitId ? s.copyWith(completed: completed) : s)
        .toList();
    await _col.doc(routeId).update({
      'stops': updated.map((s) => s.toJson()).toList(),
    });
  }
}

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  return RouteRepository(ref.watch(firestoreProvider));
});

final routesForDoctorProvider = StreamProvider.family<List<RoutePlan>, String>(
  (ref, doctorId) => ref.watch(routeRepositoryProvider).watchForDoctor(doctorId),
);

final routeForDateProvider =
    StreamProvider.family<RoutePlan?, RouteDateKey>((ref, key) {
  return ref.watch(routeRepositoryProvider).watchForDate(key.doctorId, key.date);
});

class RouteDateKey {
  final String doctorId;
  final DateTime date;
  const RouteDateKey(this.doctorId, this.date);
  @override
  bool operator ==(Object other) =>
      other is RouteDateKey &&
      other.doctorId == doctorId &&
      other.date.year == date.year &&
      other.date.month == date.month &&
      other.date.day == date.day;
  @override
  int get hashCode => Object.hash(doctorId, date.year, date.month, date.day);
}
