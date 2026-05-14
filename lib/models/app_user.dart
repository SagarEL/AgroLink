import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles enforced both client-side (route guards) and server-side (security
/// rules / custom claims). Keep keys lowercase and stable — they're persisted.
enum UserRole {
  admin('admin'),
  farmer('farmer'),
  driver('driver');

  const UserRole(this.key);
  final String key;

  static UserRole fromKey(String? key) {
    return UserRole.values.firstWhere(
      (r) => r.key == key,
      orElse: () => UserRole.farmer,
    );
  }

  String get label => switch (this) {
        UserRole.admin => 'Doctor / Admin',
        UserRole.farmer => 'Farmer',
        UserRole.driver => 'Driver',
      };
}

class AppUser {
  final String uid;
  final UserRole role;
  final String name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String? fcmToken;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.role,
    required this.name,
    required this.createdAt,
    this.email,
    this.phone,
    this.profileImage,
    this.fcmToken,
  });

  AppUser copyWith({
    String? uid,
    UserRole? role,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role.key,
        'name': name,
        'email': email,
        'phone': phone,
        'profileImage': profileImage,
        'fcmToken': fcmToken,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory AppUser.fromJson(String uid, Map<String, dynamic> json) {
    return AppUser(
      uid: uid,
      role: UserRole.fromKey(json['role'] as String?),
      name: (json['name'] as String?) ?? 'Unnamed',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
      fcmToken: json['fcmToken'] as String?,
      createdAt: _toDate(json['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _toDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
