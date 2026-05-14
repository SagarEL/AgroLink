import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  visitReminder('visit_reminder'),
  followUp('follow_up'),
  missedVisit('missed_visit'),
  criticalAlert('critical_alert'),
  routeUpdate('route_update'),
  system('system');

  const NotificationType(this.key);
  final String key;

  static NotificationType fromKey(String? key) =>
      NotificationType.values.firstWhere((t) => t.key == key, orElse: () => NotificationType.system);
}

class AppNotification {
  final String id;
  final String targetUid;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.targetUid,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.data = const {},
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        targetUid: targetUid,
        title: title,
        body: body,
        type: type,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'targetUid': targetUid,
        'title': title,
        'body': body,
        'type': type.key,
        'data': data,
        'isRead': isRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory AppNotification.fromJson(String id, Map<String, dynamic> json) {
    DateTime d(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
    return AppNotification(
      id: id,
      targetUid: (json['targetUid'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      type: NotificationType.fromKey(json['type'] as String?),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      isRead: (json['isRead'] as bool?) ?? false,
      createdAt: d(json['createdAt']),
    );
  }
}
