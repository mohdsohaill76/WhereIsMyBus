import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/app_shell.dart';
import 'package:frontend/screens/nearby_screen.dart';
import 'package:frontend/screens/favorites_screen.dart';
import 'package:frontend/screens/routes_screen.dart';
import 'package:frontend/screens/home_screen.dart';

void main() {
  group('AppShell & Responsive Layout Tests', () {
    testWidgets('1. AppShell mounts and displays all 4 primary navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const WhereIsMyBusApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verify bottom/rail navigation items exist by key
      expect(find.byKey(const Key('nav_buses')), findsOneWidget);
      expect(find.byKey(const Key('nav_nearby')), findsOneWidget);
      expect(find.byKey(const Key('nav_routes')), findsOneWidget);
      expect(find.byKey(const Key('nav_favorites')), findsOneWidget);
    });

    testWidgets('2. Navigation to Nearby tab renders NearbyScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const WhereIsMyBusApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Nearby nav item
      await tester.tap(find.byKey(const Key('nav_nearby')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(NearbyScreen), findsOneWidget);
      expect(find.text('Nearby Transit'), findsOneWidget);
      expect(find.text('Find stops and buses around you'), findsOneWidget);
    });

    testWidgets('3. Navigation to Favorites tab renders FavoritesScreen placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(const WhereIsMyBusApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Favorites nav item
      await tester.tap(find.byKey(const Key('nav_favorites')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FavoritesScreen), findsOneWidget);
      expect(find.text('Saved Favorites'), findsOneWidget);
      expect(find.text('Fast access to your frequent buses, routes & stops'), findsOneWidget);
    });

    testWidgets('4. Navigation to Routes tab renders RoutesScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const WhereIsMyBusApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Routes nav item
      await tester.tap(find.byKey(const Key('nav_routes')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(RoutesScreen), findsOneWidget);
      expect(find.text('Routes'), findsWidgets);
    });

    testWidgets('5. Desktop responsive breakpoint renders sidebar workbench without overflow', (WidgetTester tester) async {
      // Set desktop window size: 1440x900
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const WhereIsMyBusApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Passenger Transit V2'), findsOneWidget);
      expect(find.text('RTDB Live Connected'), findsOneWidget);
      expect(find.text('NAVIGATION'), findsOneWidget);
    });
  });
}
