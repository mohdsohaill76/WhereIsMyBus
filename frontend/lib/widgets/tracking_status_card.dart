import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/live_location.dart';
import '../services/eta_calculator.dart';
import 'live_status_dot.dart';

/// Hero ETA and Live Status Telemetry Panel
class TrackingStatusCard extends StatelessWidget {
  final LiveLocation location;
  final double? nextStopLat;
  final double? nextStopLng;
  final VoidCallback? onRefresh;

  const TrackingStatusCard({
    super.key,
    required this.location,
    this.nextStopLat,
    this.nextStopLng,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isStale = location.isStale;
    final isMoving = location.status.toLowerCase() == 'moving' && !isStale;

    // Passenger ETA string to next stop
    final etaText = EtaCalculator.calculateEta(
      location: location,
      nextStopLat: nextStopLat,
      nextStopLng: nextStopLng,
    );

    return Container(
      decoration: AppTheme.cardDecoration(
        background: AppTheme.surfaceLayer2,
        border: isStale ? AppTheme.statusOfflineBorder : AppTheme.borderMedium,
        glowColor: isMoving ? AppTheme.primaryBlue : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stale Warning Alert Banner if telemetry > 30s
          if (isStale) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.statusOfflineBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
                border: Border(bottom: BorderSide(color: AppTheme.statusOfflineBorder)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.statusOffline, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Telemetry stale (>30s ago). Showing last known position.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.statusOffline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Status Badge & Updated Time + Refresh
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStale
                            ? AppTheme.statusOfflineBg
                            : (isMoving ? AppTheme.statusLiveBg : AppTheme.statusStoppedBg),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(
                          color: isStale
                              ? AppTheme.statusOfflineBorder
                              : (isMoving ? AppTheme.statusLiveBorder : AppTheme.statusStoppedBorder),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isMoving)
                            const LiveStatusDot(size: 5, color: AppTheme.statusLive)
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
                            isStale
                                ? 'STALE'
                                : (isMoving ? 'LIVE' : location.status.toUpperCase()),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isStale
                                  ? AppTheme.statusOffline
                                  : (isMoving ? AppTheme.statusLive : AppTheme.statusStopped),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Updated Time & Refresh Button
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Updated ${location.formattedTime}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (onRefresh != null) ...[
                          const SizedBox(width: 6),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onRefresh,
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLayer3,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.borderSubtle),
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 14,
                                  color: AppTheme.primaryBlueLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Dominant ETA Hero Section ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.etaHeroGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(
                      color: isMoving ? AppTheme.borderAccent : AppTheme.borderSubtle,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ARRIVING IN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlueLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        etaText,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -1.2,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            'to ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              location.nextStop.isNotEmpty
                                  ? location.nextStop
                                  : 'Next stop',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Divider
                const Divider(color: AppTheme.borderSubtle, height: 1),
                const SizedBox(height: 14),

                // Secondary Metrics Row: Speed & Current Stop
                Row(
                  children: [
                    // Speed Metric
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLayer1,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: const Icon(Icons.speed_rounded, color: AppTheme.primaryBlueLight, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.formattedSpeed,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Speed',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textTertiary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Current Stop Metric
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLayer1,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.statusLiveBg,
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: const Icon(Icons.location_on_rounded, color: AppTheme.statusLive, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.currentStop.isNotEmpty ? location.currentStop : 'In transit',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Current Stop',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textTertiary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
