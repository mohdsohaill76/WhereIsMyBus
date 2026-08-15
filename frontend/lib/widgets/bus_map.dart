import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BusMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String busNumber;
  final String currentStop;
  final String nextStop;
  final List<Map<String, String>> stops;

  const BusMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.busNumber,
    required this.currentStop,
    required this.nextStop,
    required this.stops,
  });

  @override
  State<BusMapWidget> createState() => _BusMapWidgetState();
}

class _BusMapWidgetState extends State<BusMapWidget> {
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.25).clamp(0.8, 2.5);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.25).clamp(0.8, 2.5);
    });
  }

  void _recenter() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // Interactive Map Canvas
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _panOffset += details.delta;
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: _MapCanvasPainter(
                zoom: _zoomLevel,
                offset: _panOffset,
                latitude: widget.latitude,
                longitude: widget.longitude,
                currentStop: widget.currentStop,
                nextStop: widget.nextStop,
                stops: widget.stops,
              ),
            ),
          ),

          // Top Floating Pill: Lat/Lng Coordinates
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xCC0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location_rounded, color: AppTheme.primaryBlue, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.latitude.toStringAsFixed(4)}, ${widget.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bus Marker Label Overlay (Centered on Map Canvas)
          Center(
            child: Transform.translate(
              offset: _panOffset,
              child: Transform.scale(
                scale: _zoomLevel,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bus Marker Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x662563EB),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_bus_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            widget.busNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Pointer triangle
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map Control Floating Buttons (Zoom In, Zoom Out, Recenter)
          Positioned(
            right: 12,
            bottom: 12,
            child: Column(
              children: [
                _buildMapButton(
                  icon: Icons.add_rounded,
                  onTap: _zoomIn,
                  tooltip: 'Zoom In',
                ),
                const SizedBox(height: 6),
                _buildMapButton(
                  icon: Icons.remove_rounded,
                  onTap: _zoomOut,
                  tooltip: 'Zoom Out',
                ),
                const SizedBox(height: 6),
                _buildMapButton(
                  icon: Icons.center_focus_strong_rounded,
                  onTap: _recenter,
                  tooltip: 'Recenter Bus',
                  isAccent: true,
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
    required VoidCallback onTap,
    required String tooltip,
    bool isAccent = false,
  }) {
    return Material(
      color: isAccent ? AppTheme.primaryBlue : const Color(0xEE1E293B),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAccent ? Colors.white24 : const Color(0xFF334155),
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

class _MapCanvasPainter extends CustomPainter {
  final double zoom;
  final Offset offset;
  final double latitude;
  final double longitude;
  final String currentStop;
  final String nextStop;
  final List<Map<String, String>> stops;

  _MapCanvasPainter({
    required this.zoom,
    required this.offset,
    required this.latitude,
    required this.longitude,
    required this.currentStop,
    required this.nextStop,
    required this.stops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2) + offset;

    // Draw Dark Slate Grid background roads
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.0;

    final mainArterial = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 20.0 * zoom
      ..strokeCap = StrokeCap.round;

    // Grid lines
    for (double i = -500; i < size.width + 500; i += 60 * zoom) {
      canvas.drawLine(
        Offset(i + offset.dx % 60, 0),
        Offset(i + offset.dx % 60, size.height),
        gridPaint,
      );
    }
    for (double j = -500; j < size.height + 500; j += 60 * zoom) {
      canvas.drawLine(
        Offset(0, j + offset.dy % 60),
        Offset(size.width, j + offset.dy % 60),
        gridPaint,
      );
    }

    // Arterial transit road curve across screen
    final path = Path();
    final p0 = center + Offset(-160 * zoom, 120 * zoom);
    final p1 = center + Offset(-60 * zoom, -20 * zoom); // Current stop (Hanamkonda)
    final p2 = center + Offset(80 * zoom, -80 * zoom); // Next stop (Subedari)
    final p3 = center + Offset(180 * zoom, 40 * zoom);

    path.moveTo(p0.dx, p0.dy);
    path.cubicTo(p1.dx - 30 * zoom, p1.dy + 30 * zoom, p2.dx - 20 * zoom, p2.dy, p3.dx, p3.dy);

    canvas.drawPath(path, mainArterial);

    // Active Route Polyline
    final activeRoutePaint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 6.0 * zoom
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, activeRoutePaint);

    // Draw Stop Nodes along route
    final stopPoints = [
      center + Offset(-150 * zoom, 110 * zoom), // Warangal
      center + Offset(-60 * zoom, -20 * zoom), // Hanamkonda (Current)
      center + Offset(30 * zoom, -65 * zoom), // Subedari (Next)
      center + Offset(100 * zoom, -30 * zoom), // NIT Warangal
      center + Offset(170 * zoom, 35 * zoom), // Kazipet
    ];

    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final nodeBorderPaint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 3.0 * zoom
      ..style = PaintingStyle.stroke;

    final currentHighlightPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < stopPoints.length && i < stops.length; i++) {
      final point = stopPoints[i];
      final stopName = stops[i]['shortName'] ?? stops[i]['name']!;
      final isCurrent = stopName.toLowerCase().contains(currentStop.toLowerCase());
      final isNext = stopName.toLowerCase().contains(nextStop.toLowerCase());

      double nodeRadius = 6.0 * zoom;
      if (isCurrent) {
        nodeRadius = 9.0 * zoom;
        // Outer halo
        canvas.drawCircle(
          point,
          15.0 * zoom,
          Paint()..color = const Color(0x4416A34A),
        );
        canvas.drawCircle(point, nodeRadius, currentHighlightPaint);
      } else if (isNext) {
        nodeRadius = 8.0 * zoom;
        canvas.drawCircle(
          point,
          13.0 * zoom,
          Paint()..color = const Color(0x442563EB),
        );
        canvas.drawCircle(point, nodeRadius, Paint()..color = AppTheme.primaryBlue);
      } else {
        canvas.drawCircle(point, nodeRadius, nodePaint);
        canvas.drawCircle(point, nodeRadius, nodeBorderPaint);
      }

      // Stop Text Label
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: stopName,
          style: TextStyle(
            color: isCurrent
                ? const Color(0xFF4ADE80)
                : (isNext ? Colors.white : const Color(0xFF94A3B8)),
            fontSize: (10.0 * zoom).clamp(8.0, 14.0),
            fontWeight: isCurrent || isNext ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        point + Offset(-textPainter.width / 2, 12 * zoom),
      );
    }

    // Bus pulse ring at center
    final pulsePaint = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 28 * zoom, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.offset != offset ||
        oldDelegate.latitude != latitude ||
        oldDelegate.longitude != longitude ||
        oldDelegate.currentStop != currentStop ||
        oldDelegate.nextStop != nextStop;
  }
}
