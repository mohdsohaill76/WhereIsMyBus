import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recent_activity_item.dart';
import '../services/storage_service.dart';
import '../screens/bus_tracking_screen.dart';
import '../screens/routes_screen.dart';

/// Recent Activity List component displaying passenger interaction history
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return ValueListenableBuilder<List<RecentActivityItem>>(
      valueListenable: storage.recentActivitiesNotifier,
      builder: (context, recents, _) {
        if (recents.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: AppTheme.primaryBlueLight,
                      size: 20,
                    ),
                    SizedBox(width: AppTheme.space8),
                    Text(
                      'Recent Activity',
                      style: AppTheme.titleLarge,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => storage.clearRecentActivities(),
                  child: const Text(
                    'Clear History',
                    style: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space8),

            // Activity Item List (capped display)
            ...recents.take(5).map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: AppTheme.space8),
                decoration: AppTheme.cardDecoration(
                  background: AppTheme.surfaceLayer1,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(item.icon, color: item.accentColor, size: 18),
                    ),
                    title: Text(item.title, style: AppTheme.titleSmall),
                    subtitle: Text(item.subtitle, style: AppTheme.caption, maxLines: 1),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.formattedTime, style: AppTheme.caption),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textTertiary,
                          size: 18,
                        ),
                      ],
                    ),
                    onTap: () {
                      if (item.isBus) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BusTrackingScreen(
                              busNumber: item.id,
                              routeName: item.subtitle,
                            ),
                          ),
                        );
                      } else if (item.isRoute) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RoutesScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space24),
          ],
        );
      },
    );
  }
}
