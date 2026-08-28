import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/location_service.dart';

void main() {
  group('LocationService Unit Tests', () {
    final locationService = LocationService.instance;

    setUp(() {
      locationService.reset();
    });

    test('1. Initial state is LocationStatus.initial with no cached position', () {
      expect(locationService.statusNotifier.value, equals(LocationStatus.initial));
      expect(locationService.lastKnownResult, isNull);
    });

    test('2. LocationResult helper properties identify ready state accurately', () {
      const readyResult = LocationResult(
        status: LocationStatus.ready,
        latitude: 17.9784,
        longitude: 79.5941,
        message: 'Acquired',
      );
      expect(readyResult.isReady, isTrue);

      const deniedResult = LocationResult(
        status: LocationStatus.denied,
        message: 'Denied',
      );
      expect(deniedResult.isReady, isFalse);

      const missingCoordResult = LocationResult(
        status: LocationStatus.ready,
        message: 'No coordinates',
      );
      expect(missingCoordResult.isReady, isFalse);
    });

    test('3. Fallback coordinates represent Warangal Transit Central Hub', () {
      expect(LocationService.fallbackLat, equals(17.9784));
      expect(LocationService.fallbackLng, equals(79.5941));
    });
  });
}
