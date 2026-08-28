import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/favorite_item.dart';
import '../models/recent_activity_item.dart';
import '../services/storage_service.dart';
import '../screens/bus_tracking_screen.dart';
import '../screens/routes_screen.dart';

/// Horizontal carousel / grid of saved favorites for the Home Dashboard
class FavoritesSection extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const FavoritesSection({
    super.key,
    this.onExplorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return ValueListenableBuilder<List<FavoriteItem>>(
      valueListenable: storage.favoritesNotifier,
      builder: (context, favorites, _) {
        if (favorites.isEmpty) {
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
                      Icons.star_rounded,
                      color: AppTheme.accentAmber,
                      size: 20,
                    ),
                    SizedBox(width: AppTheme.space8),
                    Text(
                      'Favorites',
                      style: AppTheme.titleLarge,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space10,
                    vertical: AppTheme.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLayer2,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Text(
                    '${favorites.length} Saved',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentAmber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space12),

            // Horizontal Scrollable Cards
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppTheme.space12),
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return _FavoriteCard(
                    item: item,
                    onTap: () {
                      storage.addRecentActivity(
                        RecentActivityItem(
                          type: item.type,
                          id: item.id,
                          title: item.title,
                          subtitle: item.subtitle,
                          viewedAt: DateTime.now().millisecondsSinceEpoch,
                        ),
                      );

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
                    onRemove: () {
                      storage.removeFavorite(item.type, item.id);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.space24),
          ],
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: AppTheme.cardDecoration(
        background: AppTheme.surfaceLayer1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 12, color: item.accentColor),
                          const SizedBox(width: 4),
                          Text(
                            item.typeLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: item.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.star_rounded,
                        color: AppTheme.accentAmber,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: AppTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
