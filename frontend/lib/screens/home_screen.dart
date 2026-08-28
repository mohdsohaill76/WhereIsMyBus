import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/bus_model.dart';
import '../services/transit_api_service.dart';
import '../widgets/bus_card.dart';
import '../widgets/quick_stats_bar.dart';
import '../widgets/live_status_dot.dart';
import '../widgets/skeleton_loader.dart';
import 'bus_tracking_screen.dart';
import 'routes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TransitApiService _apiService = TransitApiService();

  List<BusModel> _buses = [];
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
      if (mounted) {
        setState(() {
          _buses = loadedBuses;
          _isLoading = false;
        });
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

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                // 1. Buses Dashboard Tab
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
                    child: CustomScrollView(
                      slivers: [
                        // Minimalist Dark Header & Hero Section
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Brand Header & Live Counter
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
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
                                        const SizedBox(width: 12),
                                        const Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'WhereIsMyBus',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: AppTheme.textPrimary,
                                                letterSpacing: -0.4,
                                              ),
                                            ),
                                            Text(
                                              'Real-time public transport',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Status Pill: ● 5 buses live
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.statusLiveBg,
                                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                        border: Border.all(color: AppTheme.statusLiveBorder),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const LiveStatusDot(size: 5, color: AppTheme.statusLive),
                                          const SizedBox(width: 6),
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
                                const SizedBox(height: 24),

                                // Hero Message Typography
                                const Text(
                                  'Track your bus.\nKnow when it arrives.',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.textPrimary,
                                    height: 1.15,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Real-time bus locations, routes and arrival information.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Primary Search Component
                                Container(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLayer1,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                                    border: Border.all(
                                      color: _searchQuery.isNotEmpty
                                          ? AppTheme.primaryBlue
                                          : AppTheme.borderMedium,
                                      width: 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search_rounded,
                                        color: AppTheme.primaryBlueLight,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
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
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content List
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 95),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Stats Section
                              QuickStatsBar(
                                totalBuses: _buses.length,
                                liveBuses: liveCount,
                                activeRoutes: uniqueRoutesCount,
                              ),
                              const SizedBox(height: 24),

                              // Section Header: Live Buses / Currently Operating
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Live buses',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Currently operating',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                              const SizedBox(height: 14),

                              // Loading State with Shimmer Skeletons
                              if (_isLoading) ...[
                                const BusCardSkeleton(),
                                const BusCardSkeleton(),
                                const BusCardSkeleton(),
                              ]
                              // Error State
                              else if (_errorMessage != null)
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: AppTheme.cardDecoration(
                                    background: AppTheme.surfaceLayer1,
                                    border: AppTheme.statusOfflineBorder,
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.wifi_off_rounded, size: 40, color: AppTheme.statusOffline),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Unable to load buses',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Check your connection and try again.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                      ),
                                      const SizedBox(height: 16),
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
                              // Empty State
                              else if (filteredBuses.isEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                                  decoration: AppTheme.cardDecoration(
                                    background: AppTheme.surfaceLayer1,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
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
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No buses found',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Try searching for another bus, route or stop.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
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
                              // Bus Cards
                              else
                                ...filteredBuses.map((bus) => BusCard(
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
                                    )),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. Routes Screen Tab
                const RoutesScreen(),
              ],
            ),

            // Modern Floating Frosted Navigation Bar Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: Container(
                  height: 52,
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.all(4),
                  decoration: AppTheme.glassDecoration(
                    background: AppTheme.surfaceLayer1.withValues(alpha: 0.92),
                    border: AppTheme.borderMedium,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildNavItem(
                          index: 0,
                          icon: Icons.directions_bus_rounded,
                          label: 'Buses',
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          index: 1,
                          icon: Icons.alt_route_rounded,
                          label: 'Routes',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x333B82F6),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 17,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
