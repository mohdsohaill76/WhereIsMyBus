import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/favorite_item.dart';
import '../services/storage_service.dart';
import '../utils/responsive.dart';
import 'bus_tracking_screen.dart';
import 'routes_screen.dart';

/// Full-featured Favorites Screen organizing saved buses, routes, and stops
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final StorageService _storage = StorageService.instance;
  String _activeFilter = 'all'; // 'all' | 'bus' | 'route' | 'stop'

  @override
  Widget build(BuildContext context) {
    return ContentConstraint(
      child: ValueListenableBuilder<List<FavoriteItem>>(
        valueListenable: _storage.favoritesNotifier,
        builder: (context, allFavorites, _) {
          final filtered = _activeFilter == 'all'
              ? allFavorites
              : allFavorites.where((f) => f.type == _activeFilter).toList();

          final busCount = allFavorites.where((f) => f.isBus).length;
          final routeCount = allFavorites.where((f) => f.isRoute).length;
          final stopCount = allFavorites.where((f) => f.isStop).length;

          return CustomScrollView(
            slivers: [
              // ── Header Area ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.screenPadding.copyWith(bottom: AppTheme.space12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.space8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentAmber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(
                                    color: AppTheme.accentAmber.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.accentAmber,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppTheme.space12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Saved Favorites',
                                    style: AppTheme.titleLarge,
                                  ),
                                  SizedBox(height: AppTheme.space2),
                                  Text(
                                    'Fast access to your frequent buses, routes & stops',
                                    style: AppTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (allFavorites.isNotEmpty)
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
                                '${allFavorites.length} Total',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentAmber,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space20),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', 'All', allFavorites.length),
                            const SizedBox(width: AppTheme.space8),
                            _buildFilterChip('bus', 'Buses', busCount),
                            const SizedBox(width: AppTheme.space8),
                            _buildFilterChip('route', 'Routes', routeCount),
                            const SizedBox(width: AppTheme.space8),
                            _buildFilterChip('stop', 'Stops', stopCount),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Favorites Content Area ─────────────────────────────────────
              SliverPadding(
                padding: context.screenPadding.copyWith(
                  top: AppTheme.space4,
                  bottom: context.isMobile ? 80.0 : AppTheme.space32,
                ),
                sliver: filtered.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = filtered[index];
                            return _buildFavoriteCard(item);
                          },
                          childCount: filtered.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, int count) {
    final isSelected = _activeFilter == key;
    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentAmber.withValues(alpha: 0.15)
              : AppTheme.surfaceLayer2,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: isSelected ? AppTheme.accentAmber : AppTheme.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.accentAmber : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.accentAmber : AppTheme.surfaceLayer3,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.bgDark : AppTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.space40,
        horizontal: AppTheme.space24,
      ),
      decoration: AppTheme.cardDecoration(
        background: AppTheme.surfaceLayer1,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceLayer2,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_border_rounded,
              size: 40,
              color: AppTheme.accentAmber,
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          const Text(
            'No saved favorites yet',
            style: AppTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space6),
          const Text(
            'Star your daily buses, routes or stops from the dashboard or search to track them quickly.',
            textAlign: TextAlign.center,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space12),
      decoration: AppTheme.cardDecoration(
        background: AppTheme.surfaceLayer1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Row(
          children: [
            // Leading Badge
            Container(
              padding: const EdgeInsets.all(AppTheme.space10),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: item.accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                item.icon,
                color: item.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.space14),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          item.typeLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: item.accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: AppTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.space10),

            // Quick Action Button (Track / View)
            if (item.isBus)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BusTrackingScreen(
                        busNumber: item.id,
                        routeName: item.subtitle,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.navigation_rounded, size: 14),
                label: const Text('Track', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(70, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              )
            else if (item.isRoute)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RoutesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.alt_route_rounded, size: 14),
                label: const Text('View', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(70, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),

            // Remove Bookmark Star
            IconButton(
              icon: const Icon(
                Icons.star_rounded,
                color: AppTheme.accentAmber,
                size: 24,
              ),
              tooltip: 'Remove from favorites',
              onPressed: () {
                _storage.removeFavorite(item.type, item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
