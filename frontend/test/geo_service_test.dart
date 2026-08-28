import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/bus_model.dart';
import 'package:frontend/models/route_model.dart';
import 'package:frontend/models/stop_model.dart';
import 'package:frontend/services/geo_service.dart';

void main() {
  group('GeoService & Geographic Calculations Unit Tests', () {
    final geoService = GeoService.instance;

    test('1. Distance between identical coordinates is zero', () {
      final d = geoService.calculateDistanceMeters(17.9784, 79.5941, 17.9784, 79.5941);
      expect(d, equals(0.0));
    });

    test('2. Haversine distance between known Warangal transit points is accurate (~7.7 km)', () {
      // Warangal Station (17.9784, 79.5941) to Kazipet Junction (17.9812, 79.5218)
      final distance = geoService.calculateDistanceMeters(17.9784, 79.5941, 17.9812, 79.5218);
      // Distance is ~7.67 km = ~7670 meters
      expect(distance, greaterThan(7500.0));
      expect(distance, lessThan(8000.0));
    });

    test('3. Walking time calculation produces reasonable estimates (~75 m/min)', () {
      expect(geoService.calculateWalkingMinutes(0), equals(1));
      expect(geoService.calculateWalkingMinutes(50), equals(1));
      expect(geoService.calculateWalkingMinutes(375), equals(5));
      expect(geoService.calculateWalkingMinutes(750), equals(10));
      expect(geoService.calculateWalkingMinutes(1500), equals(20));
    });

    test('4. calculateNearbyStops sorts stops by distance ascending and matches serving routes and active buses', () {
      final mockStops = [
        const StopModel(
          id: 'STOP_FAR',
          name: 'Kazipet Junction',
          shortName: 'KZJ',
          latitude: 17.9812,
          longitude: 79.5218,
          sequence: 2,
        ),
        const StopModel(
          id: 'STOP_NEAR',
          name: 'Warangal Station',
          shortName: 'WGL',
          latitude: 17.9785,
          longitude: 79.5940,
          sequence: 1,
        ),
      ];

      final mockRoutes = [
        const RouteModel(
          id: 'ROUTE_01',
          name: 'Warangal → Kazipet Express',
          description: 'Main Corridor',
          stops: [
            StopModel(id: 'STOP_NEAR', name: 'Warangal Station', shortName: 'WGL', latitude: 17.9785, longitude: 79.5940, sequence: 1),
            StopModel(id: 'STOP_FAR', name: 'Kazipet Junction', shortName: 'KZJ', latitude: 17.9812, longitude: 79.5218, sequence: 2),
          ],
          assignedBusIds: ['BUS101'],
        ),
      ];

      final mockBuses = [
        BusModel(
          id: 'BUS101',
          busNumber: 'BUS 101',
          routeId: 'ROUTE_01',
          routeName: 'Warangal → Kazipet Express',
          status: 'Moving',
        ),
      ];

      // Passenger is at Warangal Station (17.9784, 79.5941)
      final nearby = geoService.calculateNearbyStops(
        userLat: 17.9784,
        userLng: 79.5941,
        stops: mockStops,
        routes: mockRoutes,
        buses: mockBuses,
      );

      expect(nearby.length, equals(2));
      // Closest stop must be STOP_NEAR (~15 meters)
      expect(nearby[0].id, equals('STOP_NEAR'));
      expect(nearby[0].distanceMeters, lessThan(100.0));
      expect(nearby[0].distanceLabel, contains('m'));
      expect(nearby[0].estimatedWalkingMinutes, equals(1));
      expect(nearby[0].servingRoutes.length, equals(1));
      expect(nearby[0].activeBusCount, equals(1));

      // Second stop is STOP_FAR (~7.7 km)
      expect(nearby[1].id, equals('STOP_FAR'));
      expect(nearby[1].distanceMeters, greaterThan(7000.0));
      expect(nearby[1].distanceLabel, contains('km'));
    });
  });
}
