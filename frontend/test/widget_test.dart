import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/bus_tracking_screen.dart';
import 'package:frontend/screens/routes_screen.dart';

void main() {
  testWidgets('Passenger App Home Screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WhereIsMyBusApp());
    await tester.pumpAndSettle();

    // Verify header and branding
    expect(find.text('WhereIsMyBus'), findsOneWidget);
    expect(find.text('Your city, moving with you'), findsOneWidget);

    // Verify search placeholder
    expect(find.text('Search bus number or route...'), findsOneWidget);

    // Verify Available Buses header
    expect(find.text('Live Buses Near You'), findsOneWidget);
  });

  testWidgets('Navigation from Home Screen to Bus Tracking Screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const WhereIsMyBusApp());
    await tester.pumpAndSettle();

    if (find.text('Track Bus').hasFound) {
      // Tap first Track Bus button
      await tester.tap(find.text('Track Bus').first);
      await tester.pumpAndSettle();

      // Verify BusTrackingScreen rendered
      expect(find.byType(BusTrackingScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();

      // Verify returned to Home Screen
      expect(find.text('WhereIsMyBus'), findsOneWidget);
    }
  });

  testWidgets('Routes Screen rendering and Route Details test', (WidgetTester tester) async {
    await tester.pumpWidget(const WhereIsMyBusApp());
    await tester.pumpAndSettle();

    // Switch to Routes tab in floating navigation
    await tester.tap(find.byIcon(Icons.alt_route_rounded).last);
    await tester.pumpAndSettle();

    // Routes Screen renders
    expect(find.byType(RoutesScreen), findsOneWidget);
    expect(find.text('Bus Routes'), findsOneWidget);
    expect(find.text('Explore transit lines and stops'), findsOneWidget);
  });
}
