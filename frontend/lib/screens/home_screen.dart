import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/bus_model.dart';
import '../services/transit_api_service.dart';
import '../utils/responsive.dart';
import '../widgets/bus_card.dart';
import '../widgets/quick_stats_bar.dart';
import '../widgets/live_status_dot.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/favorites_section.dart';
import '../widgets/recent_activity_list.dart';
import 'bus_tracking_screen.dart';
import 'routes_screen.dart';
import 'search_screen.dart';
import 'nearby_screen.dart';
import '../models/stop_model.dart';
import '../models/route_model.dart';
import '../models/nearby_stop.dart';
import '../services/location_service.dart';
import '../services/geo_service.dart';

/// Redesigned Passenger Dashboard for WhereIsMyBus V2
/// Integrates Global Search, Favorites, Metrics, Live Fleet, and Recent History.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TransitApiService _apiService = TransitApiService();
  final LocationService _locationService = LocationService.instance;
  final GeoService _geoService = GeoService.instance;

  List<BusModel> _buses = [];
  List<StopModel> _stops = [];
  List<RouteModel> _routes = [];
  List<NearbyStop> _nearbyStops = [];
  bool _isLocationActive = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBuses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loadedBuses = await _apiService.fetchBuses();
      final loadedStops = await _apiService.getAllStops();
      final loadedRoutes = await _apiService.getAllRoutes();

      if (mounted) {
        setState(() {
          _buses = loadedBuses;
          _stops = loadedStops;
          _routes = loadedRoutes;
          _isLoading = false;
        });

        _checkExistingLocationAndCompute();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _checkExistingLocationAndCompute() {
    final loc = _locationService.lastKnownResult;
    if (loc != null && loc.isReady && _stops.isNotEmpty) {
      setState(() {
        _isLocationActive = true;
        _nearbyStops = _geoService.calculateNearbyStops(
          userLat: loc.latitude!,
          userLng: loc.longitude!,
          stops: _stops,
          routes: _routes,
          buses: _buses,
        );
      });
    }
  }

  Future<void> _enableLocation() async {
    final result = await _locationService.getCurrentPosition(requestIfDenied: true);
    if (!mounted) return;

    if (result.isReady && _stops.isNotEmpty) {
      setState(() {
        _isLocationActive = true;
        _nearbyStops = _geoService.calculateNearbyStops(
          userLat: result.latitude!,
          userLng: result.longitude!,
          stops: _stops,
          routes: _routes,
          buses: _buses,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBuses = _buses.where((bus) {
      final query = _searchQuery.toLowerCase();
      final numberMatch = bus.busNumber.toLowerCase().contains(query);
      final routeMatch = bus.routeName.toLowerCase().contains(query);
      final idMatch = bus.id.toLowerCase().contains(query);
      return numberMatch || routeMatch || idMatch;
    }).toList();

    final liveCount = _buses.where((b) {
      final s = b.status.toLowerCase();
      return s == 'moving' || s == 'active' || s == 'in_transit' || s == 'live';
    }).length;

    final uniqueRoutesCount = _buses.map((b) => b.routeId).toSet().length;

    return ContentConstraint(
      child: CustomScrollView(
        slivers: [
          // ── Top Header & Hero Area ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: context.screenPadding.copyWith(bottom: AppTheme.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Header & Live Counter Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.space8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentButtonGradient,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x333B82F6),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppTheme.space12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'WhereIsMyBus',
                                    style: AppTheme.titleLarge,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: AppTheme.space2),
                                  Text(
                                    'Real-time public transport',
                                    style: AppTheme.bodySmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTheme.space8),

                      // Status Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space10,
                          vertical: AppTheme.space6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.statusLiveBg,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          border: Border.all(color: AppTheme.statusLiveBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LiveStatusDot(size: 5, color: AppTheme.statusLive),
                            const SizedBox(width: AppTheme.space6),
                            Text(
                              '$liveCount buses live',
                              style: const TextStyle(
                                color: AppTheme.statusLive,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space24),

                  // Hero Copy
                  const Text(
                    'Track your bus.\nKnow when it arrives.',
                    style: AppTheme.display,
                  ),
                  const SizedBox(height: AppTheme.space6),
                  const Text(
                    'Real-time bus locations, routes and arrival information.',
                    style: AppTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppTheme.space20),

                  // Global Search Bar
                  Semantics(
                    textField: true,
                    label: 'Search buses, routes or stops',
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLayer1,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(
                          color: _searchQuery.isNotEmpty
                              ? AppTheme.primaryBlue
                              : AppTheme.borderMedium,
                          width: 1,
                        ),
                        boxShadow: AppTheme.shadowSubtle,
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
                              controller: _searchController,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                              cursorColor: AppTheme.primaryBlueLight,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search buses, routes or stops...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(
                                Icons.cancel_rounded,
                                color: AppTheme.textSecondary,
                                size: 18,
                              ),
                            )
                          else
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const SearchScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.space8,
                                    vertical: AppTheme.space2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLayer2,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    border: Border.all(color: AppTheme.borderSubtle),
                                  ),
                                  child: const Text(
                                    'Ctrl K',
                                    style: TextStyle(
                                      color: AppTheme.textTertiary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Dashboard Metrics & Sections ──────────────────────────────
          SliverPadding(
            padding: context.screenPadding.copyWith(
              top: AppTheme.space4,
              bottom: context.isMobile ? 80.0 : AppTheme.space32,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Quick Metrics Overview
                QuickStatsBar(
                  totalBuses: _buses.length,
                  liveBuses: liveCount,
                  activeRoutes: uniqueRoutesCount,
                ),
                const SizedBox(height: AppTheme.space24),

                // 2. Saved Favorites Carousel
                FavoritesSection(
                  onExplorePressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RoutesScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.space20),

                // 3. Transit Near You Section
                _buildTransitNearYouSection(),
                const SizedBox(height: AppTheme.space24),

                // 4. Section Header: Live Buses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live buses',
                          style: AppTheme.titleLarge,
                        ),
                        SizedBox(height: AppTheme.space2),
                        Text(
                          'Currently operating',
                          style: AppTheme.caption,
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
                        '${filteredBuses.length} Buses',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space16),

                // Loading Shimmer Skeletons
                if (_isLoading) ...[
                  const BusCardSkeleton(),
                  const BusCardSkeleton(),
                  const BusCardSkeleton(),
                ]
                // Error State with Retry
                else if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space24),
                    decoration: AppTheme.cardDecoration(
                      background: AppTheme.surfaceLayer1,
                      border: AppTheme.statusOfflineBorder,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 40,
                          color: AppTheme.statusOffline,
                        ),
                        const SizedBox(height: AppTheme.space12),
                        const Text(
                          'Unable to load buses',
                          style: AppTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.space4),
                        const Text(
                          'Check your connection and try again.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(height: AppTheme.space16),
                        ElevatedButton.icon(
                          onPressed: _loadBuses,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                // Empty Search State
                else if (filteredBuses.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.space36,
                      horizontal: AppTheme.space20,
                    ),
                    decoration: AppTheme.cardDecoration(
                      background: AppTheme.surfaceLayer1,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.space12),
                          decoration: const BoxDecoration(
                            color: AppTheme.surfaceLayer2,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 32,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.space12),
                        const Text(
                          'No buses found',
                          style: AppTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.space4),
                        const Text(
                          'Try searching for another bus, route or stop.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(height: AppTheme.space16),
                        OutlinedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 15),
                          label: const Text('Clear Search'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlueLight,
                            side: const BorderSide(color: AppTheme.borderMedium),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                // Live Bus Cards
                else
                  ...filteredBuses.map(
                    (bus) => BusCard(
                      busNumber: bus.busNumber,
                      route: bus.routeName,
                      status: bus.status,
                      onTrackPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BusTrackingScreen(
                              busNumber: bus.id,
                              routeName: bus.routeName,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                 const SizedBox(height: AppTheme.space24),

                // 4. Passenger Recent History
                const RecentActivityList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitNearYouSection() {
    if (_isLocationActive && _nearbyStops.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transit near you',
                    style: AppTheme.titleLarge,
                  ),
                  SizedBox(height: AppTheme.space2),
                  Text(
                    'Closest stops and stations',
                    style: AppTheme.caption,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NearbyScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View all nearby',
                  style: TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),

          // Render top 2 closest stops
          ..._nearbyStops.take(2).map((stop) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.space8),
              decoration: AppTheme.cardDecoration(
                background: AppTheme.surfaceLayer1,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(Icons.location_on_rounded, color: AppTheme.accentCyan, size: 18),
                  ),
                  title: Text(stop.name, style: AppTheme.titleSmall),
                  subtitle: Text(
                    '${stop.distanceLabel} • ${stop.walkingLabel}',
                    style: AppTheme.caption,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textTertiary,
                    size: 20,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NearbyScreen(),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      );
    }

    // Location disabled / initial prompt banner
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLayer1,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space10),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(Icons.near_me_rounded, color: AppTheme.accentCyan, size: 22),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find transit near you',
                  style: AppTheme.titleSmall,
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  'Use your location to discover nearby stops and buses.',
                  style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surfaceLayer2,
              foregroundColor: AppTheme.accentCyan,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                side: const BorderSide(color: AppTheme.accentCyan),
              ),
            ),
            onPressed: _enableLocation,
            child: const Text(
              'Enable location',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
