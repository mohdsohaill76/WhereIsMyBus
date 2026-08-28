import 'package:flutter/material.dart';
import '../models/stop_model.dart';
import '../theme/app_theme.dart';
import 'live_status_dot.dart';

/// Premium Transit Progress Timeline
class RouteProgressCard extends StatelessWidget {
  final String currentStop;
  final String nextStop;
  final List<dynamic> stops;
  final String? routeName;

  const RouteProgressCard({
    super.key,
    required this.currentStop,
    required this.nextStop,
    required this.stops,
    this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(
        background: AppTheme.surfaceLayer2,
        border: AppTheme.borderMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: Title & Route Name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              if (routeName != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLayer1,
                      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Text(
                      routeName!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlueLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Current & Next Stop Callout Boxes
          Row(
            children: [
              // CURRENT STOP
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.statusLiveBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.statusLiveBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          LiveStatusDot(size: 4, color: AppTheme.statusLive),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'CURRENT STOP',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.statusLive,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStop.isNotEmpty ? currentStop : 'In transit',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // NEXT STOP
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLayer1,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.borderAccent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.near_me_rounded, size: 11, color: AppTheme.primaryBlueLight),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'NEXT STOP',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBlueLight,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextStop.isNotEmpty ? nextStop : 'Approaching',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          const Text(
            'Timeline Stops',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Custom Bespoke Vertical Timeline
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final item = stops[index];
              final String stopName = item is StopModel ? item.name : (item['name']?.toString() ?? 'Stop');
              final String shortName = item is StopModel ? item.shortName : (item['shortName']?.toString() ?? stopName);
              final String stopId = item is StopModel ? item.id : (item['id']?.toString() ?? 'STOP');

              final isCurrent = shortName.toLowerCase() == currentStop.toLowerCase() ||
                  stopId.toLowerCase() == currentStop.toLowerCase() ||
                  stopName.toLowerCase() == currentStop.toLowerCase();
              final isNext = shortName.toLowerCase() == nextStop.toLowerCase() ||
                  stopId.toLowerCase() == nextStop.toLowerCase() ||
                  stopName.toLowerCase() == nextStop.toLowerCase();
              final isOrigin = index == 0;
              final isDestination = index == stops.length - 1;

              Color nodeColor;
              Color lineColor;

              if (isCurrent) {
                nodeColor = AppTheme.statusLive;
                lineColor = AppTheme.primaryBlue;
              } else if (isNext) {
                nodeColor = AppTheme.primaryBlueLight;
                lineColor = AppTheme.borderSubtle;
              } else if (isOrigin) {
                nodeColor = AppTheme.primaryBlue;
                lineColor = AppTheme.borderSubtle;
              } else if (isDestination) {
                nodeColor = AppTheme.accentPurple;
                lineColor = AppTheme.borderSubtle;
              } else {
                nodeColor = AppTheme.borderLight;
                lineColor = AppTheme.borderSubtle;
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Line & Node Dot
                    SizedBox(
                      width: 22,
                      child: Column(
                        children: [
                          if (isCurrent)
                            const LiveStatusDot(size: 8, color: AppTheme.statusLive)
                          else
                            Container(
                              width: (isNext || isOrigin || isDestination) ? 10 : 8,
                              height: (isNext || isOrigin || isDestination) ? 10 : 8,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: nodeColor,
                                border: Border.all(
                                  color: isNext ? AppTheme.primaryBlueGlow : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          if (!isDestination)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: lineColor,
                                margin: const EdgeInsets.symmetric(vertical: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Stop Detail Text & Badges
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stopName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isCurrent || isNext || isOrigin || isDestination
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isCurrent
                                          ? AppTheme.statusLive
                                          : (isNext ? AppTheme.primaryBlueLight : AppTheme.textPrimary),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Stop #${index + 1} • $stopId',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.statusLiveBg,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                  border: Border.all(color: AppTheme.statusLiveBorder),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.statusLive,
                                  ),
                                ),
                              )
                            else if (isNext)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLayer3,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                                  border: Border.all(color: AppTheme.borderAccent),
                                ),
                                child: const Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBlueLight,
                                  ),
                                ),
                              )
                            else if (isOrigin)
                              const Text(
                                'Origin',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textTertiary,
                                ),
                              )
                            else if (isDestination)
                              const Text(
                                'Destination',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentPurple,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
