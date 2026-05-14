import 'package:cloud_firestore/cloud_firestore.dart';

import 'plot.dart';

enum VisitStatus {
  planned('planned', 'Planned'),
  inProgress('in_progress', 'In progress'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  const VisitStatus(this.key, this.label);
  final String key;
  final String label;

  static VisitStatus fromKey(String? key) =>
      VisitStatus.values.firstWhere((v) => v.key == key, orElse: () => VisitStatus.planned);
}

class MedicineEntry {
  final String name;
  final String dosage;
  final String? frequency;
  final String? notes;

  const MedicineEntry({
    required this.name,
    required this.dosage,
    this.frequency,
    this.notes,
  });

  Map<String, dynamic> toJson() =>
      {'name': name, 'dosage': dosage, 'frequency': frequency, 'notes': notes};

  factory MedicineEntry.fromJson(Map<String, dynamic> json) => MedicineEntry(
        name: (json['name'] as String?) ?? '',
        dosage: (json['dosage'] as String?) ?? '',
        frequency: json['frequency'] as String?,
        notes: json['notes'] as String?,
      );
}

class Visit {
  final String id;
  final String farmerId;
  final String plotId;
  final String doctorId;
  final DateTime visitDate;
  final DateTime? nextVisitDate;
  final List<String> diseasesObserved;
  final List<MedicineEntry> medicines;
  final String? fertilizerRecommendation;
  final String? notes;
  final String? voiceNoteUrl;
  final List<String> photos;
  final PriorityLevel severity;
  final VisitStatus status;
  final bool followUpRequired;
  final double? feeCharged;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Cached denormalized labels for list rendering.
  final String? farmerName;
  final String? plotLabel;
  final String? village;

  const Visit({
    required this.id,
    required this.farmerId,
    required this.plotId,
    required this.doctorId,
    required this.visitDate,
    required this.createdAt,
    this.nextVisitDate,
    this.diseasesObserved = const [],
    this.medicines = const [],
    this.fertilizerRecommendation,
    this.notes,
    this.voiceNoteUrl,
    this.photos = const [],
    this.severity = PriorityLevel.low,
    this.status = VisitStatus.planned,
    this.followUpRequired = false,
    this.feeCharged,
    this.updatedAt,
    this.farmerName,
    this.plotLabel,
    this.village,
  });

  Visit copyWith({
    String? id,
    String? farmerId,
    String? plotId,
    String? doctorId,
    DateTime? visitDate,
    DateTime? nextVisitDate,
    List<String>? diseasesObserved,
    List<MedicineEntry>? medicines,
    String? fertilizerRecommendation,
    String? notes,
    String? voiceNoteUrl,
    List<String>? photos,
    PriorityLevel? severity,
    VisitStatus? status,
    bool? followUpRequired,
    double? feeCharged,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? farmerName,
    String? plotLabel,
    String? village,
  }) {
    return Visit(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      plotId: plotId ?? this.plotId,
      doctorId: doctorId ?? this.doctorId,
      visitDate: visitDate ?? this.visitDate,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      diseasesObserved: diseasesObserved ?? this.diseasesObserved,
      medicines: medicines ?? this.medicines,
      fertilizerRecommendation: fertilizerRecommendation ?? this.fertilizerRecommendation,
      notes: notes ?? this.notes,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      photos: photos ?? this.photos,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      feeCharged: feeCharged ?? this.feeCharged,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      farmerName: farmerName ?? this.farmerName,
      plotLabel: plotLabel ?? this.plotLabel,
      village: village ?? this.village,
    );
  }

  Map<String, dynamic> toJson() => {
        'farmerId': farmerId,
        'plotId': plotId,
        'doctorId': doctorId,
        'visitDate': Timestamp.fromDate(visitDate),
        'nextVisitDate': nextVisitDate != null ? Timestamp.fromDate(nextVisitDate!) : null,
        'diseasesObserved': diseasesObserved,
        'medicines': medicines.map((m) => m.toJson()).toList(),
        'fertilizerRecommendation': fertilizerRecommendation,
        'notes': notes,
        'voiceNoteUrl': voiceNoteUrl,
        'photos': photos,
        'severity': severity.key,
        'status': status.key,
        'followUpRequired': followUpRequired,
        'feeCharged': feeCharged,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'farmerName': farmerName,
        'plotLabel': plotLabel,
        'village': village,
      };

  factory Visit.fromJson(String id, Map<String, dynamic> json) {
    DateTime? d(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return null;
    }

    return Visit(
      id: id,
      farmerId: (json['farmerId'] as String?) ?? '',
      plotId: (json['plotId'] as String?) ?? '',
      doctorId: (json['doctorId'] as String?) ?? '',
      visitDate: d(json['visitDate']) ?? DateTime.now(),
      nextVisitDate: d(json['nextVisitDate']),
      diseasesObserved: (json['diseasesObserved'] as List?)?.cast<String>() ?? const [],
      medicines: ((json['medicines'] as List?) ?? const [])
          .map((m) => MedicineEntry.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
      fertilizerRecommendation: json['fertilizerRecommendation'] as String?,
      notes: json['notes'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      photos: (json['photos'] as List?)?.cast<String>() ?? const [],
      severity: PriorityLevel.fromKey(json['severity'] as String?),
      status: VisitStatus.fromKey(json['status'] as String?),
      followUpRequired: (json['followUpRequired'] as bool?) ?? false,
      feeCharged: (json['feeCharged'] as num?)?.toDouble(),
      createdAt: d(json['createdAt']) ?? DateTime.now(),
      updatedAt: d(json['updatedAt']),
      farmerName: json['farmerName'] as String?,
      plotLabel: json['plotLabel'] as String?,
      village: json['village'] as String?,
    );
  }
}
