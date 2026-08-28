import 'stop_model.dart';
import 'route_model.dart';

/// Augmented Stop model enriched with geographic distance, walking estimates, and transit intelligence
class NearbyStop {
  final StopModel stop;
  final double distanceMeters;
  final List<RouteModel> servingRoutes;
  final int activeBusCount;

  const NearbyStop({
    required this.stop,
    required this.distanceMeters,
    this.servingRoutes = const [],
    this.activeBusCount = 0,
  });

  String get id => stop.id;
  String get name => stop.name;
  String get shortName => stop.shortName;
  double get latitude => stop.latitude;
  double get longitude => stop.longitude;
  int get sequence => stop.sequence;

  /// Human-readable distance formatted cleanly (e.g. "350 m" or "1.4 km")
  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m';
    }
    final km = distanceMeters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Estimated walking time assuming standard pedestrian velocity (~4.5 km/h ≈ 75 m/min)
  int get estimatedWalkingMinutes {
    if (distanceMeters <= 50) return 1;
    final mins = (distanceMeters / 75.0).ceil();
    return mins.clamp(1, 999);
  }

  /// Formatted walking label (e.g. "~5 min walk")
  String get walkingLabel => '~$estimatedWalkingMinutes min walk';

  /// Number of transit corridors servicing this stop
  int get routeCount => servingRoutes.length;

  /// Formatted route count label (e.g. "3 routes")
  String get routeCountLabel {
    final count = servingRoutes.length;
    return '$count ${count == 1 ? 'route' : 'routes'}';
  }

  /// Formatted live bus count label (e.g. "2 buses nearby")
  String get activeBusLabel {
    if (activeBusCount <= 0) return 'No live buses';
    return '$activeBusCount ${activeBusCount == 1 ? 'bus' : 'buses'} nearby';
  }
}
