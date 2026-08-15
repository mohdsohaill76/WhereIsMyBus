import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/live_location.dart';
import '../services/eta_calculator.dart';

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

    // Calculate passenger-friendly ETA to next stop
    final etaText = EtaCalculator.calculateEta(
      location: location,
      nextStopLat: nextStopLat,
      nextStopLng: nextStopLng,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(
        border: isStale ? const Color(0xFFFCA5A5) : AppTheme.borderColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stale Warning Banner if >30s
          if (isStale) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Location stale (>30s ago). Showing last known location.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF991B1B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Top Header: Live Badge & Timestamp / Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isStale
                        ? AppTheme.statusOfflineBg
                        : (isMoving ? AppTheme.statusLiveBg : AppTheme.statusStoppedBg),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isStale
                          ? AppTheme.statusOfflineBorder
                          : (isMoving ? AppTheme.statusLiveBorder : AppTheme.statusStoppedBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isStale
                              ? AppTheme.statusOfflineDot
                              : (isMoving ? AppTheme.statusLiveDot : AppTheme.statusStoppedDot),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isStale
                              ? 'STALE'
                              : (isMoving ? 'LIVE • MOVING' : location.status.toUpperCase()),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isStale
                                ? AppTheme.statusOfflineText
                                : (isMoving ? AppTheme.statusLiveText : AppTheme.statusStoppedText),
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Updated Time & Refresh Button
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${location.formattedTime}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  if (onRefresh != null) ...[
                    const SizedBox(width: 6),
                    Semantics(
                      button: true,
                      label: 'Refresh live location',
                      child: InkWell(
                        onTap: onRefresh,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            size: 16,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Prominent Passenger ETA Hero Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x292563EB),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.timer_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ESTIMATED ARRIVAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E40AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        etaText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Next Stop: ${location.nextStop}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E40AF),
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
          const SizedBox(height: 12),

          // Speed & Current Stop Row
          Row(
            children: [
              // Speed
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSlate,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: AppTheme.primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.formattedSpeed,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Speed',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Current Stop
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSlate,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.currentStop,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Current Stop',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
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
    );
  }
}
