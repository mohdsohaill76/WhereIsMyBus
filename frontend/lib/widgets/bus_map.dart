import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/stop_model.dart';
import '../theme/app_theme.dart';
import 'live_status_dot.dart';

/// Configuration for Map Tile Provider (CARTO Dark Matter / OpenStreetMap)
class MapTileConfig {
  /// CARTO Dark Matter tile endpoint (OpenStreetMap-based dark vector raster)
  static const String darkMapUrl = 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
  static const String fallbackOsmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
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

class _BusMapWidgetState extends State<BusMapWidget> {
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
          padding: const EdgeInsets.all(48),
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.bgDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusSurface),
        border: Border.all(color: AppTheme.borderMedium, width: 1),
      ),
      child: Stack(
        children: [
          // 1. OpenStreetMap (CARTO Dark Matter) Interactive FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialPos,
              initialZoom: widget.isOverviewMode ? 13.0 : 14.8,
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
              // Dark-themed Map Tile Layer
              TileLayer(
                urlTemplate: MapTileConfig.darkMapUrl,
                fallbackUrl: MapTileConfig.fallbackOsmUrl,
                userAgentPackageName: MapTileConfig.userAgentPackage,
                tileProvider: NetworkTileProvider(),
                maxZoom: 19,
              ),

              // Route Polyline Glow Layer & Core Layer
              if (polylinePoints.isNotEmpty) ...[
                // Ambient Glow Casing
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                      strokeWidth: 9.0,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),
                // Crisp Core Line
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      color: AppTheme.primaryBlue,
                      strokeWidth: 4.0,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),
              ],

              // Stop & Bus Markers Layer
              MarkerLayer(
                markers: [
                  for (int i = 0; i < parsedStops.length; i++)
                    _buildStopMarker(parsedStops[i], i, parsedStops.length),

                  // Custom Hero Live Bus Marker
                  if (widget.latitude != 0.0 && widget.longitude != 0.0 && !widget.isOverviewMode)
                    Marker(
                      point: LatLng(widget.latitude, widget.longitude),
                      width: 150,
                      height: 75,
                      alignment: Alignment.center,
                      child: _buildLiveBusHeroMarker(),
                    ),
                ],
              ),

              // OpenStreetMap & CARTO Attribution Badge
              const SimpleAttributionWidget(
                source: Text(
                  '© OpenStreetMap contributors © CARTO',
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

          // 2. Selected Stop Floating Tooltip Card
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
                      : Icons.near_me_rounded,
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

  /// Builds a Stop Marker with dark mode accents
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
    Color borderColor;
    double markerSize = 22;

    if (isCurrent) {
      markerBg = AppTheme.statusLive;
      borderColor = Colors.white;
      markerSize = 28;
    } else if (isNext) {
      markerBg = AppTheme.primaryBlue;
      borderColor = Colors.white;
      markerSize = 26;
    } else if (isOrigin) {
      markerBg = AppTheme.primaryBlue;
      borderColor = AppTheme.primaryBlueLight;
      markerSize = 24;
    } else if (isDestination) {
      markerBg = AppTheme.accentPurple;
      borderColor = Colors.white;
      markerSize = 24;
    } else {
      markerBg = AppTheme.surfaceLayer1;
      borderColor = AppTheme.borderLight;
      markerSize = 18;
    }

    return Marker(
      point: LatLng(stop.latitude, stop.longitude),
      width: 38,
      height: 38,
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
            border: Border.all(color: borderColor, width: (isCurrent || isNext) ? 2.5 : 1.5),
            boxShadow: [
              BoxShadow(
                color: markerBg.withValues(alpha: 0.5),
                blurRadius: (isCurrent || isNext) ? 10 : 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: (isCurrent || isNext || isOrigin || isDestination)
                ? Icon(
                    isCurrent
                        ? Icons.location_on_rounded
                        : (isNext ? Icons.near_me_rounded : (isOrigin ? Icons.trip_origin_rounded : Icons.flag_rounded)),
                    color: Colors.white,
                    size: markerSize * 0.55,
                  )
                : Text(
                    '${stop.sequence}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Custom Hero Live Bus Marker (BUS101 ● LIVE with Emerald Glow)
  Widget _buildLiveBusHeroMarker() {
    final isLive = widget.isLive && !widget.isStale;
    final statusColor = widget.isStale
        ? AppTheme.statusOffline
        : (isLive ? AppTheme.statusLive : AppTheme.statusStopped);
    final statusLabel = widget.isStale
        ? 'STALE'
        : (isLive ? 'LIVE' : (widget.status?.toUpperCase() ?? 'STOPPED'));

    final speedText = widget.speed != null && widget.speed! > 0
        ? ' • ${widget.speed!.toStringAsFixed(0)} km/h'
        : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bus Badge Pill with subtle emerald glow
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLayer1,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(color: statusColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLive)
                LiveStatusDot(size: 4, color: statusColor)
              else
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 5),
              Text(
                '${widget.busNumber} ($statusLabel$speedText)',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // Bus Pin Icon with Core Light Dot
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLayer1,
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.directions_bus_rounded,
              color: statusColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  /// Stop Information Floating Tooltip Card
  Widget _buildStopTooltipCard(StopModel stop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: AppTheme.cardDecoration(
        background: AppTheme.surfaceLayer2,
        border: AppTheme.borderMedium,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppTheme.primaryBlueLight,
              size: 17,
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
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  'Stop #${stop.sequence} • ${stop.id}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
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
            icon: const Icon(Icons.close_rounded, color: AppTheme.textTertiary, size: 18),
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
      color: isAccent ? AppTheme.primaryBlue : AppTheme.surfaceLayer2,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: isAccent ? AppTheme.primaryBlueLight : AppTheme.borderMedium,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isAccent ? Colors.white : AppTheme.textPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
