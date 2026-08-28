import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/live_location.dart';
import '../models/stop_model.dart';
import '../services/transit_api_service.dart';
import '../widgets/bus_map.dart';
import '../widgets/tracking_status_card.dart';
import '../widgets/route_progress_card.dart';
import '../widgets/live_status_dot.dart';

class BusTrackingScreen extends StatefulWidget {
  final String busNumber;
  final String routeName;

  const BusTrackingScreen({
    super.key,
    this.busNumber = 'BUS101',
    this.routeName = 'Warangal → Kazipet',
  });

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  final TransitApiService _apiService = TransitApiService();
  LiveLocation? _location;
  List<StopModel> _routeStops = [];
  StopModel? _nextStopModel;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto refresh live location telemetry every 15 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchData(showLoading: false);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool showLoading = true}) async {
    if (showLoading && _location == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final stops = await _apiService.getStopsForBus(widget.busNumber);
      final loc = await _apiService.getLiveLocation(widget.busNumber);

      if (mounted) {
        StopModel? resolvedNextStop;
        if (loc != null && loc.nextStop.isNotEmpty) {
          final nextQuery = loc.nextStop.trim().toLowerCase();
          for (final s in stops) {
            if (s.id.toLowerCase() == nextQuery ||
                s.shortName.toLowerCase() == nextQuery ||
                s.name.toLowerCase() == nextQuery ||
                s.name.toLowerCase().contains(nextQuery)) {
              resolvedNextStop = s;
              break;
            }
          }
          resolvedNextStop ??= await _apiService.resolveStop(loc.nextStop);
        }

        setState(() {
          _location = loc;
          _routeStops = stops;
          _nextStopModel = resolvedNextStop;
          _isLoading = false;
          _errorMessage = loc == null ? 'Bus location not found' : null;
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
    final isStale = _location?.isStale ?? false;
    final isLive = !isStale && (_location?.status.toLowerCase() == 'moving' || _location?.status.toLowerCase() == 'live');

    final displayBusName = widget.busNumber.toLowerCase().startsWith('bus')
        ? widget.busNumber
        : 'Bus ${widget.busNumber.replaceAll('BUS', '')}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          body: SafeArea(
            child: isDesktop
                ? _buildDesktopLayout(displayBusName, isLive, isStale)
                : _buildMobileLayout(displayBusName, isLive, isStale),
          ),
        );
      },
    );
  }

  /// Responsive Mobile / Small Screen Layout (Dominant 68% map with sliding bottom panel)
  Widget _buildMobileLayout(String displayBusName, bool isLive, bool isStale) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = (screenHeight * 0.42).clamp(320.0, 420.0);
    final mapBottomPadding = bottomSheetHeight - 20.0;

    return Stack(
      children: [
        // 1. Dominant Interactive Dark OpenStreetMap Layer
        Positioned.fill(
          bottom: mapBottomPadding,
          child: _buildMapArea(displayBusName, isLive, isStale),
        ),

        // 2. Minimal Floating Top Controls (← Back | BUS101 ● LIVE)
        Positioned(
          top: 14,
          left: 14,
          right: 14,
          child: _buildTopOverlayHeader(displayBusName, isLive, isStale),
        ),

        // 3. Sliding / Floating Bottom Information Panel Sheet
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: bottomSheetHeight,
          child: Container(
            decoration: AppTheme.sheetDecoration(background: AppTheme.surfaceLayer1),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.borderMedium,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_location != null) ...[
                    // Dominant ETA Hero Card
                    TrackingStatusCard(
                      location: _location!,
                      nextStopLat: _nextStopModel?.latitude,
                      nextStopLng: _nextStopModel?.longitude,
                      onRefresh: () => _fetchData(showLoading: false),
                    ),
                    const SizedBox(height: 14),

                    // Route Progress Timeline Card
                    RouteProgressCard(
                      currentStop: _location!.currentStop,
                      nextStop: _location!.nextStop,
                      stops: _routeStops,
                      routeName: widget.routeName,
                    ),
                    const SizedBox(height: 14),

                    // Trip Summary Card
                    _buildTripSummaryCard(displayBusName),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Responsive Desktop / Tablet Layout (65% Map on left, 35% Telemetry Workbench on right)
  Widget _buildDesktopLayout(String displayBusName, bool isLive, bool isStale) {
    return Column(
      children: [
        // Desktop Top App Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLayer1,
            border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                    tooltip: 'Back to Home',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    displayBusName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${widget.routeName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _buildStatusPill(isLive, isStale),
            ],
          ),
        ),

        // Desktop Split Area
        Expanded(
          child: Row(
            children: [
              // Dominant Map (65%)
              Expanded(
                flex: 65,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildMapArea(displayBusName, isLive, isStale),
                ),
              ),

              // Side Telemetry Panel (35%)
              Expanded(
                flex: 35,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceLayer1,
                    border: Border(left: BorderSide(color: AppTheme.borderSubtle)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_location != null) ...[
                          TrackingStatusCard(
                            location: _location!,
                            nextStopLat: _nextStopModel?.latitude,
                            nextStopLng: _nextStopModel?.longitude,
                            onRefresh: () => _fetchData(showLoading: false),
                          ),
                          const SizedBox(height: 16),
                          RouteProgressCard(
                            currentStop: _location!.currentStop,
                            nextStop: _location!.nextStop,
                            stops: _routeStops,
                            routeName: widget.routeName,
                          ),
                          const SizedBox(height: 16),
                          _buildTripSummaryCard(displayBusName),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Minimal Top Floating Controls for Map
  Widget _buildTopOverlayHeader(String displayBusName, bool isLive, bool isStale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Pill
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: AppTheme.glassDecoration(
                background: AppTheme.surfaceLayer1.withValues(alpha: 0.9),
                border: AppTheme.borderMedium,
              ),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bus ID & Status Badge Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: AppTheme.glassDecoration(
            background: AppTheme.surfaceLayer1.withValues(alpha: 0.9),
            border: AppTheme.borderMedium,
          ),
          child: Row(
            children: [
              Text(
                displayBusName,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              if (isLive)
                const LiveStatusDot(size: 4, color: AppTheme.statusLive)
              else
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isStale ? AppTheme.statusOffline : AppTheme.statusStopped,
                  ),
                ),
              const SizedBox(width: 5),
              Text(
                isLive ? 'LIVE' : (isStale ? 'STALE' : _location?.status.toUpperCase() ?? 'OFFLINE'),
                style: TextStyle(
                  color: isLive ? AppTheme.statusLive : (isStale ? AppTheme.statusOffline : AppTheme.statusStopped),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(bool isLive, bool isStale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isStale
            ? AppTheme.statusOfflineBg
            : (isLive ? AppTheme.statusLiveBg : AppTheme.statusStoppedBg),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: isStale
              ? AppTheme.statusOfflineBorder
              : (isLive ? AppTheme.statusLiveBorder : AppTheme.statusStoppedBorder),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            const LiveStatusDot(size: 4, color: AppTheme.statusLive)
          else
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isStale ? AppTheme.statusOffline : AppTheme.statusStopped,
              ),
            ),
          const SizedBox(width: 5),
          Text(
            isLive ? 'LIVE' : (isStale ? 'STALE' : _location?.status.toUpperCase() ?? 'OFFLINE'),
            style: TextStyle(
              color: isLive ? AppTheme.statusLive : (isStale ? AppTheme.statusOffline : AppTheme.statusStopped),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// Map Rendering Area
  Widget _buildMapArea(String displayBusName, bool isLive, bool isStale) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }
    if (_errorMessage != null || _location == null) {
      return Container(
        color: AppTheme.bgDark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 44, color: AppTheme.statusOffline),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Bus location unavailable',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchData,
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
          ),
        ),
      );
    }

    return BusMapWidget(
      latitude: _location!.latitude,
      longitude: _location!.longitude,
      busNumber: displayBusName,
      currentStop: _location!.currentStop,
      nextStop: _location!.nextStop,
      stops: _routeStops,
      isLive: isLive,
      isStale: isStale,
      speed: _location!.speed,
      status: _location!.status,
    );
  }

  /// Trip Summary Card
  Widget _buildTripSummaryCard(String displayBusName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(
        background: AppTheme.surfaceLayer2,
        border: AppTheme.borderMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trip Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow('Bus ID', displayBusName),
          _buildSummaryRow('Route', widget.routeName),
          _buildSummaryRow('Trip ID', _location!.tripId),
          _buildSummaryRow('Status', _location!.status.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
