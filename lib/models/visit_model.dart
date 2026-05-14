import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────
/// Visit Model — Represents a farm visit/consultation
/// ─────────────────────────────────────────────────────────────
class VisitModel {
  final String visitId;
  final String farmerId;
  final String farmerName;
  final String plotId;
  final String doctorId;
  final DateTime visitDate;
  final DateTime? nextVisitDate;
  final String status;
  final List<String> diseaseObserved;
  final List<String> medicinesGiven;
  final String? fertilizerRecommendation;
  final String? notes;
  final String? voiceNotes;
  final List<String> photos;
  final String severity;
  final bool followUpRequired;
  final String? village;
  final double? consultationFee;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const VisitModel({
    required this.visitId,
    required this.farmerId,
    required this.farmerName,
    required this.plotId,
    required this.doctorId,
    required this.visitDate,
    this.nextVisitDate,
    this.status = 'scheduled',
    this.diseaseObserved = const [],
    this.medicinesGiven = const [],
    this.fertilizerRecommendation,
    this.notes,
    this.voiceNotes,
    this.photos = const [],
    this.severity = 'low',
    this.followUpRequired = false,
    this.village,
    this.consultationFee,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory VisitModel.fromMap(Map<String, dynamic> map) {
    return VisitModel(
      visitId: map['visitId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      plotId: map['plotId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      visitDate: (map['visitDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      nextVisitDate: (map['nextVisitDate'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'scheduled',
      diseaseObserved: List<String>.from(map['diseaseObserved'] ?? []),
      medicinesGiven: List<String>.from(map['medicinesGiven'] ?? []),
      fertilizerRecommendation: map['fertilizerRecommendation'],
      notes: map['notes'],
      voiceNotes: map['voiceNotes'],
      photos: List<String>.from(map['photos'] ?? []),
      severity: map['severity'] ?? 'low',
      followUpRequired: map['followUpRequired'] ?? false,
      village: map['village'],
      consultationFee: (map['consultationFee'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'plotId': plotId,
      'doctorId': doctorId,
      'visitDate': Timestamp.fromDate(visitDate),
      'nextVisitDate':
          nextVisitDate != null ? Timestamp.fromDate(nextVisitDate!) : null,
      'status': status,
      'diseaseObserved': diseaseObserved,
      'medicinesGiven': medicinesGiven,
      'fertilizerRecommendation': fertilizerRecommendation,
      'notes': notes,
      'voiceNotes': voiceNotes,
      'photos': photos,
      'severity': severity,
      'followUpRequired': followUpRequired,
      'village': village,
      'consultationFee': consultationFee,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  VisitModel copyWith({
    String? visitId,
    String? farmerId,
    String? farmerName,
    String? plotId,
    String? doctorId,
    DateTime? visitDate,
    DateTime? nextVisitDate,
    String? status,
    List<String>? diseaseObserved,
    List<String>? medicinesGiven,
    String? fertilizerRecommendation,
    String? notes,
    String? voiceNotes,
    List<String>? photos,
    String? severity,
    bool? followUpRequired,
    String? village,
    double? consultationFee,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return VisitModel(
      visitId: visitId ?? this.visitId,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      plotId: plotId ?? this.plotId,
      doctorId: doctorId ?? this.doctorId,
      visitDate: visitDate ?? this.visitDate,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      status: status ?? this.status,
      diseaseObserved: diseaseObserved ?? this.diseaseObserved,
      medicinesGiven: medicinesGiven ?? this.medicinesGiven,
      fertilizerRecommendation:
          fertilizerRecommendation ?? this.fertilizerRecommendation,
      notes: notes ?? this.notes,
      voiceNotes: voiceNotes ?? this.voiceNotes,
      photos: photos ?? this.photos,
      severity: severity ?? this.severity,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      village: village ?? this.village,
      consultationFee: consultationFee ?? this.consultationFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isScheduled => status == 'scheduled';
  bool get isCritical => severity == 'critical';
  bool get isOverdue =>
      status == 'scheduled' && visitDate.isBefore(DateTime.now());
}
