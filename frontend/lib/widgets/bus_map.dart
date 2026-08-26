import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/stop_model.dart';
import '../theme/app_theme.dart';

/// Configuration for Map Tile Provider (Modular for easy swapping)
class MapTileConfig {
  /// Default OpenStreetMap tile endpoint
  static const String openStreetMapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackage = 'com.whereismybus.app';
}

class BusMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String busNumber;
  final String currentStop;
  final String nextStop;
  final List<dynamic> stops;
  final bool isLive;
  final bool isStale;
  final double? speed;
  final String? status;
  final bool isOverviewMode;

  const BusMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.busNumber,
    required this.currentStop,
    required this.nextStop,
    required this.stops,
    this.isLive = true,
    this.isStale = false,
    this.speed,
    this.status,
    this.isOverviewMode = false,
  });

  @override
  State<BusMapWidget> createState() => _BusMapWidgetState();
}

class _BusMapWidgetState extends State<BusMapWidget> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  StopModel? _selectedStop;
  bool _isMapReady = false;

  @override
  void didUpdateWidget(covariant BusMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) &&
        !widget.isOverviewMode &&
        widget.latitude != 0.0 &&
        widget.longitude != 0.0 &&
        _isMapReady) {
      _mapController.move(
        LatLng(widget.latitude, widget.longitude),
        _mapController.camera.zoom,
      );
    } else if (oldWidget.stops != widget.stops && widget.isOverviewMode && _isMapReady) {
      _fitRouteBounds();
    }
  }

  /// Parses diverse stop formats into unified StopModel list
  List<StopModel> _parseStops() {
    final List<StopModel> parsed = [];
    for (int i = 0; i < widget.stops.length; i++) {
      final item = widget.stops[i];
      if (item is StopModel) {
        parsed.add(item);
      } else if (item is Map<String, dynamic>) {
        parsed.add(StopModel.fromJson(item, null, i + 1));
      } else if (item is Map<String, String>) {
        final Map<String, dynamic> dynMap = Map<String, dynamic>.from(item);
        if (dynMap['latitude'] is String) {
          dynMap['latitude'] = double.tryParse(dynMap['latitude']) ?? 17.9784;
        }
        if (dynMap['longitude'] is String) {
          dynMap['longitude'] = double.tryParse(dynMap['longitude']) ?? 79.5941;
        }
        parsed.add(StopModel.fromJson(dynMap, null, i + 1));
      }
    }
    return parsed;
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom < 18.5) {
      _mapController.move(_mapController.camera.center, currentZoom + 1.0);
    }
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    if (currentZoom > 3.0) {
      _mapController.move(_mapController.camera.center, currentZoom - 1.0);
    }
  }

  void _recenterBus() {
    if (widget.isOverviewMode) {
      _fitRouteBounds();
    } else {
      final target = (widget.latitude != 0.0 && widget.longitude != 0.0)
          ? LatLng(widget.latitude, widget.longitude)
          : const LatLng(17.9784, 79.5941);
      _mapController.move(target, 15.0);
    }
  }

  void _fitRouteBounds() {
    final parsedStops = _parseStops();
    if (parsedStops.isEmpty) return;

    final points = parsedStops.map((s) => LatLng(s.latitude, s.longitude)).toList();
    if (widget.latitude != 0.0 && widget.longitude != 0.0) {
      points.add(LatLng(widget.latitude, widget.longitude));
    }

    if (points.isNotEmpty) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialPos = LatLng(
      widget.latitude != 0.0 ? widget.latitude : 17.9784,
      widget.longitude != 0.0 ? widget.longitude : 79.5941,
    );

    final parsedStops = _parseStops();
    final polylinePoints = parsedStops.map((s) => LatLng(s.latitude, s.longitude)).toList();

    // Determine Bus Status Styling
    final Color busStatusColor;
    final String busStatusLabel;
    if (widget.isStale) {
      busStatusColor = const Color(0xFFF97316); // Orange
      busStatusLabel = 'STALE';
    } else if (widget.isLive) {
      busStatusColor = const Color(0xFF10B981); // Emerald Green
      busStatusLabel = 'LIVE';
    } else {
      busStatusColor = const Color(0xFFF59E0B); // Amber
      busStatusLabel = widget.status?.toUpperCase() ?? 'STOPPED';
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. OpenStreetMap Interactive FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialPos,
              initialZoom: widget.isOverviewMode ? 13.0 : 14.5,
              minZoom: 3.0,
              maxZoom: 18.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onMapReady: () {
                setState(() {
                  _isMapReady = true;
                });
                if (widget.isOverviewMode && parsedStops.isNotEmpty) {
                  _fitRouteBounds();
                }
              },
              onTap: (tapPosition, point) {
                if (_selectedStop != null) {
                  setState(() {
                    _selectedStop = null;
                  });
                }
              },
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: MapTileConfig.openStreetMapUrl,
                userAgentPackageName: MapTileConfig.userAgentPackage,
                tileProvider: NetworkTileProvider(),
                maxZoom: 19,
              ),

              // Route Polyline Layer
              if (polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Base Blue Route Line
                    Polyline(
                      points: polylinePoints,
                      color: AppTheme.primaryBlue,
                      strokeWidth: 5.0,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),

              // Stop Markers Layer
              MarkerLayer(
                markers: [
                  for (int i = 0; i < parsedStops.length; i++)
                    _buildStopMarker(parsedStops[i], i, parsedStops.length),

                  // Live Bus Marker
                  if (widget.latitude != 0.0 && widget.longitude != 0.0 && !widget.isOverviewMode)
                    Marker(
                      point: LatLng(widget.latitude, widget.longitude),
                      width: 140,
                      height: 70,
                      alignment: Alignment.center,
                      child: _buildLiveBusMarkerWidget(busStatusColor, busStatusLabel),
                    ),
                ],
              ),

              // Standard OpenStreetMap Attribution
              const SimpleAttributionWidget(
                source: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                alignment: Alignment.bottomLeft,
              ),
            ],
          ),

          // 2. Selected Stop Detail Tooltip/Card Overlay
          if (_selectedStop != null)
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _buildStopTooltipCard(_selectedStop!),
            ),

          // 3. Floating Custom Map Controls (Zoom In, Zoom Out, Recenter)
          Positioned(
            right: 14,
            bottom: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapControlButton(
                  icon: Icons.add_rounded,
                  onTap: _zoomIn,
                  tooltip: 'Zoom In',
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: Icons.remove_rounded,
                  onTap: _zoomOut,
                  tooltip: 'Zoom Out',
                ),
                const SizedBox(height: 8),
                _buildMapControlButton(
                  icon: widget.isOverviewMode
                      ? Icons.crop_free_rounded
                      : Icons.center_focus_strong_rounded,
                  onTap: _recenterBus,
                  tooltip: widget.isOverviewMode ? 'Fit Route' : 'Recenter Bus',
                  isAccent: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a Stop Marker with distinct styling for Origin, Destination, Current, Next, and Waypoints
  Marker _buildStopMarker(StopModel stop, int index, int totalStops) {
    final isOrigin = index == 0;
    final isDestination = index == totalStops - 1 && totalStops > 1;
    final isCurrent = stop.name.toLowerCase().contains(widget.currentStop.toLowerCase()) ||
        stop.shortName.toLowerCase().contains(widget.currentStop.toLowerCase()) ||
        stop.id.toLowerCase() == widget.currentStop.toLowerCase();
    final isNext = stop.name.toLowerCase().contains(widget.nextStop.toLowerCase()) ||
        stop.shortName.toLowerCase().contains(widget.nextStop.toLowerCase()) ||
        stop.id.toLowerCase() == widget.nextStop.toLowerCase();

    Color markerBg;
    IconData markerIcon;
    double markerSize = 28;

    if (isCurrent) {
      markerBg = const Color(0xFF10B981); // Emerald Green
      markerIcon = Icons.location_pin;
      markerSize = 34;
    } else if (isNext) {
      markerBg = const Color(0xFF06B6D4); // Cyan
      markerIcon = Icons.navigation_rounded;
      markerSize = 32;
    } else if (isOrigin) {
      markerBg = const Color(0xFF22C55E); // Green
      markerIcon = Icons.trip_origin_rounded;
      markerSize = 28;
    } else if (isDestination) {
      markerBg = const Color(0xFFEF4444); // Red
      markerIcon = Icons.sports_score_rounded;
      markerSize = 28;
    } else {
      markerBg = const Color(0xFF475569); // Slate Blue
      markerIcon = Icons.circle;
      markerSize = 24;
    }

    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: 44,
      height: 44,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStop = stop;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: markerSize,
          height: markerSize,
          decoration: BoxDecoration(
            color: markerBg,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: markerBg.withValues(alpha: 0.45),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: (isCurrent || isNext || isOrigin || isDestination)
                ? Icon(markerIcon, color: Colors.white, size: markerSize * 0.55)
                : Text(
                    '${stop.sequence}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Builds the animated, glowing Live Bus Marker
  Widget _buildLiveBusMarkerWidget(Color statusColor, String statusLabel) {
    final speedText = widget.speed != null && widget.speed! > 0
        ? ' • ${widget.speed!.toStringAsFixed(0)} km/h'
        : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bus Badge Label Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '${widget.busNumber} ($statusLabel$speedText)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),

        // Glowing Bus Icon Pin
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.directions_bus_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ],
    );
  }

  /// Stop Information Floating Tooltip Card
  Widget _buildStopTooltipCard(StopModel stop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stop.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stop #${stop.sequence} • ${stop.id}',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedStop = null;
              });
            },
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Dismiss',
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isAccent = false,
  }) {
    return Material(
      color: isAccent ? AppTheme.primaryBlue : const Color(0xEE1E293B),
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAccent ? const Color(0x6693C5FD) : const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
