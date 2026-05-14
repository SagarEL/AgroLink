import 'package:cloud_firestore/cloud_firestore.dart';

/// ─────────────────────────────────────────────────────────────
/// Route Model — Represents an optimized visit route
/// ─────────────────────────────────────────────────────────────
class RouteModel {
  final String routeId;
  final String doctorId;
  final List<String> visitIds;
  final List<RouteStop> stops;
  final List<int> optimizedOrder;
  final double? totalDistance;
  final double? estimatedTime;
  final DateTime routeDate;
  final String status;
  final DateTime createdAt;
  final int completedStops;

  const RouteModel({
    required this.routeId,
    required this.doctorId,
    required this.visitIds,
    this.stops = const [],
    this.optimizedOrder = const [],
    this.totalDistance,
    this.estimatedTime,
    required this.routeDate,
    this.status = 'planned',
    required this.createdAt,
    this.completedStops = 0,
  });

  factory RouteModel.fromMap(Map<String, dynamic> map) {
    return RouteModel(
      routeId: map['routeId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      visitIds: List<String>.from(map['visitIds'] ?? []),
      stops: (map['stops'] as List<dynamic>?)
              ?.map((s) => RouteStop.fromMap(s))
              .toList() ??
          [],
      optimizedOrder: List<int>.from(map['optimizedOrder'] ?? []),
      totalDistance: (map['totalDistance'] ?? 0).toDouble(),
      estimatedTime: (map['estimatedTime'] ?? 0).toDouble(),
      routeDate: (map['routeDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'planned',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedStops: map['completedStops'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routeId': routeId,
      'doctorId': doctorId,
      'visitIds': visitIds,
      'stops': stops.map((s) => s.toMap()).toList(),
      'optimizedOrder': optimizedOrder,
      'totalDistance': totalDistance,
      'estimatedTime': estimatedTime,
      'routeDate': Timestamp.fromDate(routeDate),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedStops': completedStops,
    };
  }

  RouteModel copyWith({
    String? routeId,
    String? doctorId,
    List<String>? visitIds,
    List<RouteStop>? stops,
    List<int>? optimizedOrder,
    double? totalDistance,
    double? estimatedTime,
    DateTime? routeDate,
    String? status,
    DateTime? createdAt,
    int? completedStops,
  }) {
    return RouteModel(
      routeId: routeId ?? this.routeId,
      doctorId: doctorId ?? this.doctorId,
      visitIds: visitIds ?? this.visitIds,
      stops: stops ?? this.stops,
      optimizedOrder: optimizedOrder ?? this.optimizedOrder,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      routeDate: routeDate ?? this.routeDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedStops: completedStops ?? this.completedStops,
    );
  }

  double get progressPercent =>
      stops.isEmpty ? 0 : completedStops / stops.length;
}

/// A single stop in the route
class RouteStop {
  final String visitId;
  final String farmerId;
  final String farmerName;
  final String village;
  final double? lat;
  final double? lng;
  final bool isCompleted;
  final int order;

  const RouteStop({
    required this.visitId,
    required this.farmerId,
    required this.farmerName,
    required this.village,
    this.lat,
    this.lng,
    this.isCompleted = false,
    this.order = 0,
  });

  factory RouteStop.fromMap(Map<String, dynamic> map) {
    return RouteStop(
      visitId: map['visitId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      village: map['village'] ?? '',
      lat: map['lat']?.toDouble(),
      lng: map['lng']?.toDouble(),
      isCompleted: map['isCompleted'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'village': village,
      'lat': lat,
      'lng': lng,
      'isCompleted': isCompleted,
      'order': order,
    };
  }
}
