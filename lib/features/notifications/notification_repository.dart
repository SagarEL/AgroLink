import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/providers.dart';
import '../../models/app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._firestore);
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestorePaths.notifications);

  Stream<List<AppNotification>> watchForUser(String uid, {int limit = 100}) {
    return _col
        .where('targetUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => AppNotification.fromJson(d.id, d.data())).toList());
  }

  Stream<int> unreadCount(String uid) {
    return _col
        .where('targetUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.size);
  }

  Future<void> markRead(String id) async {
    await _col.doc(id).update({'isRead': true});
  }

  Future<void> markAllRead(String uid) async {
    final unread = await _col
        .where('targetUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .limit(200)
        .get();
    final batch = _firestore.batch();
    for (final d in unread.docs) {
      batch.update(d.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> create(AppNotification n) async {
    final id = n.id.isEmpty ? const Uuid().v4() : n.id;
    await _col.doc(id).set({...n.toJson(), 'createdAt': FieldValue.serverTimestamp()});
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(firestoreProvider));
});

final notificationsProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, uid) {
  return ref.watch(notificationRepositoryProvider).watchForUser(uid);
});

final unreadCountProvider = StreamProvider.family<int, String>((ref, uid) {
  return ref.watch(notificationRepositoryProvider).unreadCount(uid);
});
