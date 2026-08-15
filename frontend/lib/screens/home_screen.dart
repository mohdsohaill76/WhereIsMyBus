import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/bus_model.dart';
import '../services/transit_api_service.dart';
import '../widgets/bus_card.dart';
import '../widgets/quick_stats_bar.dart';
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
      return s == 'moving' || s == 'active' || s == 'in_transit';
    }).length;

    final uniqueRoutesCount = _buses.map((b) => b.routeId).toSet().length;

    return Scaffold(
      backgroundColor: AppTheme.bgSlate,
      body: SafeArea(
        child: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                // Home Tab Content
                CustomScrollView(
                  slivers: [
                    // Top Hero Header Section
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.headerGradient,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // App Brand Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x402563EB),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.directions_bus_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'WhereIsMyBus',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                        SizedBox(height: 1),
                                        Text(
                                          'Your city, moving with you',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF4ADE80),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$liveCount LIVE',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Primary Search / Discovery Input
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x24000000),
                                    blurRadius: 14,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    color: AppTheme.primaryBlue,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Search bus number or route...',
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 14,
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
                                        color: AppTheme.textMuted,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Content Padding Area
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Quick Stats Bar
                          QuickStatsBar(
                            totalBuses: _buses.length,
                            liveBuses: liveCount,
                            activeRoutes: uniqueRoutesCount,
                          ),
                          const SizedBox(height: 24),

                          // Section Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Live Buses Near You',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${filteredBuses.length} Buses',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Loading State
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 50),
                              child: Center(
                                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                              ),
                            )
                          // Connection Error State
                          else if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: AppTheme.cardDecoration(),
                              child: Column(
                                children: [
                                  const Icon(Icons.cloud_off_rounded, size: 42, color: Color(0xFFDC2626)),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Unable to connect to server',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _loadBuses,
                                    icon: const Icon(Icons.refresh_rounded, size: 16),
                                    label: const Text('Retry Connection'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryNavy,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // Empty Search State
                          else if (filteredBuses.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                              decoration: AppTheme.cardDecoration(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.bgSlate,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.search_off_rounded,
                                      size: 36,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'No buses found',
                                    style: TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Try searching for another bus number or route.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
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
                                    icon: const Icon(Icons.refresh_rounded, size: 16),
                                    label: const Text('Clear Search'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBlue,
                                      side: const BorderSide(color: AppTheme.primaryBlue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // Dynamic Real Buses List
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

                // Routes Tab
                const RoutesScreen(),
              ],
            ),

            // Floating Bottom Navigation Bar
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3B000000),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.directions_bus_rounded,
                      label: 'Buses',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.alt_route_rounded,
                      label: 'Routes',
                    ),
                  ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 20,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
