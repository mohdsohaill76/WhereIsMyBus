import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/route_model.dart';
import '../services/transit_api_service.dart';
import '../widgets/route_card.dart';
import '../widgets/skeleton_loader.dart';
import 'route_details_screen.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  final TransitApiService _apiService = TransitApiService();
  List<RouteModel> _allRoutes = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final routes = await _apiService.fetchRoutes();
      if (mounted) {
        setState(() {
          _allRoutes = routes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRoutes = _allRoutes.where((route) {
      final query = _searchQuery.toLowerCase();
      final idMatch = route.id.toLowerCase().contains(query);
      final nameMatch = route.name.toLowerCase().contains(query);
      final stopMatch = route.stops.any((s) =>
          s.name.toLowerCase().contains(query) || s.shortName.toLowerCase().contains(query));
      return idMatch || nameMatch || stopMatch;
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
        child: CustomScrollView(
          slivers: [
            // Top Header & Search Area
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Brand
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: AppTheme.accentPurple.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.alt_route_rounded,
                            color: AppTheme.accentPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Routes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              'Find your route and see buses operating right now.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Input Component
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLayer1,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(
                          color: _searchQuery.isNotEmpty
                              ? AppTheme.accentPurple
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
                            color: AppTheme.accentPurple,
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
                              cursorColor: AppTheme.accentPurple,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search routes or stops...',
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

            // Content Area
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 95),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_isLoading) ...[
                    const RouteCardSkeleton(),
                    const RouteCardSkeleton(),
                    const RouteCardSkeleton(),
                  ]
                  else if (_hasError)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: AppTheme.cardDecoration(
                        background: AppTheme.surfaceLayer1,
                        border: AppTheme.statusOfflineBorder,
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.statusOffline),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to load routes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Check your connection and try again.',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadRoutes,
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
                  else ...[
                    // Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Routes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLayer2,
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Text(
                            '${filteredRoutes.length} Routes',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Empty State
                    if (filteredRoutes.isEmpty)
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
                              'No routes found',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try searching for another route name or stop.',
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
                                foregroundColor: AppTheme.accentPurple,
                                side: const BorderSide(color: AppTheme.borderMedium),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...filteredRoutes.map((route) => RouteCard(
                            route: route,
                            onViewRoutePressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RouteDetailsScreen(route: route),
                                ),
                              );
                            },
                          )),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
