import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/stop_model.dart';
import 'package:frontend/models/route_model.dart';
import 'package:frontend/models/nearby_stop.dart';
import 'package:frontend/widgets/nearby_stop_card.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/nearby_screen.dart';
import 'package:frontend/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4 Nearby Transit Radar Widget Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService.instance;
      await storage.init();
      await storage.clearAll();
    });

    testWidgets('1. NearbyStopCard renders name, distance, walking estimate, route count, and live bus badge', (WidgetTester tester) async {
      const mockStop = StopModel(
        id: 'STOP001',
        name: 'Central Bus Station',
        shortName: 'CBS',
        latitude: 17.9784,
        longitude: 79.5941,
        sequence: 1,
      );

      const mockRoute = RouteModel(
        id: 'R01',
        name: 'Warangal Express',
        description: 'Main Corridor',
        stops: [mockStop],
        assignedBusIds: ['BUS101'],
      );

      final nearbyStop = NearbyStop(
        stop: mockStop,
        distanceMeters: 350.0,
        servingRoutes: const [mockRoute],
        activeBusCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearbyStopCard(
              nearbyStop: nearbyStop,
            ),
          ),
        ),
      );

      expect(find.text('Central Bus Station'), findsOneWidget);
      expect(find.text('CBS'), findsOneWidget);
      expect(find.text('350 m • ~5 min walk'), findsOneWidget);
      expect(find.text('1 route'), findsOneWidget);
      expect(find.text('2 buses nearby'), findsOneWidget);
    });

    testWidgets('2. NearbyStopCard favorite button toggles bookmark state', (WidgetTester tester) async {
      const mockStop = StopModel(
        id: 'STOP001',
        name: 'Central Bus Station',
        shortName: 'CBS',
        latitude: 17.9784,
        longitude: 79.5941,
        sequence: 1,
      );

      final nearbyStop = NearbyStop(
        stop: mockStop,
        distanceMeters: 400.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NearbyStopCard(
              nearbyStop: nearbyStop,
            ),
          ),
        ),
      );

      expect(storage.isFavorite('stop', 'STOP001'), isFalse);

      // Tap favorite button
      final favButton = find.byType(IconButton);
      expect(favButton, findsOneWidget);
      await tester.tap(favButton);
      await tester.pump();

      expect(storage.isFavorite('stop', 'STOP001'), isTrue);
    });

    testWidgets('3. HomeScreen displays "Find transit near you" location card', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Find transit near you'), findsOneWidget);
      expect(find.text('Enable location'), findsOneWidget);
    });

    testWidgets('4. NearbyScreen mounts and renders header and action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NearbyScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Nearby Transit'), findsOneWidget);
      expect(find.text('Find stops and buses around you'), findsOneWidget);
      expect(find.text('Select Stop'), findsOneWidget);
    });
  });
}
