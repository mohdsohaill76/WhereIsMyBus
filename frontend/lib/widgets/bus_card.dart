import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BusCard extends StatelessWidget {
  final String busNumber;
  final String route;
  final String status;
  final VoidCallback? onTrackPressed;

  const BusCard({
    super.key,
    required this.busNumber,
    required this.route,
    required this.status,
    this.onTrackPressed,
  });

  Widget _buildStatusBadge(String statusText) {
    final lower = statusText.toLowerCase();
    Color bg;
    Color textColor;
    Color dotColor;
    Color border;
    String label;

    if (lower == 'offline') {
      bg = AppTheme.statusOfflineBg;
      textColor = AppTheme.statusOfflineText;
      dotColor = AppTheme.statusOfflineDot;
      border = AppTheme.statusOfflineBorder;
      label = 'Offline';
    } else if (lower == 'stopped') {
      bg = AppTheme.statusStoppedBg;
      textColor = AppTheme.statusStoppedText;
      dotColor = AppTheme.statusStoppedDot;
      border = AppTheme.statusStoppedBorder;
      label = 'Stopped';
    } else {
      bg = AppTheme.statusLiveBg;
      textColor = AppTheme.statusLiveText;
      dotColor = AppTheme.statusLiveDot;
      border = AppTheme.statusLiveBorder;
      label = 'LIVE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeParts = route.split('→');
    final origin = routeParts.isNotEmpty ? routeParts[0].trim() : route;
    final destination = routeParts.length > 1 ? routeParts[1].trim() : '';

    final lowerStatus = status.toLowerCase();
    final isMoving = lowerStatus == 'moving' || lowerStatus == 'active' || lowerStatus == 'in_transit';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.cardDecoration(
        border: isMoving ? AppTheme.primaryBlue.withValues(alpha: 0.25) : AppTheme.borderColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Bus Number & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: isMoving
                              ? AppTheme.primaryBlue.withValues(alpha: 0.12)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          color: isMoving ? AppTheme.primaryBlue : AppTheme.textMuted,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              busNumber,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Public Transit',
                              style: TextStyle(
                                fontSize: 11,
                                color: isMoving ? AppTheme.primaryBlue : AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),

            // Route Visualization Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.bgSlate,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trip_origin_rounded,
                    size: 15,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      origin,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (destination.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Icon(
                        Icons.east_rounded,
                        size: 14,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Primary Action: Track Bus (48px height minimum for accessibility)
            Semantics(
              button: true,
              label: 'Track $busNumber',
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onTrackPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.near_me_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Track Bus',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
}
