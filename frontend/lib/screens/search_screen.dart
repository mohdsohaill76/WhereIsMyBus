import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../models/search_result.dart';
import '../models/favorite_item.dart';
import '../models/recent_activity_item.dart';
import '../services/transit_api_service.dart';
import '../services/search_service.dart';
import '../services/storage_service.dart';
import '../utils/responsive.dart';
import 'bus_tracking_screen.dart';
import 'route_details_screen.dart';

/// Full-featured, real-time Global Search Screen for WhereIsMyBus V2
class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TransitApiService _apiService = TransitApiService();
  final SearchService _searchService = SearchService.instance;
  final StorageService _storageService = StorageService.instance;

  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  String _searchQuery = '';
  String _activeFilter = 'all'; // 'all' | 'buses' | 'routes' | 'stops'

  List<BusModel> _buses = [];
  List<RouteModel> _routes = [];
  List<StopModel> _stops = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _loadTransitData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTransitData() async {
    setState(() => _isLoadingData = true);
    try {
      final results = await Future.wait([
        _apiService.fetchBuses(),
        _apiService.fetchRoutes(),
        _apiService.fetchStops(),
      ]);

      if (mounted) {
        setState(() {
          _buses = results[0] as List<BusModel>;
          _routes = results[1] as List<RouteModel>;
          _stops = results[2] as List<StopModel>;
          _isLoadingData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _onResultSelected(SearchResult result) {
    // Record into recent activity
    _storageService.addRecentActivity(
      RecentActivityItem(
        type: result.type,
        id: result.id,
        title: result.title,
        subtitle: result.subtitle,
        viewedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    if (result.isBus) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BusTrackingScreen(
            busNumber: result.id,
            routeName: result.metadata?['routeName'] as String? ?? result.subtitle,
          ),
        ),
      );
    } else if (result.isRoute) {
      final route = result.metadata?['route'] as RouteModel? ??
          _routes.firstWhere(
            (r) => r.id == result.id,
            orElse: () => RouteModel(
              id: result.id,
              name: result.title,
              description: '',
              stops: [],
              assignedBusIds: [],
            ),
          );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RouteDetailsScreen(route: route),
        ),
      );
    } else if (result.isStop) {
      _showStopDetailSheet(result);
    }
  }

  void _showStopDetailSheet(SearchResult result) {
    final stop = result.metadata?['stop'] as StopModel?;
    final lat = stop?.latitude ?? 0.0;
    final lng = stop?.longitude ?? 0.0;

    // Find routes that stop here
    final passingRoutes = _routes
        .where((r) => r.stops.any((s) => s.id == result.id || s.name == result.title))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: AppTheme.sheetDecoration(),
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle pill
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderMedium,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space20),

              // Stop Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppTheme.accentCyan,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.title,
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          result.subtitle,
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  // Favorite Stop Action
                  ValueListenableBuilder<List<FavoriteItem>>(
                    valueListenable: _storageService.favoritesNotifier,
                    builder: (context, favorites, child) {
                      final isFav = _storageService.isFavorite('stop', result.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFav ? AppTheme.accentAmber : AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          _storageService.toggleFavorite(
                            FavoriteItem(
                              type: 'stop',
                              id: result.id,
                              title: result.title,
                              subtitle: result.subtitle,
                              savedAt: DateTime.now().millisecondsSinceEpoch,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space20),
              const Divider(color: AppTheme.borderSubtle, height: 1),
              const SizedBox(height: AppTheme.space16),

              // Stop Details & Passing Routes
              const Text(
                'Routes Serving This Stop',
                style: AppTheme.titleSmall,
              ),
              const SizedBox(height: AppTheme.space10),

              if (passingRoutes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No active transit lines assigned to this stop currently.',
                    style: AppTheme.bodySmall,
                  ),
                )
              else
                ...passingRoutes.map(
                  (r) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: AppTheme.cardDecoration(
                      background: AppTheme.surfaceLayer2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '${r.stops.length} stops along corridor',
                                style: AppTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RouteDetailsScreen(route: r),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(60, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          child: const Text('View Route', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: AppTheme.space16),
              // Coordinates Info
              Container(
                padding: const EdgeInsets.all(AppTheme.space12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLayer2,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.explore_outlined, size: 16, color: AppTheme.textTertiary),
                    const SizedBox(width: AppTheme.space8),
                    Text(
                      'GPS: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.space20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _searchService.search(
      query: _searchQuery,
      typeFilter: _activeFilter,
      buses: _buses,
      routes: _routes,
      stops: _stops,
    );

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: ContentConstraint(
          child: Column(
            children: [
              // ── Search App Bar & Input ─────────────────────────────────────
              Container(
                padding: context.screenPadding.copyWith(bottom: AppTheme.space12),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceLayer1,
                  border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: AppTheme.space6),
                        Expanded(
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLayer2,
                              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                              border: Border.all(
                                color: _searchQuery.isNotEmpty
                                    ? AppTheme.primaryBlue
                                    : AppTheme.borderMedium,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: AppTheme.primaryBlueLight,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.space10),
                                Expanded(
                                  child: TextField(
                                    key: const Key('global_search_input'),
                                    controller: _searchController,
                                    focusNode: _focusNode,
                                    autofocus: true,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                    ),
                                    cursorColor: AppTheme.primaryBlueLight,
                                    onChanged: (val) {
                                      setState(() => _searchQuery = val);
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search by bus #, route name or stop...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: AppTheme.textTertiary,
                                        fontSize: 13,
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    child: const Icon(
                                      Icons.cancel_rounded,
                                      color: AppTheme.textSecondary,
                                      size: 18,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.space12),

                    // Category Filter Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'All Results', searchResults.length),
                          const SizedBox(width: AppTheme.space8),
                          _buildFilterChip('buses', 'Buses', _countFor('bus')),
                          const SizedBox(width: AppTheme.space8),
                          _buildFilterChip('routes', 'Routes', _countFor('route')),
                          const SizedBox(width: AppTheme.space8),
                          _buildFilterChip('stops', 'Stops', _countFor('stop')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search Content / Results Body ──────────────────────────────
              Expanded(
                child: _isLoadingData
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryBlue,
                          strokeWidth: 2.5,
                        ),
                      )
                    : _searchQuery.isEmpty
                        ? _buildRecentSearchesState()
                        : searchResults.isEmpty
                            ? _buildEmptyResultsState()
                            : _buildResultsList(searchResults),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _countFor(String type) {
    return _searchService
        .search(
          query: _searchQuery,
          typeFilter: type,
          buses: _buses,
          routes: _routes,
          stops: _stops,
        )
        .length;
  }

  Widget _buildFilterChip(String filterKey, String label, int count) {
    final isSelected = _activeFilter == filterKey;
    return InkWell(
      onTap: () => setState(() => _activeFilter = filterKey),
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.15)
              : AppTheme.surfaceLayer2,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
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
                color: isSelected ? AppTheme.primaryBlueLight : AppTheme.textSecondary,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceLayer3,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchesState() {
    return ValueListenableBuilder<List<RecentActivityItem>>(
      valueListenable: _storageService.recentActivitiesNotifier,
      builder: (context, recents, _) {
        if (recents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceLayer1,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 36,
                    color: AppTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: AppTheme.space16),
                const Text(
                  'Search WhereIsMyBus',
                  style: AppTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.space4),
                const Text(
                  'Find buses, routes, and transit stops instantly.',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: context.screenPadding.copyWith(top: AppTheme.space16, bottom: AppTheme.space32),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: AppTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () => _storageService.clearRecentActivities(),
                  child: const Text(
                    'Clear All',
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
            ...recents.map(
              (item) => Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
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
                  trailing: Text(item.formattedTime, style: AppTheme.caption),
                  onTap: () {
                    _onResultSelected(
                      SearchResult(
                        type: item.type,
                        id: item.id,
                        title: item.title,
                        subtitle: item.subtitle,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceLayer1,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'No matches for "$_searchQuery"',
              style: AppTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space6),
            const Text(
              'Check for typos or try searching by station name, bus number or route corridor.',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<SearchResult> results) {
    return ListView.builder(
      padding: context.screenPadding.copyWith(top: AppTheme.space16, bottom: AppTheme.space32),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.space10),
          decoration: AppTheme.cardDecoration(
            background: AppTheme.surfaceLayer1,
          ),
          child: InkWell(
            onTap: () => _onResultSelected(result),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space14),
              child: Row(
                children: [
                  // Type Badge Icon
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space10),
                    decoration: BoxDecoration(
                      color: result.badgeBg,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: result.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      result.icon,
                      color: result.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space12),

                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: result.badgeBg,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Text(
                                result.typeLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: result.accentColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                result.title,
                                style: AppTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          result.subtitle,
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Star / Bookmark Button
                  ValueListenableBuilder<List<FavoriteItem>>(
                    valueListenable: _storageService.favoritesNotifier,
                    builder: (context, favorites, child) {
                      final isFav = _storageService.isFavorite(result.type, result.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isFav ? AppTheme.accentAmber : AppTheme.textTertiary,
                          size: 22,
                        ),
                        tooltip: isFav ? 'Unfavorite' : 'Add to Favorites',
                        onPressed: () {
                          _storageService.toggleFavorite(
                            FavoriteItem(
                              type: result.type,
                              id: result.id,
                              title: result.title,
                              subtitle: result.subtitle,
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
        );
      },
    );
  }
}
