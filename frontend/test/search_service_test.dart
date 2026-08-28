import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/bus_model.dart';
import 'package:frontend/models/route_model.dart';
import 'package:frontend/models/stop_model.dart';
import 'package:frontend/services/search_service.dart';

void main() {
  group('SearchService Unit Tests', () {
    final searchService = SearchService.instance;

    final mockBuses = [
      BusModel(
        id: 'BUS101',
        busNumber: 'BUS 101',
        routeId: 'WGL01',
        routeName: 'Warangal → Kazipet',
        status: 'Moving',
      ),
      BusModel(
        id: 'BUS102',
        busNumber: 'BUS 102',
        routeId: 'WGL02',
        routeName: 'Hanamkonda → NIT',
        status: 'Stopped',
      ),
    ];

    final mockRoutes = [
      RouteModel(
        id: 'WGL01',
        name: 'Warangal → Kazipet',
        description: 'Main Corridor',
        stops: [
          StopModel(id: 'STOP001', name: 'Warangal Station', shortName: 'WGL', latitude: 17.97, longitude: 79.59, sequence: 1),
          StopModel(id: 'STOP002', name: 'Kazipet Junction', shortName: 'KZJ', latitude: 17.98, longitude: 79.52, sequence: 2),
        ],
        assignedBusIds: ['BUS101'],
      ),
      RouteModel(
        id: 'WGL02',
        name: 'Hanamkonda → NIT',
        description: 'University Express',
        stops: [
          StopModel(id: 'STOP003', name: 'Hanamkonda Bus Station', shortName: 'HNK', latitude: 18.01, longitude: 79.55, sequence: 1),
          StopModel(id: 'STOP004', name: 'NIT Warangal Gate', shortName: 'NIT', latitude: 17.98, longitude: 79.53, sequence: 2),
        ],
        assignedBusIds: ['BUS102'],
      ),
    ];

    final mockStops = [
      StopModel(id: 'STOP001', name: 'Warangal Station', shortName: 'WGL', latitude: 17.97, longitude: 79.59, sequence: 1),
      StopModel(id: 'STOP002', name: 'Kazipet Junction', shortName: 'KZJ', latitude: 17.98, longitude: 79.52, sequence: 2),
      StopModel(id: 'STOP003', name: 'Hanamkonda Bus Station', shortName: 'HNK', latitude: 18.01, longitude: 79.55, sequence: 1),
      StopModel(id: 'STOP004', name: 'NIT Warangal Gate', shortName: 'NIT', latitude: 17.98, longitude: 79.53, sequence: 2),
    ];

    test('1. Empty query returns empty results', () {
      final results = searchService.search(
        query: '',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );
      expect(results.isEmpty, true);
    });

    test('2. Bus matching by number and ID', () {
      final results = searchService.search(
        query: '101',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );

      expect(results.isNotEmpty, true);
      final busResult = results.firstWhere((r) => r.isBus);
      expect(busResult.id, 'BUS101');
      expect(busResult.title, 'BUS 101');
    });

    test('3. Route matching by ID and corridor name', () {
      final results = searchService.search(
        query: 'Kazipet',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );

      expect(results.any((r) => r.isRoute), true);
      expect(results.any((r) => r.isStop), true);
    });

    test('4. Stop matching by station name and short code', () {
      final results = searchService.search(
        query: 'HNK',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );

      expect(results.isNotEmpty, true);
      final stopResult = results.firstWhere((r) => r.isStop);
      expect(stopResult.id, 'STOP003');
      expect(stopResult.title, 'Hanamkonda Bus Station');
    });

    test('5. Type filtering isolates specific entities', () {
      final busOnly = searchService.search(
        query: 'Warangal',
        typeFilter: 'buses',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );
      expect(busOnly.every((r) => r.isBus), true);

      final routeOnly = searchService.search(
        query: 'Warangal',
        typeFilter: 'routes',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );
      expect(routeOnly.every((r) => r.isRoute), true);

      final stopOnly = searchService.search(
        query: 'Warangal',
        typeFilter: 'stops',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );
      expect(stopOnly.every((r) => r.isStop), true);
    });

    test('6. Relevance scoring prioritizes exact matches', () {
      final results = searchService.search(
        query: 'BUS101',
        buses: mockBuses,
        routes: mockRoutes,
        stops: mockStops,
      );

      expect(results.first.id, 'BUS101');
      expect(results.first.relevanceScore >= 80.0, true);
    });
  });
}
