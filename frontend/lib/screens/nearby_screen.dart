import 'package:flutter/material.dart';
import '../models/stop_model.dart';
import '../models/route_model.dart';
import '../models/bus_model.dart';
import '../models/nearby_stop.dart';
import '../models/favorite_item.dart';
import '../models/recent_activity_item.dart';
import '../services/transit_api_service.dart';
import '../services/location_service.dart';
import '../services/geo_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/nearby_map.dart';
import '../widgets/nearby_stop_card.dart';
import '../widgets/skeleton_loader.dart';
import 'bus_tracking_screen.dart';
import 'route_details_screen.dart';

/// Full-featured Nearby Transit Radar screen for WhereIsMyBus V2
class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final TransitApiService _apiService = TransitApiService.instance;
  final LocationService _locationService = LocationService.instance;
  final GeoService _geoService = GeoService.instance;
  final StorageService _storageService = StorageService.instance;

  bool _isLoadingData = true;
  String? _errorMessage;

  List<StopModel> _allStops = [];
  List<RouteModel> _allRoutes = [];
  List<BusModel> _allBuses = [];

  List<NearbyStop> _nearbyStops = [];
  NearbyStop? _selectedStop;

  double? _userLat;
  double? _userLng;
  LocationStatus _locationStatus = LocationStatus.initial;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    _fetchTransitDataAndLocate();
  }

  Future<void> _fetchTransitDataAndLocate() async {
    setState(() {
      _isLoadingData = true;
      _errorMessage = null;
    });

    try {
      final stops = await _apiService.getAllStops();
      final routes = await _apiService.getAllRoutes();
      final buses = await _apiService.getAllBuses();

      if (!mounted) return;

      setState(() {
        _allStops = stops;
        _allRoutes = routes;
        _allBuses = buses;
        _isLoadingData = false;
      });

      // Try acquiring current GPS position
      await _requestUserLocation(requestIfDenied: false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
        _errorMessage = 'Could not load transit network: $e';
      });
    }
  }

  Future<void> _requestUserLocation({bool requestIfDenied = true}) async {
    final result = await _locationService.getCurrentPosition(
      requestIfDenied: requestIfDenied,
    );

    if (!mounted) return;

    setState(() {
      _locationStatus = result.status;
      _locationMessage = result.message;
      if (result.isReady) {
        _userLat = result.latitude;
        _userLng = result.longitude;
      } else {
        // Fallback reference coordinates (Warangal Transit Central Hub)
        _userLat ??= LocationService.fallbackLat;
        _userLng ??= LocationService.fallbackLng;
      }
      _recalculateNearbyStops();
    });
  }

  void _recalculateNearbyStops() {
    if (_userLat == null || _userLng == null || _allStops.isEmpty) {
      _nearbyStops = [];
      return;
    }

    _nearbyStops = _geoService.calculateNearbyStops(
      userLat: _userLat!,
      userLng: _userLng!,
      stops: _allStops,
      routes: _allRoutes,
      buses: _allBuses,
    );

    if (_nearbyStops.isNotEmpty && _selectedStop == null) {
      _selectedStop = _nearbyStops.first;
    }
  }

  void _onStopSelected(NearbyStop stop) {
    setState(() {
      _selectedStop = stop;
    });

    _storageService.addRecentActivity(
      RecentActivityItem(
        type: 'stop',
        id: stop.id,
        title: stop.name,
        subtitle: '${stop.routeCountLabel} • ${stop.distanceLabel}',
        viewedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    // Open detail bottom sheet on mobile and tablet
    if (!context.isDesktop) {
      _showStopIntelligenceSheet(stop);
    }
  }

  void _showManualStopPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceLayer1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _allStops.where((s) {
              final q = searchQuery.toLowerCase();
              return s.name.toLowerCase().contains(q) ||
                  s.shortName.toLowerCase().contains(q) ||
                  s.id.toLowerCase().contains(q);
            }).toList();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Select a Transit Station',
                    style: AppTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Explore transit departures and routes from any station',
                    style: AppTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Search Field
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search station by name or short code...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
                      filled: true,
                      fillColor: AppTheme.bgSurfaceCard,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.accentCyan),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // List of filtered stops
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'No matching transit stops found.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const Divider(color: AppTheme.borderSubtle, height: 1),
                            itemBuilder: (context, index) {
                              final stop = filtered[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                                  'Code: ${stop.shortName.isNotEmpty ? stop.shortName : stop.id}',
                                  style: AppTheme.caption,
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary, size: 20),
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  // Update user center to this selected stop
                                  setState(() {
                                    _userLat = stop.latitude;
                                    _userLng = stop.longitude;
                                    _recalculateNearbyStops();
                                    final found = _nearbyStops.firstWhere(
                                      (n) => n.id == stop.id,
                                      orElse: () => NearbyStop(stop: stop, distanceMeters: 0),
                                    );
                                    _onStopSelected(found);
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStopIntelligenceSheet(NearbyStop nearby) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceLayer1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stop Title & Star Toggle Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.space10),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.location_on_rounded, color: AppTheme.accentCyan, size: 24),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nearby.name, style: AppTheme.titleLarge),
                            const SizedBox(height: 2),
                            Text(
                              '${nearby.distanceLabel} away • ${nearby.walkingLabel}',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      ValueListenableBuilder<List<FavoriteItem>>(
                        valueListenable: _storageService.favoritesNotifier,
                        builder: (context, favorites, child) {
                          final isFav = _storageService.isFavorite('stop', nearby.id);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.star_rounded : Icons.star_border_rounded,
                              color: isFav ? AppTheme.accentAmber : AppTheme.textSecondary,
                              size: 24,
                            ),
                            tooltip: isFav ? 'Remove Favorite' : 'Save Favorite',
                            onPressed: () {
                              _storageService.toggleFavorite(
                                FavoriteItem(
                                  type: 'stop',
                                  id: nearby.id,
                                  title: nearby.name,
                                  subtitle: '${nearby.routeCountLabel} • ${nearby.distanceLabel}',
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

                  // Serving Routes Section
                  const Text('Serving Routes', style: AppTheme.titleMedium),
                  const SizedBox(height: AppTheme.space8),

                  if (nearby.servingRoutes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.space16),
                      decoration: AppTheme.cardDecoration(background: AppTheme.bgSurfaceCard),
                      child: const Text(
                        'No direct route lines mapped for this station.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    )
                  else
                    ...nearby.servingRoutes.map(
                      (route) => Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.space8),
                        decoration: AppTheme.cardDecoration(background: AppTheme.bgSurfaceCard),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentIndigo.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: const Icon(Icons.alt_route_rounded, color: AppTheme.accentIndigo, size: 18),
                          ),
                          title: Text(route.name, style: AppTheme.titleSmall),
                          subtitle: Text(
                            '${route.stops.length} stops • ${route.assignedBusIds.length} assigned buses',
                            style: AppTheme.caption,
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.surfaceLayer2,
                              foregroundColor: AppTheme.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                side: const BorderSide(color: AppTheme.borderMedium),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RouteDetailsScreen(route: route),
                                ),
                              );
                            },
                            child: const Text('View Route', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppTheme.space20),

                  // Active Buses Section
                  const Text('Active Buses Nearby', style: AppTheme.titleMedium),
                  const SizedBox(height: AppTheme.space8),

                  _buildActiveBusesListForStop(nearby),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActiveBusesListForStop(NearbyStop nearby) {
    final servingRouteIds = nearby.servingRoutes.map((r) => r.id.toUpperCase()).toSet();
    final servingRouteNames = nearby.servingRoutes.map((r) => r.name.toLowerCase()).toSet();

    final busesOnCorridor = _allBuses.where((b) {
      return servingRouteIds.contains(b.routeId.toUpperCase()) ||
          servingRouteNames.contains(b.routeName.toLowerCase());
    }).toList();

    if (busesOnCorridor.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.space16),
        decoration: AppTheme.cardDecoration(background: AppTheme.bgSurfaceCard),
        child: const Text(
          'No buses currently transmitting telemetry along this corridor.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    }

    return Column(
      children: busesOnCorridor.map((bus) {
        final isMoving = bus.status.toLowerCase() == 'moving';
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.space8),
          decoration: AppTheme.cardDecoration(background: AppTheme.bgSurfaceCard),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isMoving ? AppTheme.statusLive : AppTheme.statusStopped).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                color: isMoving ? AppTheme.statusLive : AppTheme.statusStopped,
                size: 18,
              ),
            ),
            title: Row(
              children: [
                Text(bus.busNumber, style: AppTheme.titleSmall),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMoving ? AppTheme.statusLiveBg : AppTheme.statusStoppedBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: isMoving ? AppTheme.statusLiveBorder : AppTheme.statusStoppedBorder,
                    ),
                  ),
                  child: Text(
                    bus.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isMoving ? AppTheme.statusLive : AppTheme.statusStopped,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(bus.routeName, style: AppTheme.caption, maxLines: 1),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BusTrackingScreen(
                      busNumber: bus.busNumber,
                      routeName: bus.routeName,
                    ),
                  ),
                );
              },
              child: const Text('Track Bus', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContentConstraint(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoadingData
            ? Padding(
                padding: context.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppTheme.space16),
                    const SkeletonLoader(width: double.infinity, height: 180),
                    const SizedBox(height: AppTheme.space16),
                    const SkeletonLoader(width: double.infinity, height: 80),
                    const SizedBox(height: AppTheme.space10),
                    const SkeletonLoader(width: double.infinity, height: 80),
                  ],
                ),
              )
            : _errorMessage != null
                ? Padding(
                    padding: context.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppTheme.space32),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.statusStale),
                              const SizedBox(height: AppTheme.space16),
                              Text(_errorMessage!, style: AppTheme.titleMedium, textAlign: TextAlign.center),
                              const SizedBox(height: AppTheme.space16),
                              ElevatedButton.icon(
                                style: AppTheme.primaryButtonStyle,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Retry'),
                                onPressed: _fetchTransitDataAndLocate,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : context.isDesktop
                    ? _buildDesktopLayout()
                    : _buildMobileTabletLayout(),
      ),
    );
  }

  Widget _buildLocationStatusBanner() {
    final isGpsReady = _locationStatus == LocationStatus.ready;
    final isDenied = _locationStatus == LocationStatus.denied ||
        _locationStatus == LocationStatus.permanentlyDenied;

    return Container(
      padding: const EdgeInsets.all(AppTheme.space12),
      decoration: BoxDecoration(
        color: isGpsReady ? AppTheme.statusLiveBg : AppTheme.surfaceLayer1,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isGpsReady ? AppTheme.statusLiveBorder : AppTheme.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGpsReady ? Icons.my_location_rounded : Icons.location_searching_rounded,
            color: isGpsReady ? AppTheme.statusLive : AppTheme.accentCyan,
            size: 20,
          ),
          const SizedBox(width: AppTheme.space10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGpsReady
                      ? 'Location Active • Showing closest stations'
                      : isDenied
                          ? 'GPS Permission Denied'
                          : 'Reference Hub Active (Warangal Central)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isGpsReady ? AppTheme.statusLive : AppTheme.textPrimary,
                  ),
                ),
                if (_locationMessage != null && !isGpsReady) ...[
                  const SizedBox(height: 2),
                  Text(
                    _locationMessage!,
                    style: AppTheme.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppTheme.space8),
          if (!isGpsReady)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentCyan,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.gps_fixed_rounded, size: 16),
              label: const Text('Use GPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              onPressed: () => _requestUserLocation(requestIfDenied: true),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
                    color: AppTheme.accentCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.radar_rounded, color: AppTheme.accentCyan, size: 20),
                ),
                const SizedBox(width: AppTheme.space12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nearby Transit', style: AppTheme.titleLarge),
                    SizedBox(height: AppTheme.space2),
                    Text('Find stops and buses around you', style: AppTheme.bodySmall),
                  ],
                ),
              ],
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentCyan,
                side: const BorderSide(color: AppTheme.accentCyan),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
              ),
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('Select Stop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              onPressed: _showManualStopPicker,
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space12),
        _buildLocationStatusBanner(),
      ],
    );
  }

  Widget _buildMobileTabletLayout() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: context.screenPadding.copyWith(bottom: AppTheme.space12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppTheme.space16),

                // Interactive Radar Map
                SizedBox(
                  height: context.isTablet ? 280 : 220,
                  child: NearbyMapWidget(
                    userLat: _userLat,
                    userLng: _userLng,
                    nearbyStops: _nearbyStops,
                    activeBuses: _allBuses,
                    selectedStop: _selectedStop,
                    onStopTapped: _onStopSelected,
                    onRecenter: () => _requestUserLocation(requestIfDenied: true),
                  ),
                ),
                const SizedBox(height: AppTheme.space16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Stops by Proximity (${_nearbyStops.length})', style: AppTheme.titleMedium),
                    const Text('Sorted by distance', style: AppTheme.caption),
                  ],
                ),
                const SizedBox(height: AppTheme.space8),
              ],
            ),
          ),
        ),

        // List of Nearby Stops
        SliverPadding(
          padding: context.screenPadding.copyWith(top: 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final nearby = _nearbyStops[index];
                return NearbyStopCard(
                  nearbyStop: nearby,
                  isSelected: _selectedStop?.id == nearby.id,
                  onTap: () => _onStopSelected(nearby),
                );
              },
              childCount: _nearbyStops.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: context.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.space16),

          // 2-Column Split View
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Scrollable List of Nearby Stops
                SizedBox(
                  width: 440,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nearby Stops (${_nearbyStops.length})', style: AppTheme.titleMedium),
                          const Text('Sorted by distance', style: AppTheme.caption),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _nearbyStops.length,
                          itemBuilder: (context, index) {
                            final nearby = _nearbyStops[index];
                            return NearbyStopCard(
                              nearbyStop: nearby,
                              isSelected: _selectedStop?.id == nearby.id,
                              onTap: () => _onStopSelected(nearby),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.space20),

                // Right Column: Interactive Map + Active Selected Stop Intelligence Panel
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: NearbyMapWidget(
                          userLat: _userLat,
                          userLng: _userLng,
                          nearbyStops: _nearbyStops,
                          activeBuses: _allBuses,
                          selectedStop: _selectedStop,
                          onStopTapped: _onStopSelected,
                          onRecenter: () => _requestUserLocation(requestIfDenied: true),
                        ),
                      ),
                      if (_selectedStop != null) ...[
                        const SizedBox(height: AppTheme.space12),
                        _buildDesktopStopPanel(_selectedStop!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStopPanel(NearbyStop stop) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space14),
      decoration: AppTheme.cardDecoration(background: AppTheme.surfaceLayer1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space8),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppTheme.accentCyan, size: 20),
          ),
          const SizedBox(width: AppTheme.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name, style: AppTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${stop.distanceLabel} away • ${stop.walkingLabel} • ${stop.routeCountLabel}',
                  style: AppTheme.caption,
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: AppTheme.primaryButtonStyle,
            icon: const Icon(Icons.info_outline_rounded, size: 16),
            label: const Text('View Departures & Buses', style: TextStyle(fontSize: 12)),
            onPressed: () => _showStopIntelligenceSheet(stop),
          ),
        ],
      ),
    );
  }
}
