import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────
/// Notification Model
/// ─────────────────────────────────────────────────────────────
class NotificationModel {
  final String notificationId;
  final String title;
  final String body;
  final String targetUser;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.targetUser,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      notificationId: map['notificationId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      targetUser: map['targetUser'] ?? '',
      type: map['type'] ?? 'general',
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'title': title,
      'body': body,
      'targetUser': targetUser,
      'type': type,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? title,
    String? body,
    String? targetUser,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      body: body ?? this.body,
      targetUser: targetUser ?? this.targetUser,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }
}
