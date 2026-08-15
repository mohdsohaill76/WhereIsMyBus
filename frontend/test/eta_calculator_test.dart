import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/live_location.dart';
import 'package:frontend/services/eta_calculator.dart';

void main() {
  group('EtaCalculator Tests', () {
    const double nextStopLat = 17.9820;
    const double nextStopLng = 79.5850;

    test('1. Normal moving bus calculates rounded minute ETA', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final location = LiveLocation(
        busId: 'BUS101',
        tripId: 'TRIP001',
        latitude: 17.9500, // ~3.7 km away
        longitude: 79.5850,
        speed: 35.0, // at 35 km/h, ~6.3 mins
        heading: 180.0,
        timestamp: now,
        currentStop: 'Hanamkonda',
        nextStop: 'Subedari',
        status: 'moving',
      );

      final eta = EtaCalculator.calculateEta(
        location: location,
        nextStopLat: nextStopLat,
        nextStopLng: nextStopLng,
      );

      expect(eta, startsWith('~'));
      expect(eta, endsWith('min'));
    });

    test('2. ETA under one minute returns Arriving', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final location = LiveLocation(
        busId: 'BUS101',
        tripId: 'TRIP001',
        latitude: 17.9819, // extremely close (a few meters away)
        longitude: 79.5849,
        speed: 30.0,
        heading: 180.0,
        timestamp: now,
        currentStop: 'Hanamkonda',
        nextStop: 'Subedari',
        status: 'moving',
      );

      final eta = EtaCalculator.calculateEta(
        location: location,
        nextStopLat: nextStopLat,
        nextStopLng: nextStopLng,
      );

      expect(eta, equals('Arriving'));
    });

    test('3. Zero speed returns Waiting', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final location = LiveLocation(
        busId: 'BUS101',
        tripId: 'TRIP001',
        latitude: 17.9784,
        longitude: 79.5941,
        speed: 0.0, // stopped
        heading: 180.0,
        timestamp: now,
        currentStop: 'Hanamkonda',
        nextStop: 'Subedari',
        status: 'stopped',
      );

      final eta = EtaCalculator.calculateEta(
        location: location,
        nextStopLat: nextStopLat,
        nextStopLng: nextStopLng,
      );

      expect(eta, equals('Waiting'));
    });

    test('4. Missing next stop returns ETA unavailable', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final location = LiveLocation(
        busId: 'BUS101',
        tripId: 'TRIP001',
        latitude: 17.9784,
        longitude: 79.5941,
        speed: 35.0,
        heading: 180.0,
        timestamp: now,
        currentStop: 'Hanamkonda',
        nextStop: '', // empty next stop
        status: 'moving',
      );

      final eta = EtaCalculator.calculateEta(
        location: location,
        nextStopLat: nextStopLat,
        nextStopLng: nextStopLng,
      );

      expect(eta, equals('ETA unavailable'));
    });

    test('5. Stale location (>30 seconds old) returns ETA unavailable', () {
      final staleTimestamp = DateTime.now().millisecondsSinceEpoch - 35000; // 35 seconds ago
      final location = LiveLocation(
        busId: 'BUS101',
        tripId: 'TRIP001',
        latitude: 17.9784,
        longitude: 79.5941,
        speed: 35.0,
        heading: 180.0,
        timestamp: staleTimestamp,
        currentStop: 'Hanamkonda',
        nextStop: 'Subedari',
        status: 'moving',
      );

      final eta = EtaCalculator.calculateEta(
        location: location,
        nextStopLat: nextStopLat,
        nextStopLng: nextStopLng,
      );

      expect(eta, equals('ETA unavailable'));
    });

    test('6. Invalid or missing next stop coordinates returns ETA unavailable', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final location = LiveLocation(
        busId: 'BUS101',
        tripId: 'TRIP001',
        latitude: 17.9784,
        longitude: 79.5941,
        speed: 35.0,
        heading: 180.0,
        timestamp: now,
        currentStop: 'Hanamkonda',
        nextStop: 'Subedari',
        status: 'moving',
      );

      final etaWithNullCoords = EtaCalculator.calculateEta(
        location: location,
        nextStopLat: null,
        nextStopLng: null,
      );

      final etaWithZeroCoords = EtaCalculator.calculateEta(
        location: location,
        nextStopLat: 0.0,
        nextStopLng: 0.0,
      );

      expect(etaWithNullCoords, equals('ETA unavailable'));
      expect(etaWithZeroCoords, equals('ETA unavailable'));
    });

    test('7. Null location returns ETA unavailable', () {
      final eta = EtaCalculator.calculateEta(
        location: null,
        nextStopLat: nextStopLat,
        nextStopLng: nextStopLng,
      );

      expect(eta, equals('ETA unavailable'));
    });
  });
}
