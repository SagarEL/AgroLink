import 'package:cloud_firestore/cloud_firestore.dart';

class RouteStop {
  final String visitId;
  final String farmerId;
  final String plotId;
  final String label;
  final String? village;
  final double lat;
  final double lng;
  final bool completed;

  const RouteStop({
    required this.visitId,
    required this.farmerId,
    required this.plotId,
    required this.label,
    required this.lat,
    required this.lng,
    this.village,
    this.completed = false,
  });

  RouteStop copyWith({bool? completed}) => RouteStop(
        visitId: visitId,
        farmerId: farmerId,
        plotId: plotId,
        label: label,
        village: village,
        lat: lat,
        lng: lng,
        completed: completed ?? this.completed,
      );

  Map<String, dynamic> toJson() => {
        'visitId': visitId,
        'farmerId': farmerId,
        'plotId': plotId,
        'label': label,
        'village': village,
        'lat': lat,
        'lng': lng,
        'completed': completed,
      };

  factory RouteStop.fromJson(Map<String, dynamic> json) => RouteStop(
        visitId: (json['visitId'] as String?) ?? '',
        farmerId: (json['farmerId'] as String?) ?? '',
        plotId: (json['plotId'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        village: json['village'] as String?,
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        completed: (json['completed'] as bool?) ?? false,
      );
}

class RoutePlan {
  final String id;
  final String doctorId;
  final DateTime routeDate;
  final List<RouteStop> stops;
  final double totalDistanceKm;
  final Duration estimatedTime;
  final double startLat;
  final double startLng;
  final DateTime createdAt;

  const RoutePlan({
    required this.id,
    required this.doctorId,
    required this.routeDate,
    required this.stops,
    required this.totalDistanceKm,
    required this.estimatedTime,
    required this.startLat,
    required this.startLng,
    required this.createdAt,
  });

  int get completedCount => stops.where((s) => s.completed).length;
  double get progress => stops.isEmpty ? 0 : completedCount / stops.length;

  RoutePlan copyWith({List<RouteStop>? stops}) => RoutePlan(
        id: id,
        doctorId: doctorId,
        routeDate: routeDate,
        stops: stops ?? this.stops,
        totalDistanceKm: totalDistanceKm,
        estimatedTime: estimatedTime,
        startLat: startLat,
        startLng: startLng,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'routeDate': Timestamp.fromDate(routeDate),
        'stops': stops.map((s) => s.toJson()).toList(),
        'totalDistanceKm': totalDistanceKm,
        'estimatedMinutes': estimatedTime.inMinutes,
        'startLat': startLat,
        'startLng': startLng,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory RoutePlan.fromJson(String id, Map<String, dynamic> json) {
    DateTime d(dynamic v, DateTime fallback) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return fallback;
    }

    return RoutePlan(
      id: id,
      doctorId: (json['doctorId'] as String?) ?? '',
      routeDate: d(json['routeDate'], DateTime.now()),
      stops: ((json['stops'] as List?) ?? const [])
          .map((s) => RouteStop.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      estimatedTime: Duration(minutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 0),
      startLat: (json['startLat'] as num?)?.toDouble() ?? 0,
      startLng: (json['startLng'] as num?)?.toDouble() ?? 0,
      createdAt: d(json['createdAt'], DateTime.now()),
    );
  }
}
