import 'package:cloud_firestore/cloud_firestore.dart';

import 'geo_location.dart';

enum PriorityLevel {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  critical('critical', 'Critical');

  const PriorityLevel(this.key, this.label);
  final String key;
  final String label;

  static PriorityLevel fromKey(String? key) =>
      PriorityLevel.values.firstWhere((p) => p.key == key, orElse: () => PriorityLevel.low);
}

enum DiseaseStatus {
  healthy('healthy', 'Healthy'),
  observation('observation', 'Under observation'),
  infected('infected', 'Infected'),
  recovering('recovering', 'Recovering');

  const DiseaseStatus(this.key, this.label);
  final String key;
  final String label;

  static DiseaseStatus fromKey(String? key) =>
      DiseaseStatus.values.firstWhere((s) => s.key == key, orElse: () => DiseaseStatus.healthy);
}

class Plot {
  final String id;
  final String farmerId;
  final String label;
  final String cropType;
  final String? variety;
  final double acreage;
  final DateTime? plantingDate;
  final GeoLocation? location;
  final DiseaseStatus diseaseStatus;
  final PriorityLevel priorityLevel;
  final List<String> images;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastVisitAt;
  final DateTime? nextVisitAt;

  const Plot({
    required this.id,
    required this.farmerId,
    required this.label,
    required this.cropType,
    required this.acreage,
    required this.createdAt,
    this.variety,
    this.plantingDate,
    this.location,
    this.diseaseStatus = DiseaseStatus.healthy,
    this.priorityLevel = PriorityLevel.low,
    this.images = const [],
    this.notes,
    this.updatedAt,
    this.lastVisitAt,
    this.nextVisitAt,
  });

  Plot copyWith({
    String? id,
    String? farmerId,
    String? label,
    String? cropType,
    String? variety,
    double? acreage,
    DateTime? plantingDate,
    GeoLocation? location,
    DiseaseStatus? diseaseStatus,
    PriorityLevel? priorityLevel,
    List<String>? images,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastVisitAt,
    DateTime? nextVisitAt,
  }) {
    return Plot(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      label: label ?? this.label,
      cropType: cropType ?? this.cropType,
      variety: variety ?? this.variety,
      acreage: acreage ?? this.acreage,
      plantingDate: plantingDate ?? this.plantingDate,
      location: location ?? this.location,
      diseaseStatus: diseaseStatus ?? this.diseaseStatus,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastVisitAt: lastVisitAt ?? this.lastVisitAt,
      nextVisitAt: nextVisitAt ?? this.nextVisitAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'farmerId': farmerId,
        'label': label,
        'label_lower': label.toLowerCase(),
        'cropType': cropType,
        'variety': variety,
        'acreage': acreage,
        'plantingDate': plantingDate != null ? Timestamp.fromDate(plantingDate!) : null,
        'location': location?.toJson(),
        'diseaseStatus': diseaseStatus.key,
        'priorityLevel': priorityLevel.key,
        'images': images,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'lastVisitAt': lastVisitAt != null ? Timestamp.fromDate(lastVisitAt!) : null,
        'nextVisitAt': nextVisitAt != null ? Timestamp.fromDate(nextVisitAt!) : null,
      };

  factory Plot.fromJson(String id, Map<String, dynamic> json) {
    DateTime? d(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    return Plot(
      id: id,
      farmerId: (json['farmerId'] as String?) ?? '',
      label: (json['label'] as String?) ?? 'Plot',
      cropType: (json['cropType'] as String?) ?? 'Unknown',
      variety: json['variety'] as String?,
      acreage: (json['acreage'] as num?)?.toDouble() ?? 0,
      plantingDate: d(json['plantingDate']),
      location: json['location'] is Map<String, dynamic>
          ? GeoLocation.fromJson(Map<String, dynamic>.from(json['location'] as Map))
          : null,
      diseaseStatus: DiseaseStatus.fromKey(json['diseaseStatus'] as String?),
      priorityLevel: PriorityLevel.fromKey(json['priorityLevel'] as String?),
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      notes: json['notes'] as String?,
      createdAt: d(json['createdAt']) ?? DateTime.now(),
      updatedAt: d(json['updatedAt']),
      lastVisitAt: d(json['lastVisitAt']),
      nextVisitAt: d(json['nextVisitAt']),
    );
  }
}
