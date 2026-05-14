import 'dart:math';

/// Lightweight geographic helpers used by the route planner. Avoids pulling in
/// heavier mapping libraries on the data layer.
class GeoPoint {
  final double lat;
  final double lng;
  const GeoPoint(this.lat, this.lng);

  static const GeoPoint origin = GeoPoint(0, 0);

  /// Haversine distance in kilometers.
  double distanceToKm(GeoPoint other) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRad(other.lat - lat);
    final dLng = _toRad(other.lng - lng);
    final a = pow(sin(dLat / 2), 2) +
        cos(_toRad(lat)) * cos(_toRad(other.lat)) * pow(sin(dLng / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRad(double deg) => deg * pi / 180.0;
}

/// Greedy nearest-neighbor TSP — good enough for daily routes of <30 stops.
/// Returns the indices of [points] in optimized visit order, starting from
/// [start].
List<int> nearestNeighborOrder({
  required GeoPoint start,
  required List<GeoPoint> points,
}) {
  if (points.isEmpty) return const [];
  final remaining = List<int>.generate(points.length, (i) => i);
  final order = <int>[];
  var current = start;
  while (remaining.isNotEmpty) {
    var bestIdx = remaining.first;
    var bestDist = current.distanceToKm(points[bestIdx]);
    for (final idx in remaining) {
      final d = current.distanceToKm(points[idx]);
      if (d < bestDist) {
        bestDist = d;
        bestIdx = idx;
      }
    }
    order.add(bestIdx);
    remaining.remove(bestIdx);
    current = points[bestIdx];
  }
  return order;
}

double totalRouteDistanceKm(GeoPoint start, List<GeoPoint> orderedPoints) {
  var total = 0.0;
  var prev = start;
  for (final p in orderedPoints) {
    total += prev.distanceToKm(p);
    prev = p;
  }
  return total;
}
