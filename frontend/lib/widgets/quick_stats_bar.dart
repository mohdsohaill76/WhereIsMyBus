import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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

  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color bgTint,
    required bool compact,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: compact ? 6 : 10),
        decoration: AppTheme.cardDecoration(radius: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 6 : 8),
              decoration: BoxDecoration(
                color: bgTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: compact ? 16 : 18, color: iconColor),
            ),
            SizedBox(width: compact ? 6 : 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: compact ? 10 : 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        return Row(
          children: [
            _buildStatTile(
              icon: Icons.directions_bus_rounded,
              value: '$totalBuses',
              label: 'Buses',
              iconColor: AppTheme.primaryBlue,
              bgTint: AppTheme.primaryBlue.withValues(alpha: 0.1),
              compact: isCompact,
            ),
            SizedBox(width: isCompact ? 6 : 8),
            _buildStatTile(
              icon: Icons.sensors_rounded,
              value: '$liveBuses',
              label: 'Live Now',
              iconColor: const Color(0xFF16A34A),
              bgTint: AppTheme.statusLiveBg,
              compact: isCompact,
            ),
            SizedBox(width: isCompact ? 6 : 8),
            _buildStatTile(
              icon: Icons.alt_route_rounded,
              value: '$activeRoutes',
              label: 'Routes',
              iconColor: AppTheme.accentPurple,
              bgTint: const Color(0xFFF3E8FF),
              compact: isCompact,
            ),
          ],
        );
      },
    );
  }
}
