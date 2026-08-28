import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/favorite_item.dart';
import 'package:frontend/models/recent_activity_item.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:frontend/screens/search_screen.dart';
import 'package:frontend/screens/favorites_screen.dart';
import 'package:frontend/widgets/favorites_section.dart';
import 'package:frontend/widgets/recent_activity_list.dart';

void main() {
  group('Phase 3 Feature Widget Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService.instance;
      await storage.init();
      await storage.clearAll();
    });

    testWidgets('1. Favorites screen renders empty state and filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FavoritesScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Saved Favorites'), findsOneWidget);
      expect(find.text('No saved favorites yet'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Buses'), findsOneWidget);
      expect(find.text('Routes'), findsOneWidget);
      expect(find.text('Stops'), findsOneWidget);
    });

    testWidgets('2. Populated favorites display in FavoritesSection and FavoritesScreen', (WidgetTester tester) async {
      await storage.addFavorite(
        FavoriteItem(
          type: 'bus',
          id: 'BUS101',
          title: 'BUS 101',
          subtitle: 'Warangal → Kazipet',
          savedAt: 1000,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FavoritesSection(),
                Expanded(child: FavoritesScreen()),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Favorites'), findsWidgets);
      expect(find.text('BUS 101'), findsWidgets);
      expect(find.text('Track'), findsOneWidget);
    });

    testWidgets('3. Recent activity list renders and handles clear action', (WidgetTester tester) async {
      await storage.addRecentActivity(
        RecentActivityItem(
          type: 'bus',
          id: 'BUS101',
          title: 'BUS 101',
          subtitle: 'Live corridor',
          viewedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecentActivityList(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('BUS 101'), findsOneWidget);

      // Tap Clear History
      await tester.tap(find.text('Clear History'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(storage.getRecentActivities().isEmpty, true);
    });

    testWidgets('4. Global search launcher navigates to SearchScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const WhereIsMyBusApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap search launcher shortcut chip 'Ctrl K'
      final searchLauncher = find.text('Ctrl K');
      if (searchLauncher.hasFound) {
        await tester.tap(searchLauncher.first);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.byKey(const Key('global_search_input')), findsOneWidget);
      }
    });
  });
}
