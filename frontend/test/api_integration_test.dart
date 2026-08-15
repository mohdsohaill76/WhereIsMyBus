import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/bus_model.dart';
import 'package:frontend/models/live_location.dart';
import 'package:frontend/models/route_model.dart';
import 'package:frontend/models/stop_model.dart';

void main() {
  group('Backend API Response Parsing Unit Tests', () {
    test('1. Successful buses API JSON parsing (dictionary map)', () {
      final jsonMap = {
        "BUS101": {
          "busNumber": "101",
          "routeId": "WGL01",
          "status": "offline"
        }
      };

      final bus = BusModel.fromJson("BUS101", jsonMap["BUS101"]!);
      expect(bus.id, equals('BUS101'));
      expect(bus.busNumber, equals('Bus 101'));
      expect(bus.routeId, equals('WGL01'));
      expect(bus.status, equals('offline'));
    });

    test('2. Successful routes API JSON parsing (with stopIds)', () {
      final routeJson = {
        "WGL01": {
          "name": "Warangal → Kazipet",
          "stopIds": ["STOP001", "STOP002", "STOP003"]
        }
      };

      final route = RouteModel.fromJson("WGL01", routeJson["WGL01"]!);
      expect(route.id, equals('WGL01'));
      expect(route.name, equals('Warangal → Kazipet'));
      expect(route.stopCount, equals(3));
      expect(route.stops.first.id, equals('STOP001'));
    });

    test('3. Successful stops API JSON parsing', () {
      final stopJson = {
        "STOP001": {
          "name": "Hanamkonda",
          "latitude": 17.9784,
          "longitude": 79.5941
        }
      };

      final stop = StopModel.fromJson("STOP001", stopJson["STOP001"]!, 1);
      expect(stop.id, equals('STOP001'));
      expect(stop.name, equals('Hanamkonda'));
      expect(stop.latitude, equals(17.9784));
      expect(stop.longitude, equals(79.5941));
    });

    test('4. Successful live location telemetry API JSON parsing', () {
      final telemetryJson = {
        "latitude": 17.9784,
        "longitude": 79.5941,
        "speed": 35,
        "heading": 180,
        "timestamp": 1786732544000,
        "currentStop": "STOP001",
        "nextStop": "STOP002"
      };

      final location = LiveLocation.fromJson(telemetryJson);
      expect(location.latitude, equals(17.9784));
      expect(location.longitude, equals(79.5941));
      expect(location.speed, equals(35.0));
      expect(location.currentStop, equals('STOP001'));
      expect(location.nextStop, equals('STOP002'));
    });
  });
}
