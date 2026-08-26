import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/live_location.dart';
import '../models/stop_model.dart';
import '../services/transit_api_service.dart';
import '../widgets/bus_map.dart';
import '../widgets/tracking_status_card.dart';
import '../widgets/route_progress_card.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = (screenHeight * 0.44).clamp(320.0, 420.0);
    final mapBottomPadding = bottomSheetHeight - 30.0;

    final isStale = _location?.isStale ?? false;
    final isLive = !isStale && (_location?.status.toLowerCase() == 'moving');

    final displayBusName = widget.busNumber.toLowerCase().startsWith('bus')
        ? widget.busNumber
        : 'Bus ${widget.busNumber.replaceAll('BUS', '')}';

    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Dominant Google Map Layer
            Positioned.fill(
              bottom: mapBottomPadding,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                    )
                  : (_errorMessage != null || _location == null)
                      ? Container(
                          color: AppTheme.primaryNavy,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.wifi_off_rounded, size: 44, color: Color(0xFFEF4444)),
                                  const SizedBox(height: 12),
                                  Text(
                                    _errorMessage ?? 'Bus location unavailable',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : BusMapWidget(
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
                        ),
            ),

            // 2. Floating Top Header Controls over Map
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button Pill
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF334155)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x3B000000), blurRadius: 8),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bus ID & Live / Offline Pill Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF334155)),
                      boxShadow: const [
                        BoxShadow(color: Color(0x3B000000), blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          displayBusName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isLive ? const Color(0xFF4ADE80) : Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLive ? 'LIVE' : (isStale ? 'STALE' : _location?.status.toUpperCase() ?? 'OFFLINE'),
                          style: TextStyle(
                            color: isLive ? const Color(0xFF4ADE80) : Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Sliding / Floating Bottom Information Panel Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottomSheetHeight,
              child: Container(
                decoration: AppTheme.sheetDecoration(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sheet Handle Indicator Bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_location != null) ...[
                        // Telemetry Hero Panel with Prominent ETA
                        TrackingStatusCard(
                          location: _location!,
                          nextStopLat: _nextStopModel?.latitude,
                          nextStopLng: _nextStopModel?.longitude,
                          onRefresh: () => _fetchData(showLoading: false),
                        ),
                        const SizedBox(height: 16),

                        // Route Progress Timeline Card
                        RouteProgressCard(
                          currentStop: _location!.currentStop,
                          nextStop: _location!.nextStop,
                          stops: _routeStops,
                          routeName: widget.routeName,
                        ),
                        const SizedBox(height: 16),

                        // Trip Metadata Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trip Summary',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildSummaryRow('Bus Number', displayBusName),
                              _buildSummaryRow('Route', widget.routeName),
                              _buildSummaryRow('Trip ID', _location!.tripId),
                              _buildSummaryRow('Status', _location!.status.toUpperCase()),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}
