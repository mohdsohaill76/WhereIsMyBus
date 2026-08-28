import 'dart:math' as math;
import '../models/stop_model.dart';
import '../models/route_model.dart';
import '../models/bus_model.dart';
import '../models/nearby_stop.dart';

/// Geographic calculation service providing Haversine distance and transit radar intelligence
class GeoService {
  static final GeoService instance = GeoService._internal();

  factory GeoService() => instance;

  GeoService._internal();

  static const double earthRadiusMeters = 6371000.0;
  static const double walkingMetersPerMinute = 75.0; // ~4.5 km/h

  /// Calculates geodesic distance between two coordinate pairs in meters using the Haversine formula
  double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    if (lat1 == lat2 && lon1 == lon2) return 0.0;

    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a));
    return earthRadiusMeters * c;
  }

  /// Calculates approximate walking time in minutes
  int calculateWalkingMinutes(double distanceMeters) {
    if (distanceMeters <= 50) return 1;
    return (distanceMeters / walkingMetersPerMinute).ceil().clamp(1, 999);
  }

  /// Evaluates and correlates all transit stops against passenger location, sorted by proximity
  List<NearbyStop> calculateNearbyStops({
    required double userLat,
    required double userLng,
    required List<StopModel> stops,
    required List<RouteModel> routes,
    required List<BusModel> buses,
  }) {
    final List<NearbyStop> nearby = [];

    for (final stop in stops) {
      final distance = calculateDistanceMeters(
        userLat,
        userLng,
        stop.latitude,
        stop.longitude,
      );

      // Identify routes servicing this stop
      final servingRoutes = routes.where((r) {
        return r.stops.any((s) =>
            s.id.toUpperCase() == stop.id.toUpperCase() ||
            s.name.trim().toLowerCase() == stop.name.trim().toLowerCase());
      }).toList();

      // Count active/live buses running along these corridors
      final servingRouteIds = servingRoutes.map((r) => r.id.toUpperCase()).toSet();
      final servingRouteNames = servingRoutes.map((r) => r.name.toLowerCase()).toSet();

      final activeBuses = buses.where((b) {
        final isAssigned = servingRouteIds.contains(b.routeId.toUpperCase()) ||
            servingRouteNames.contains(b.routeName.toLowerCase());
        final isLive = b.status.toLowerCase() == 'moving' ||
            b.status.toLowerCase() == 'active' ||
            b.status.toLowerCase() == 'in_transit' ||
            b.status.toLowerCase() == 'live';
        return isAssigned && isLive;
      }).length;

      nearby.add(
        NearbyStop(
          stop: stop,
          distanceMeters: distance,
          servingRoutes: servingRoutes,
          activeBusCount: activeBuses,
        ),
      );
    }

    // Sort by proximity ascending
    nearby.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return nearby;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
}
