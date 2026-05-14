import 'package:cloud_firestore/cloud_firestore.dart';

import 'geo_location.dart';

class Farmer {
  final String id;
  final String name;
  final String phone;
  final String? altPhone;
  final String? email;
  final String village;
  final String address;
  final GeoLocation? location;
  final String? profileImage;
  final String? notes;
  final List<String> tags;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Convenience denormalized fields populated by Cloud Functions / writes.
  final int plotCount;
  final int visitCount;
  final DateTime? lastVisitAt;
  final DateTime? nextVisitAt;

  const Farmer({
    required this.id,
    required this.name,
    required this.phone,
    required this.village,
    required this.address,
    required this.createdBy,
    required this.createdAt,
    this.altPhone,
    this.email,
    this.location,
    this.profileImage,
    this.notes,
    this.tags = const [],
    this.updatedAt,
    this.plotCount = 0,
    this.visitCount = 0,
    this.lastVisitAt,
    this.nextVisitAt,
  });

  Farmer copyWith({
    String? id,
    String? name,
    String? phone,
    String? altPhone,
    String? email,
    String? village,
    String? address,
    GeoLocation? location,
    String? profileImage,
    String? notes,
    List<String>? tags,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? plotCount,
    int? visitCount,
    DateTime? lastVisitAt,
    DateTime? nextVisitAt,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      email: email ?? this.email,
      village: village ?? this.village,
      address: address ?? this.address,
      location: location ?? this.location,
      profileImage: profileImage ?? this.profileImage,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      plotCount: plotCount ?? this.plotCount,
      visitCount: visitCount ?? this.visitCount,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      nextVisitAt: nextVisitAt ?? this.nextVisitAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'name_lower': name.toLowerCase(),
        'phone': phone,
        'altPhone': altPhone,
        'email': email,
        'village': village,
        'village_lower': village.toLowerCase(),
        'address': address,
        'location': location?.toJson(),
        'profileImage': profileImage,
        'notes': notes,
        'tags': tags,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'plotCount': plotCount,
        'visitCount': visitCount,
        'lastVisitAt': lastVisitAt != null ? Timestamp.fromDate(lastVisitAt!) : null,
        'nextVisitAt': nextVisitAt != null ? Timestamp.fromDate(nextVisitAt!) : null,
      };

  factory Farmer.fromJson(String id, Map<String, dynamic> json) {
    DateTime? d(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    return Farmer(
      id: id,
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      altPhone: json['altPhone'] as String?,
      email: json['email'] as String?,
      village: (json['village'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      location: json['location'] is Map<String, dynamic>
          ? GeoLocation.fromJson(Map<String, dynamic>.from(json['location'] as Map))
          : null,
      profileImage: json['profileImage'] as String?,
      notes: json['notes'] as String?,
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      createdBy: (json['createdBy'] as String?) ?? '',
      createdAt: d(json['createdAt']) ?? DateTime.now(),
      updatedAt: d(json['updatedAt']),
      plotCount: (json['plotCount'] as num?)?.toInt() ?? 0,
      visitCount: (json['visitCount'] as num?)?.toInt() ?? 0,
      lastVisitAt: d(json['lastVisitAt']),
      nextVisitAt: d(json['nextVisitAt']),
    );
  }
}
