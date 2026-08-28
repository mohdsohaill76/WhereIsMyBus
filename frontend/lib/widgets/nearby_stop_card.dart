import 'package:flutter/material.dart';
import '../models/nearby_stop.dart';
import '../models/favorite_item.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'live_status_dot.dart';

/// Card representing a nearby transit stop with distance, walking estimate, routes, and live bus intelligence
class NearbyStopCard extends StatelessWidget {
  final NearbyStop nearbyStop;
  final VoidCallback? onTap;
  final bool isSelected;

  const NearbyStopCard({
    super.key,
    required this.nearbyStop,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.surfaceLayer2 : AppTheme.surfaceLayer1,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: isSelected ? AppTheme.accentCyan : AppTheme.borderSubtle,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: isSelected ? AppTheme.shadowFloating : AppTheme.shadowSubtle,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space14),
            child: Row(
              children: [
                // Stop Station Icon Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: AppTheme.accentCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.accentCyan,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),

                // Stop Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Stop Name + Short Code Pill
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nearbyStop.name,
                              style: AppTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (nearbyStop.shortName.isNotEmpty) ...[
                            const SizedBox(width: AppTheme.space6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.bgSurfaceCard,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                border: Border.all(color: AppTheme.borderSubtle),
                              ),
                              child: Text(
                                nearbyStop.shortName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppTheme.space4),

                      // Distance & Walking Estimation Subtitle
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk_rounded,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${nearbyStop.distanceLabel} • ${nearbyStop.walkingLabel}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space8),

                      // Route & Bus Badges Pill Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Serving Routes Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.accentIndigo.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              border: Border.all(
                                color: AppTheme.accentIndigo.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.alt_route_rounded,
                                  size: 12,
                                  color: AppTheme.accentIndigo,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  nearbyStop.routeCountLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentIndigo,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Active Bus Count Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: nearbyStop.activeBusCount > 0
                                  ? AppTheme.statusLiveBg
                                  : AppTheme.bgSurfaceCard,
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              border: Border.all(
                                color: nearbyStop.activeBusCount > 0
                                    ? AppTheme.statusLiveBorder
                                    : AppTheme.borderSubtle,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LiveStatusDot(
                                  size: 5,
                                  color: nearbyStop.activeBusCount > 0
                                      ? AppTheme.statusLive
                                      : AppTheme.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  nearbyStop.activeBusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: nearbyStop.activeBusCount > 0
                                        ? AppTheme.statusLive
                                        : AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppTheme.space8),

                // Star Favorite Button
                ValueListenableBuilder<List<FavoriteItem>>(
                  valueListenable: storage.favoritesNotifier,
                  builder: (context, favorites, child) {
                    final isFav = storage.isFavorite('stop', nearbyStop.id);
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isFav ? AppTheme.accentAmber : AppTheme.textTertiary,
                        size: 22,
                      ),
                      tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                      onPressed: () {
                        storage.toggleFavorite(
                          FavoriteItem(
                            type: 'stop',
                            id: nearbyStop.id,
                            title: nearbyStop.name,
                            subtitle: '${nearbyStop.routeCountLabel} • ${nearbyStop.distanceLabel}',
                            savedAt: DateTime.now().millisecondsSinceEpoch,
                          ),
                        );
                      },
                    );
                  },
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
