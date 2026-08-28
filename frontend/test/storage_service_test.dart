import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/favorite_item.dart';
import 'package:frontend/models/recent_activity_item.dart';
import 'package:frontend/services/storage_service.dart';

void main() {
  group('StorageService Unit Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService.instance;
      await storage.init();
      await storage.clearAll();
    });

    test('1. Save and retrieve favorites', () async {
      final item = FavoriteItem(
        type: 'bus',
        id: 'BUS101',
        title: 'BUS 101',
        subtitle: 'Warangal → Kazipet',
        savedAt: DateTime.now().millisecondsSinceEpoch,
      );

      await storage.addFavorite(item);

      expect(storage.getFavorites().length, 1);
      expect(storage.isFavorite('bus', 'BUS101'), true);
      expect(storage.isFavorite('bus', 'bus101'), true); // case-insensitive check
      expect(storage.isFavorite('route', 'BUS101'), false);
    });

    test('2. Filter favorites by type', () async {
      await storage.addFavorite(
        FavoriteItem(type: 'bus', id: 'BUS101', title: 'BUS 101', subtitle: 'Route A', savedAt: 1),
      );
      await storage.addFavorite(
        FavoriteItem(type: 'route', id: 'WGL01', title: 'Corridor 1', subtitle: '4 stops', savedAt: 2),
      );
      await storage.addFavorite(
        FavoriteItem(type: 'stop', id: 'STOP001', title: 'Hanamkonda Station', subtitle: 'Code: HNK', savedAt: 3),
      );

      expect(storage.getFavorites().length, 3);
      expect(storage.getFavoritesByType('bus').length, 1);
      expect(storage.getFavoritesByType('route').length, 1);
      expect(storage.getFavoritesByType('stop').length, 1);
    });

    test('3. Remove and toggle favorites', () async {
      final item = FavoriteItem(
        type: 'bus',
        id: 'BUS102',
        title: 'BUS 102',
        subtitle: 'Kazipet → NIT',
        savedAt: 100,
      );

      final added = await storage.toggleFavorite(item);
      expect(added, true);
      expect(storage.isFavorite('bus', 'BUS102'), true);

      final removed = await storage.toggleFavorite(item);
      expect(removed, false);
      expect(storage.isFavorite('bus', 'BUS102'), false);
    });

    test('4. Recent activity persistence and deduplication', () async {
      final act1 = RecentActivityItem(
        type: 'bus',
        id: 'BUS101',
        title: 'BUS 101',
        subtitle: 'Active line',
        viewedAt: 1000,
      );
      final act2 = RecentActivityItem(
        type: 'route',
        id: 'WGL01',
        title: 'Route WGL01',
        subtitle: 'Corridor',
        viewedAt: 2000,
      );
      final act1New = RecentActivityItem(
        type: 'bus',
        id: 'BUS101',
        title: 'BUS 101',
        subtitle: 'Active line (re-viewed)',
        viewedAt: 3000,
      );

      await storage.addRecentActivity(act1);
      await storage.addRecentActivity(act2);
      expect(storage.getRecentActivities().length, 2);
      expect(storage.getRecentActivities().first.id, 'WGL01');

      // Re-adding BUS101 moves it to the top without creating duplicate
      await storage.addRecentActivity(act1New);
      expect(storage.getRecentActivities().length, 2);
      expect(storage.getRecentActivities().first.id, 'BUS101');
      expect(storage.getRecentActivities().first.subtitle, 'Active line (re-viewed)');
    });

    test('5. Clear recent activities', () async {
      await storage.addRecentActivity(
        RecentActivityItem(type: 'bus', id: 'BUS101', title: 'Bus', subtitle: 'Sub', viewedAt: 1),
      );
      expect(storage.getRecentActivities().isNotEmpty, true);

      await storage.clearRecentActivities();
      expect(storage.getRecentActivities().isEmpty, true);
    });
  });
}
