import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'nearby_screen.dart';
import 'routes_screen.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

/// Master Responsive Application Shell for WhereIsMyBus V2
/// Seamlessly adapts between Mobile Bottom Dock, Tablet Navigation Rail, and Desktop Sidebar.
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.directions_bus_rounded,
      selectedIcon: Icons.directions_bus_filled_rounded,
      label: 'Buses',
      tooltip: 'Live Bus Tracking',
      keyName: 'nav_buses',
    ),
    _NavItem(
      icon: Icons.near_me_outlined,
      selectedIcon: Icons.near_me_rounded,
      label: 'Nearby',
      tooltip: 'Nearby Transit Stops',
      keyName: 'nav_nearby',
    ),
    _NavItem(
      icon: Icons.alt_route_rounded,
      selectedIcon: Icons.alt_route_rounded,
      label: 'Routes',
      tooltip: 'Transit Corridors',
      keyName: 'nav_routes',
    ),
    _NavItem(
      icon: Icons.bookmark_border_rounded,
      selectedIcon: Icons.bookmark_rounded,
      label: 'Favorites',
      tooltip: 'Saved Favorites',
      keyName: 'nav_favorites',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      HomeScreen(),
      NearbyScreen(),
      RoutesScreen(),
      FavoritesScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: ResponsiveLayout(
          // ── Mobile Layout (Bottom Floating Navigation Dock) ─────────────
          mobile: Stack(
            children: [
              Positioned.fill(
                child: IndexedStack(
                  index: _currentIndex,
                  children: screens,
                ),
              ),
              Positioned(
                left: AppTheme.space16,
                right: AppTheme.space16,
                bottom: AppTheme.space16,
                child: _buildMobileBottomDock(),
              ),
            ],
          ),

          // ── Tablet Layout (Adaptive Navigation Rail) ─────────────────────
          tablet: Row(
            children: [
              _buildTabletNavRail(),
              const VerticalDivider(width: 1, color: AppTheme.borderSubtle),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: screens,
                ),
              ),
            ],
          ),

          // ── Desktop Layout (Full Sidebar Navigation Workbench) ───────────
          desktop: Row(
            children: [
              _buildDesktopSidebar(),
              const VerticalDivider(width: 1, color: AppTheme.borderSubtle),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: screens,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile Bottom Floating Glass Dock ──────────────────────────────────
  Widget _buildMobileBottomDock() {
    return Center(
      child: Container(
        height: 60,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: AppTheme.glassDecoration(
          background: AppTheme.surfaceLayer1.withValues(alpha: 0.95),
          border: AppTheme.borderMedium,
        ),
        child: Row(
          children: List.generate(_navItems.length, (index) {
            final item = _navItems[index];
            final isSelected = _currentIndex == index;

            return Expanded(
              child: Semantics(
                button: true,
                selected: isSelected,
                label: item.label,
                child: InkWell(
                  key: Key(item.keyName),
                  onTap: () => _onTabSelected(index),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.selectedIcon : item.icon,
                          color: isSelected
                              ? AppTheme.primaryBlueLight
                              : AppTheme.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryBlueLight
                                : AppTheme.textTertiary,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Tablet Navigation Rail ─────────────────────────────────────────────
  Widget _buildTabletNavRail() {
    return Container(
      width: ResponsiveBreakpoints.navRailWidth,
      color: AppTheme.surfaceLayer1,
      child: Column(
        children: [
          const SizedBox(height: AppTheme.space16),
          // Brand Logo
          Container(
            padding: const EdgeInsets.all(AppTheme.space8),
            decoration: BoxDecoration(
              gradient: AppTheme.accentButtonGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.directions_bus_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: AppTheme.space24),

          // Nav Rail Items
          Expanded(
            child: Column(
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Tooltip(
                    message: item.tooltip,
                    child: InkWell(
                      key: Key(item.keyName),
                      onTap: () => _onTabSelected(index),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryBlue.withValues(alpha: 0.4)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected
                                  ? AppTheme.primaryBlueLight
                                  : AppTheme.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.primaryBlueLight
                                    : AppTheme.textTertiary,
                                fontSize: 9,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop Sidebar Navigation ─────────────────────────────────────────
  Widget _buildDesktopSidebar() {
    return Container(
      width: ResponsiveBreakpoints.sideNavWidth,
      color: AppTheme.surfaceLayer1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header with Expanded text to prevent any overflow
          Row(
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WhereIsMyBus',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Passenger Transit V2',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),

          // Quick Search Button
          InkWell(
            key: const Key('desktop_global_search_button'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLayer2,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.borderMedium),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, size: 16, color: AppTheme.primaryBlueLight),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search anything...',
                      style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
                    ),
                  ),
                  Text(
                    'Ctrl K',
                    style: TextStyle(fontSize: 10, color: AppTheme.textTertiary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.space20),
          const Divider(color: AppTheme.borderSubtle, height: 1),
          const SizedBox(height: AppTheme.space16),

          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Sidebar Navigation Links
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: item.label,
                    child: InkWell(
                      key: Key(item.keyName),
                      onTap: () => _onTabSelected(index),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.surfaceLayer2 : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: isSelected ? AppTheme.borderAccent : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? AppTheme.primaryBlueLight : AppTheme.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: AppTheme.space12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer Telemetry Status Indicator
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLayer2,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.statusLive,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTheme.space8),
                const Expanded(
                  child: Text(
                    'RTDB Live Connected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String tooltip;
  final String keyName;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.tooltip,
    required this.keyName,
  });
}
