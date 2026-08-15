import 'dart:math';
import '../models/live_location.dart';

class EtaCalculator {
  /// Earth's radius in kilometers
  static const double _earthRadiusKm = 6371.0;

  /// Calculates passenger-friendly ETA string to the next stop.
  static String calculateEta({
    required LiveLocation? location,
    required double? nextStopLat,
    required double? nextStopLng,
  }) {
    // Rule 1: Null location check
    if (location == null) {
      return 'ETA unavailable';
    }

    // Rule 2: Stale location (>30s) -> ETA is unreliable
    if (location.isStale) {
      return 'ETA unavailable';
    }

    // Rule 3: Check valid bus coordinates
    if (location.latitude == 0.0 && location.longitude == 0.0) {
      return 'ETA unavailable';
    }

    // Rule 4: Check valid next stop coordinates
    if (nextStopLat == null || nextStopLng == null || (nextStopLat == 0.0 && nextStopLng == 0.0)) {
      return 'ETA unavailable';
    }

    // Rule 5: Check next stop name validity
    if (location.nextStop.trim().isEmpty) {
      return 'ETA unavailable';
    }

    // Rule 6: Stopped or near zero speed
    if (location.speed <= 1.0) {
      return 'Waiting';
    }

    // Rule 7: Calculate Haversine distance in kilometers
    final distanceKm = _haversineDistanceKm(
      location.latitude,
      location.longitude,
      nextStopLat,
      nextStopLng,
    );

    // Rule 8: Calculate time in minutes (speed is in km/h)
    final timeInHours = distanceKm / location.speed;
    final timeInMinutes = timeInHours * 60.0;

    // Rule 9: Sub-minute arrival
    if (timeInMinutes < 1.0) {
      return 'Arriving';
    }

    // Rule 10: Rounded minutes
    final roundedMins = timeInMinutes.round();
    return '~$roundedMins min';
  }

  /// Calculates Haversine distance between two lat/lng points in kilometers.
  static double _haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }
}
