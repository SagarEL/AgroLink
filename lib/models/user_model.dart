import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────
/// User Model — Represents authenticated users with roles
/// ─────────────────────────────────────────────────────────────
class UserModel {
  final String uid;
  final String role;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.role,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImage,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      role: map['role'] ?? 'farmer',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'phone': phone,
      'email': email,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
    };
  }

  UserModel copyWith({
    String? uid,
    String? role,
    String? name,
    String? phone,
    String? email,
    String? profileImage,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAdmin => role == 'admin' || role == 'doctor';
  bool get isFarmer => role == 'farmer';
  bool get isDriver => role == 'driver';
}
