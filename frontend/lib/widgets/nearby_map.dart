import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/nearby_stop.dart';
import '../models/bus_model.dart';
import '../theme/app_theme.dart';
import 'bus_map.dart';

/// Interactive Flutter Map dedicated to Nearby Transit Radar
class NearbyMapWidget extends StatefulWidget {
  final double? userLat;
  final double? userLng;
  final List<NearbyStop> nearbyStops;
  final List<BusModel> activeBuses;
  final NearbyStop? selectedStop;
  final ValueChanged<NearbyStop>? onStopTapped;
  final VoidCallback? onRecenter;

  const NearbyMapWidget({
    super.key,
    this.userLat,
    this.userLng,
    required this.nearbyStops,
    this.activeBuses = const [],
    this.selectedStop,
    this.onStopTapped,
    this.onRecenter,
  });

  @override
  State<NearbyMapWidget> createState() => _NearbyMapWidgetState();
}

class _NearbyMapWidgetState extends State<NearbyMapWidget> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  void didUpdateWidget(covariant NearbyMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isMapReady) {
      if (widget.selectedStop != null && widget.selectedStop != oldWidget.selectedStop) {
        _mapController.move(
          LatLng(widget.selectedStop!.latitude, widget.selectedStop!.longitude),
          15.5,
        );
      } else if (widget.userLat != null &&
          widget.userLng != null &&
          (widget.userLat != oldWidget.userLat || widget.userLng != oldWidget.userLng)) {
        _mapController.move(
          LatLng(widget.userLat!, widget.userLng!),
          15.0,
        );
      }
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _recenter() {
    if (widget.userLat != null && widget.userLng != null) {
      _mapController.move(LatLng(widget.userLat!, widget.userLng!), 15.0);
    } else if (widget.nearbyStops.isNotEmpty) {
      _mapController.move(
        LatLng(widget.nearbyStops.first.latitude, widget.nearbyStops.first.longitude),
        15.0,
      );
    }
    widget.onRecenter?.call();
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = widget.userLat ??
        (widget.nearbyStops.isNotEmpty ? widget.nearbyStops.first.latitude : 17.9784);
    final centerLng = widget.userLng ??
        (widget.nearbyStops.isNotEmpty ? widget.nearbyStops.first.longitude : 79.5941);

    final List<Marker> markers = [];

    // 1. Passenger Location Marker
    if (widget.userLat != null && widget.userLng != null) {
      markers.add(
        Marker(
          point: LatLng(widget.userLat!, widget.userLng!),
          width: 50,
          height: 50,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppTheme.primaryBlueLight.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
                // Inner Core Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlueLight,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x663B82F6),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Nearby Stop Markers
    for (final nearby in widget.nearbyStops) {
      final isSelected = widget.selectedStop?.id == nearby.id;

      markers.add(
        Marker(
          point: LatLng(nearby.latitude, nearby.longitude),
          width: isSelected ? 120 : 90,
          height: 60,
          child: GestureDetector(
            onTap: () => widget.onStopTapped?.call(nearby),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stop Label Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentCyan : AppTheme.surfaceLayer1,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: isSelected ? Colors.white : AppTheme.accentCyan.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: AppTheme.shadowSubtle,
                  ),
                  child: Text(
                    nearby.shortName.isNotEmpty ? nearby.shortName : nearby.name,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppTheme.bgDark : AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                // Pin Icon
                Icon(
                  Icons.location_on_rounded,
                  color: isSelected ? AppTheme.accentCyan : AppTheme.accentCyan.withValues(alpha: 0.8),
                  size: isSelected ? 26 : 22,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(centerLat, centerLng),
              initialZoom: 14.5,
              minZoom: 10.0,
              maxZoom: 18.0,
              onMapReady: () {
                setState(() => _isMapReady = true);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapTileConfig.darkMapUrl,
                fallbackUrl: MapTileConfig.fallbackOsmUrl,
                userAgentPackageName: MapTileConfig.userAgentPackage,
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Map Control Floating Actions (+, -, Recenter)
          Positioned(
            right: 14,
            bottom: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 6),
                _buildMapButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: _zoomOut,
                ),
                const SizedBox(height: 6),
                _buildMapButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter on Location',
                  color: AppTheme.primaryBlueLight,
                  onTap: _recenter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = AppTheme.textPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Container(
          width: 36,
          height: 36,
          decoration: AppTheme.glassDecoration(
            background: AppTheme.surfaceLayer1.withValues(alpha: 0.9),
            border: AppTheme.borderMedium,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
