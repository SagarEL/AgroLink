import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────
/// Farmer Model — Represents a farmer/client
/// ─────────────────────────────────────────────────────────────
class FarmerModel {
  final String farmerId;
  final String farmerName;
  final String phone;
  final String village;
  final String address;
  final Map<String, double>? geoLocation;
  final String? notes;
  final String? profileImage;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int totalPlots;
  final int totalVisits;
  final String? lastVisitDate;
  final bool isActive;

  const FarmerModel({
    required this.farmerId,
    required this.farmerName,
    required this.phone,
    required this.village,
    required this.address,
    this.geoLocation,
    this.notes,
    this.profileImage,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.totalPlots = 0,
    this.totalVisits = 0,
    this.lastVisitDate,
    this.isActive = true,
  });

  factory FarmerModel.fromMap(Map<String, dynamic> map) {
    return FarmerModel(
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      phone: map['phone'] ?? '',
      village: map['village'] ?? '',
      address: map['address'] ?? '',
      geoLocation: map['geoLocation'] != null
          ? Map<String, double>.from(map['geoLocation'])
          : null,
      notes: map['notes'],
      profileImage: map['profileImage'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      totalPlots: map['totalPlots'] ?? 0,
      totalVisits: map['totalVisits'] ?? 0,
      lastVisitDate: map['lastVisitDate'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'phone': phone,
      'village': village,
      'address': address,
      'geoLocation': geoLocation,
      'notes': notes,
      'profileImage': profileImage,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'totalPlots': totalPlots,
      'totalVisits': totalVisits,
      'lastVisitDate': lastVisitDate,
      'isActive': isActive,
    };
  }

  FarmerModel copyWith({
    String? farmerId,
    String? farmerName,
    String? phone,
    String? village,
    String? address,
    Map<String, double>? geoLocation,
    String? notes,
    String? profileImage,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalPlots,
    int? totalVisits,
    String? lastVisitDate,
    bool? isActive,
  }) {
    return FarmerModel(
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      phone: phone ?? this.phone,
      village: village ?? this.village,
      address: address ?? this.address,
      geoLocation: geoLocation ?? this.geoLocation,
      notes: notes ?? this.notes,
      profileImage: profileImage ?? this.profileImage,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalPlots: totalPlots ?? this.totalPlots,
      totalVisits: totalVisits ?? this.totalVisits,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
