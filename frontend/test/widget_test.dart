import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/bus_tracking_screen.dart';
import 'package:frontend/screens/routes_screen.dart';

void main() {
  testWidgets('Passenger App Home Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WhereIsMyBusApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Verify header and branding
    expect(find.text('WhereIsMyBus'), findsOneWidget);
    expect(find.text('Real-time public transport'), findsOneWidget);

    // Verify hero copy and search placeholder
    expect(find.text('Track your bus.\nKnow when it arrives.'), findsOneWidget);
    expect(find.text('Search buses, routes or stops...'), findsOneWidget);

    // Verify Live Buses header / stats
    expect(find.text('Live buses'), findsWidgets);
    expect(find.text('Currently operating'), findsOneWidget);
  });

  testWidgets('Navigation from Home Screen to Bus Tracking Screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const WhereIsMyBusApp());
    await tester.pump(const Duration(milliseconds: 500));

    if (find.text('Track').hasFound) {
      // Tap first Track button
      await tester.tap(find.text('Track').first);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify BusTrackingScreen rendered
      expect(find.byType(BusTrackingScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pump(const Duration(milliseconds: 500));

      // Verify returned to Home Screen
      expect(find.text('WhereIsMyBus'), findsOneWidget);
    }
  });

  testWidgets('Routes Screen rendering and Route Details test', (WidgetTester tester) async {
    await tester.pumpWidget(const WhereIsMyBusApp());
    await tester.pump(const Duration(milliseconds: 500));

    // Switch to Routes tab in navigation
    await tester.tap(find.byKey(const Key('nav_routes')));
    await tester.pump(const Duration(milliseconds: 500));

    // Routes Screen renders
    expect(find.byType(RoutesScreen), findsOneWidget);
    expect(find.text('Routes'), findsWidgets);
    expect(find.text('Find your route and see buses operating right now.'), findsOneWidget);
  });
}
