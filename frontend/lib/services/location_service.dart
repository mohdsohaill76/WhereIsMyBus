import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus {
  initial,
  requesting,
  ready,
  denied,
  permanentlyDenied,
  unavailable,
  error,
}

class LocationResult {
  final LocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? message;

  const LocationResult({
    required this.status,
    this.latitude,
    this.longitude,
    this.message,
  });

  bool get isReady => status == LocationStatus.ready && latitude != null && longitude != null;
}

/// Robust Location Service encapsulating platform permissions and GPS acquisition
class LocationService {
  static final LocationService instance = LocationService._internal();

  factory LocationService() => instance;

  LocationService._internal();

  // Default transit center fallback (Warangal Central Transit Hub)
  static const double fallbackLat = 17.9784;
  static const double fallbackLng = 79.5941;

  final ValueNotifier<LocationStatus> statusNotifier =
      ValueNotifier<LocationStatus>(LocationStatus.initial);

  LocationResult? lastKnownResult;

  /// Obtains current GPS coordinates with complete permission and hardware safety
  Future<LocationResult> getCurrentPosition({bool requestIfDenied = true}) async {
    statusNotifier.value = LocationStatus.requesting;

    try {
      // 1. Verify hardware location services are enabled
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        final result = const LocationResult(
          status: LocationStatus.unavailable,
          message: 'Location services are disabled on your device.',
        );
        statusNotifier.value = LocationStatus.unavailable;
        lastKnownResult = result;
        return result;
      }

      // 2. Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied && requestIfDenied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        final result = const LocationResult(
          status: LocationStatus.denied,
          message: 'Location permission was denied. You can still select stops manually.',
        );
        statusNotifier.value = LocationStatus.denied;
        lastKnownResult = result;
        return result;
      }

      if (permission == LocationPermission.deniedForever) {
        final result = const LocationResult(
          status: LocationStatus.permanentlyDenied,
          message: 'Location permission is permanently denied in browser/system settings.',
        );
        statusNotifier.value = LocationStatus.permanentlyDenied;
        lastKnownResult = result;
        return result;
      }

      // 3. Acquire high-accuracy position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final result = LocationResult(
        status: LocationStatus.ready,
        latitude: position.latitude,
        longitude: position.longitude,
        message: 'Location acquired successfully.',
      );

      statusNotifier.value = LocationStatus.ready;
      lastKnownResult = result;
      return result;
    } catch (e) {
      final result = LocationResult(
        status: LocationStatus.error,
        message: 'Could not obtain location: ${e.toString().replaceAll('Exception: ', '')}',
      );
      statusNotifier.value = LocationStatus.error;
      lastKnownResult = result;
      return result;
    }
  }

  /// Clears cached state (useful for test isolation)
  void reset() {
    statusNotifier.value = LocationStatus.initial;
    lastKnownResult = null;
  }
}
