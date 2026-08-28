import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'live_status_dot.dart';

/// Premium Dashboard Metrics Widget with Hero Numbers
class QuickStatsBar extends StatelessWidget {
  final int totalBuses;
  final int liveBuses;
  final int activeRoutes;

  const QuickStatsBar({
    super.key,
    required this.totalBuses,
    required this.liveBuses,
    required this.activeRoutes,
  });

  Widget _buildMetricCard({
    required String value,
    required String label,
    required IconData icon,
    required Color accentColor,
    bool isLive = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLayer1,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderSubtle, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isLive)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LiveStatusDot(size: 6, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  )
                else
                  Icon(icon, size: 14, color: AppTheme.textTertiary),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLive ? accentColor : AppTheme.borderLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value.padLeft(2, '0'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isLive ? AppTheme.textPrimary : AppTheme.textPrimary,
                letterSpacing: -0.8,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                letterSpacing: -0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildMetricCard(
          value: '$liveBuses',
          label: 'Live buses',
          icon: Icons.sensors_rounded,
          accentColor: AppTheme.statusLive,
          isLive: true,
        ),
        const SizedBox(width: 10),
        _buildMetricCard(
          value: '$totalBuses',
          label: 'Total buses',
          icon: Icons.directions_bus_rounded,
          accentColor: AppTheme.primaryBlueLight,
        ),
        const SizedBox(width: 10),
        _buildMetricCard(
          value: '$activeRoutes',
          label: 'Routes',
          icon: Icons.alt_route_rounded,
          accentColor: AppTheme.accentPurple,
        ),
      ],
    );
  }
}
