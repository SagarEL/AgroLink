import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────
/// Plot Model — Represents a farm plot/field
/// ─────────────────────────────────────────────────────────────
class PlotModel {
  final String plotId;
  final String farmerId;
  final String farmerName;
  final String cropType;
  final double acreage;
  final String location;
  final Map<String, double>? geoCoordinates;
  final String diseaseStatus;
  final String priorityLevel;
  final List<String> images;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int totalVisits;
  final String? lastVisitDate;
  final String? yieldNotes;
  final bool isActive;

  const PlotModel({
    required this.plotId,
    required this.farmerId,
    required this.farmerName,
    required this.cropType,
    required this.acreage,
    required this.location,
    this.geoCoordinates,
    this.diseaseStatus = 'healthy',
    this.priorityLevel = 'normal',
    this.images = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.totalVisits = 0,
    this.lastVisitDate,
    this.yieldNotes,
    this.isActive = true,
  });

  factory PlotModel.fromMap(Map<String, dynamic> map) {
    return PlotModel(
      plotId: map['plotId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      cropType: map['cropType'] ?? '',
      acreage: (map['acreage'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      geoCoordinates: map['geoCoordinates'] != null
          ? Map<String, double>.from(map['geoCoordinates'])
          : null,
      diseaseStatus: map['diseaseStatus'] ?? 'healthy',
      priorityLevel: map['priorityLevel'] ?? 'normal',
      images: List<String>.from(map['images'] ?? []),
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      totalVisits: map['totalVisits'] ?? 0,
      lastVisitDate: map['lastVisitDate'],
      yieldNotes: map['yieldNotes'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plotId': plotId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'cropType': cropType,
      'acreage': acreage,
      'location': location,
      'geoCoordinates': geoCoordinates,
      'diseaseStatus': diseaseStatus,
      'priorityLevel': priorityLevel,
      'images': images,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'totalVisits': totalVisits,
      'lastVisitDate': lastVisitDate,
      'yieldNotes': yieldNotes,
      'isActive': isActive,
    };
  }

  PlotModel copyWith({
    String? plotId,
    String? farmerId,
    String? farmerName,
    String? cropType,
    double? acreage,
    String? location,
    Map<String, double>? geoCoordinates,
    String? diseaseStatus,
    String? priorityLevel,
    List<String>? images,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalVisits,
    String? lastVisitDate,
    String? yieldNotes,
    bool? isActive,
  }) {
    return PlotModel(
      plotId: plotId ?? this.plotId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      cropType: cropType ?? this.cropType,
      acreage: acreage ?? this.acreage,
      location: location ?? this.location,
      geoCoordinates: geoCoordinates ?? this.geoCoordinates,
      diseaseStatus: diseaseStatus ?? this.diseaseStatus,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalVisits: totalVisits ?? this.totalVisits,
      lastVisitDate: lastVisitDate ?? this.lastVisitDate,
      yieldNotes: yieldNotes ?? this.yieldNotes,
      isActive: isActive ?? this.isActive,
    );
  }
}
