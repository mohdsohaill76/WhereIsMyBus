import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RouteProgressCard extends StatelessWidget {
  final String currentStop;
  final String nextStop;
  final List<Map<String, String>> stops;

  const RouteProgressCard({
    super.key,
    required this.currentStop,
    required this.nextStop,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route Progress',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Route WGL01',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current Stop / Next Stop Highlight Cards
          Row(
            children: [
              // CURRENT STOP (Green Theme)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF16A34A)),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'CURRENT STOP',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF166534),
                                letterSpacing: 0.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStop,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14532D),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // NEXT STOP (Blue Theme)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.near_me_rounded, size: 13, color: AppTheme.primaryBlue),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'NEXT STOP',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E40AF),
                                letterSpacing: 0.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextStop,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A8A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Ordered Stops Timeline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),

          // Timeline Stop List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              final stopName = stop['name']!;
              final shortName = stop['shortName'] ?? stopName;
              final isCurrent = shortName.toLowerCase() == currentStop.toLowerCase();
              final isNext = shortName.toLowerCase() == nextStop.toLowerCase();
              final isOrigin = index == 0;
              final isDestination = index == stops.length - 1;

              Color dotColor;
              Color lineColor;
              if (isCurrent) {
                dotColor = const Color(0xFF16A34A);
                lineColor = AppTheme.primaryBlue;
              } else if (isNext) {
                dotColor = AppTheme.primaryBlue;
                lineColor = const Color(0xFFCBD5E1);
              } else if (isOrigin) {
                dotColor = const Color(0xFF0F172A);
                lineColor = AppTheme.primaryBlue;
              } else if (isDestination) {
                dotColor = const Color(0xFFDC2626);
                lineColor = const Color(0xFFCBD5E1);
              } else {
                dotColor = const Color(0xFF94A3B8);
                lineColor = const Color(0xFFCBD5E1);
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Line & Node Dot
                    SizedBox(
                      width: 20,
                      child: Column(
                        children: [
                          Container(
                            width: (isCurrent || isNext) ? 12 : 9,
                            height: (isCurrent || isNext) ? 12 : 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                              border: Border.all(
                                color: (isCurrent || isNext) ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          if (!isDestination)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: lineColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

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
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      color: isCurrent
                                          ? const Color(0xFF15803D)
                                          : (isNext ? AppTheme.primaryBlue : AppTheme.textDark),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    stop['id']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'At Stop',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              )
                            else if (isNext)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Next Stop',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            else if (isOrigin)
                              const Text(
                                'Origin',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              )
                            else if (isDestination)
                              const Text(
                                'Destination',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC2626),
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
