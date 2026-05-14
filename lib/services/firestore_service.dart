import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:agrolink/core/constants/app_constants.dart';
import 'package:agrolink/models/farmer_model.dart';
import 'package:agrolink/models/plot_model.dart';
import 'package:agrolink/models/visit_model.dart';
import 'package:agrolink/models/route_model.dart';
import 'package:agrolink/models/notification_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ── FARMERS ───────────────────────────────────────────────

  Stream<List<FarmerModel>> streamFarmers() {
    return _db.collection(AppConstants.farmersCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('farmerName')
        .snapshots()
        .map((s) => s.docs.map((d) => FarmerModel.fromMap(d.data())).toList());
  }

  Future<FarmerModel?> getFarmer(String id) async {
    final doc = await _db.collection(AppConstants.farmersCollection).doc(id).get();
    return doc.exists ? FarmerModel.fromMap(doc.data()!) : null;
  }

  Future<FarmerModel> addFarmer(FarmerModel farmer) async {
    final id = _uuid.v4();
    final f = farmer.copyWith(farmerId: id, createdAt: DateTime.now());
    await _db.collection(AppConstants.farmersCollection).doc(id).set(f.toMap());
    return f;
  }

  Future<void> updateFarmer(FarmerModel farmer) async {
    await _db.collection(AppConstants.farmersCollection).doc(farmer.farmerId)
        .update(farmer.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deleteFarmer(String id) async {
    await _db.collection(AppConstants.farmersCollection).doc(id).update({'isActive': false});
  }

  Future<int> getFarmerCount() async {
    final s = await _db.collection(AppConstants.farmersCollection)
        .where('isActive', isEqualTo: true).count().get();
    return s.count ?? 0;
  }

  Future<List<String>> getVillages() async {
    final s = await _db.collection(AppConstants.farmersCollection)
        .where('isActive', isEqualTo: true).get();
    final v = s.docs.map((d) => d.data()['village'] as String? ?? '')
        .where((v) => v.isNotEmpty).toSet().toList()..sort();
    return v;
  }

  // ── PLOTS ─────────────────────────────────────────────────

  Stream<List<PlotModel>> streamPlots() {
    return _db.collection(AppConstants.plotsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PlotModel.fromMap(d.data())).toList());
  }

  Stream<List<PlotModel>> streamPlotsByFarmer(String farmerId) {
    return _db.collection(AppConstants.plotsCollection)
        .where('farmerId', isEqualTo: farmerId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => PlotModel.fromMap(d.data())).toList());
  }

  Future<PlotModel> addPlot(PlotModel plot) async {
    final id = _uuid.v4();
    final p = plot.copyWith(plotId: id, createdAt: DateTime.now());
    await _db.collection(AppConstants.plotsCollection).doc(id).set(p.toMap());
    await _db.collection(AppConstants.farmersCollection).doc(plot.farmerId)
        .update({'totalPlots': FieldValue.increment(1)});
    return p;
  }

  Future<void> updatePlot(PlotModel plot) async {
    await _db.collection(AppConstants.plotsCollection).doc(plot.plotId)
        .update(plot.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> deletePlot(String plotId, String farmerId) async {
    await _db.collection(AppConstants.plotsCollection).doc(plotId).update({'isActive': false});
    await _db.collection(AppConstants.farmersCollection).doc(farmerId)
        .update({'totalPlots': FieldValue.increment(-1)});
  }

  Future<int> getPlotCount() async {
    final s = await _db.collection(AppConstants.plotsCollection)
        .where('isActive', isEqualTo: true).count().get();
    return s.count ?? 0;
  }

  // ── VISITS ────────────────────────────────────────────────

  Stream<List<VisitModel>> streamVisits() {
    return _db.collection(AppConstants.visitsCollection)
        .orderBy('visitDate', descending: true).limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => VisitModel.fromMap(d.data())).toList());
  }

  Stream<List<VisitModel>> streamVisitsByFarmer(String farmerId) {
    return _db.collection(AppConstants.visitsCollection)
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('visitDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => VisitModel.fromMap(d.data())).toList());
  }

  Stream<List<VisitModel>> streamTodaysVisits(String doctorId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _db.collection(AppConstants.visitsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('visitDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('visitDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((s) => s.docs.map((d) => VisitModel.fromMap(d.data())).toList());
  }

  Stream<List<VisitModel>> streamUpcomingVisits(String doctorId) {
    return _db.collection(AppConstants.visitsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: AppConstants.visitScheduled)
        .where('visitDate', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('visitDate').limit(20)
        .snapshots()
        .map((s) => s.docs.map((d) => VisitModel.fromMap(d.data())).toList());
  }

  Future<VisitModel> addVisit(VisitModel visit) async {
    final id = _uuid.v4();
    final v = visit.copyWith(visitId: id, createdAt: DateTime.now());
    await _db.collection(AppConstants.visitsCollection).doc(id).set(v.toMap());
    await _db.collection(AppConstants.farmersCollection).doc(visit.farmerId).update({
      'totalVisits': FieldValue.increment(1),
      'lastVisitDate': v.visitDate.toIso8601String(),
    });
    await _db.collection(AppConstants.plotsCollection).doc(visit.plotId).update({
      'totalVisits': FieldValue.increment(1),
      'lastVisitDate': v.visitDate.toIso8601String(),
    });
    return v;
  }

  Future<void> updateVisit(VisitModel visit) async {
    await _db.collection(AppConstants.visitsCollection).doc(visit.visitId)
        .update(visit.copyWith(updatedAt: DateTime.now()).toMap());
  }

  Future<void> completeVisit(String visitId) async {
    await _db.collection(AppConstants.visitsCollection).doc(visitId).update({
      'status': AppConstants.visitCompleted,
      'completedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<int> getVisitCount({DateTime? since}) async {
    Query q = _db.collection(AppConstants.visitsCollection);
    if (since != null) q = q.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(since));
    final s = await q.count().get();
    return s.count ?? 0;
  }

  Future<int> getCriticalVisitsCount() async {
    final s = await _db.collection(AppConstants.visitsCollection)
        .where('severity', isEqualTo: AppConstants.severityCritical)
        .where('status', isEqualTo: AppConstants.visitScheduled)
        .count().get();
    return s.count ?? 0;
  }

  // ── ROUTES ────────────────────────────────────────────────

  Stream<List<RouteModel>> streamRoutes(String doctorId) {
    return _db.collection(AppConstants.routesCollection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('routeDate', descending: true).limit(30)
        .snapshots()
        .map((s) => s.docs.map((d) => RouteModel.fromMap(d.data())).toList());
  }

  Future<RouteModel> addRoute(RouteModel route) async {
    final id = _uuid.v4();
    final r = route.copyWith(routeId: id, createdAt: DateTime.now());
    await _db.collection(AppConstants.routesCollection).doc(id).set(r.toMap());
    return r;
  }

  Future<void> updateRoute(RouteModel route) async {
    await _db.collection(AppConstants.routesCollection).doc(route.routeId).update(route.toMap());
  }

  // ── NOTIFICATIONS ─────────────────────────────────────────

  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _db.collection(AppConstants.notificationsCollection)
        .where('targetUser', isEqualTo: userId)
        .orderBy('createdAt', descending: true).limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => NotificationModel.fromMap(d.data())).toList());
  }

  Future<void> addNotification(NotificationModel n) async {
    final id = _uuid.v4();
    final notif = n.copyWith(notificationId: id, createdAt: DateTime.now());
    await _db.collection(AppConstants.notificationsCollection).doc(id).set(notif.toMap());
  }

  Future<void> markNotificationRead(String id) async {
    await _db.collection(AppConstants.notificationsCollection).doc(id).update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final s = await _db.collection(AppConstants.notificationsCollection)
        .where('targetUser', isEqualTo: userId).where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (final d in s.docs) batch.update(d.reference, {'isRead': true});
    await batch.commit();
  }

  Stream<int> streamUnreadCount(String userId) {
    return _db.collection(AppConstants.notificationsCollection)
        .where('targetUser', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots().map((s) => s.docs.length);
  }

  // ── ANALYTICS ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    final fc = await getFarmerCount();
    final pc = await getPlotCount();
    final now = DateTime.now();
    final ms = DateTime(now.year, now.month, 1);
    final tv = await getVisitCount();
    final mv = await getVisitCount(since: ms);
    final cc = await getCriticalVisitsCount();
    return {'totalFarmers': fc, 'totalPlots': pc, 'totalVisits': tv,
      'monthlyVisits': mv, 'criticalCases': cc};
  }

  Future<Map<String, int>> getDiseaseStats() async {
    final s = await _db.collection(AppConstants.visitsCollection)
        .where('status', isEqualTo: AppConstants.visitCompleted).get();
    final Map<String, int> m = {};
    for (final d in s.docs) {
      for (final dis in List<String>.from(d.data()['diseaseObserved'] ?? [])) {
        m[dis] = (m[dis] ?? 0) + 1;
      }
    }
    return m;
  }

  Future<Map<String, int>> getVillageStats() async {
    final s = await _db.collection(AppConstants.farmersCollection)
        .where('isActive', isEqualTo: true).get();
    final Map<String, int> m = {};
    for (final d in s.docs) {
      final v = d.data()['village'] as String? ?? 'Unknown';
      m[v] = (m[v] ?? 0) + 1;
    }
    return m;
  }
}
