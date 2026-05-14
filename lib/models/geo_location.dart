import 'package:cloud_firestore/cloud_firestore.dart';

/// A geographical coordinate plus optional human-readable address fields. We
/// don't use Firestore's GeoPoint directly so the model can travel via JSON.
class GeoLocation {
  final double lat;
  final double lng;
  final String? address;
  final String? village;
  final String? district;

  const GeoLocation({
    required this.lat,
    required this.lng,
    this.address,
    this.village,
    this.district,
  });

  GeoLocation copyWith({
    double? lat,
    double? lng,
    String? address,
    String? village,
    String? district,
  }) {
    return GeoLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      village: village ?? this.village,
      district: district ?? this.district,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'point': GeoPoint(lat, lng),
        'address': address,
        'village': village,
        'district': district,
      };

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    double parse(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    final point = json['point'];
    if (point is GeoPoint) {
      return GeoLocation(
        lat: point.latitude,
        lng: point.longitude,
        address: json['address'] as String?,
        village: json['village'] as String?,
        district: json['district'] as String?,
      );
    }
    return GeoLocation(
      lat: parse(json['lat']),
      lng: parse(json['lng']),
      address: json['address'] as String?,
      village: json['village'] as String?,
      district: json['district'] as String?,
    );
  }
}
