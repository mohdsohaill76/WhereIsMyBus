import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/route_model.dart';
import '../widgets/bus_map.dart';
import '../widgets/live_status_dot.dart';
import 'bus_tracking_screen.dart';

class RouteDetailsScreen extends StatelessWidget {
  final RouteModel route;

  const RouteDetailsScreen({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final firstStop = route.stops.isNotEmpty ? route.stops.first.shortName : 'Start';
    final secondStop = route.stops.length > 1 ? route.stops[1].shortName : 'Next';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceLayer1,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Routes',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    route.id,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    route.name,
                    style: const TextStyle(
                      fontSize: 15,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppTheme.maxContentWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Route Map Overview
                const Text(
                  'Route Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 260,
                  width: double.infinity,
                  child: BusMapWidget(
                    latitude: route.stops.isNotEmpty ? route.stops.first.latitude : 17.9784,
                    longitude: route.stops.isNotEmpty ? route.stops.first.longitude : 79.5941,
                    busNumber: route.assignedBusIds.isNotEmpty ? route.assignedBusIds.first : 'BUS101',
                    currentStop: firstStop,
                    nextStop: secondStop,
                    stops: route.stops,
                    isOverviewMode: true,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Assigned Operating Buses Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Buses operating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.statusLiveBg,
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(color: AppTheme.statusLiveBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LiveStatusDot(size: 4, color: AppTheme.statusLive),
                          const SizedBox(width: 5),
                          Text(
                            '${route.assignedBusIds.length} Active',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.statusLive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (route.assignedBusIds.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.cardDecoration(background: AppTheme.surfaceLayer1),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.textTertiary),
                        SizedBox(width: 10),
                        Text(
                          'No buses currently operating on this route.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ...route.assignedBusIds.map((busId) {
                    final displayBusName = busId.toLowerCase().startsWith('bus')
                        ? busId
                        : 'Bus ${busId.replaceAll('BUS', '')}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.cardDecoration(
                        background: AppTheme.surfaceLayer1,
                        border: AppTheme.borderSubtle,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusLiveBg,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    border: Border.all(color: AppTheme.statusLiveBorder),
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus_rounded,
                                    color: AppTheme.statusLive,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            displayBusName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const LiveStatusDot(size: 4, color: AppTheme.statusLive),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'LIVE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.statusLive,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Next stop: $secondStop',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
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
                          Semantics(
                            button: true,
                            label: 'Track $displayBusName',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BusTrackingScreen(
                                        busNumber: busId,
                                        routeName: route.name,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.accentButtonGradient,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x333B82F6),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Track',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // 3. Ordered Route Stops Vertical Timeline
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(
                    background: AppTheme.surfaceLayer1,
                    border: AppTheme.borderMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Stops',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLayer2,
                              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: Text(
                              '${route.stops.length} Total Stops',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: route.stops.length,
                        itemBuilder: (context, index) {
                          final stop = route.stops[index];
                          final isFirst = index == 0;
                          final isLast = index == route.stops.length - 1;

                          Color dotColor;
                          if (isFirst) {
                            dotColor = AppTheme.statusLive;
                          } else if (isLast) {
                            dotColor = AppTheme.accentPurple;
                          } else {
                            dotColor = AppTheme.primaryBlueLight;
                          }

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline Node
                                SizedBox(
                                  width: 22,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(vertical: 2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: dotColor,
                                          border: Border.all(
                                            color: (isFirst || isLast) ? Colors.white : Colors.transparent,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: dotColor.withValues(alpha: 0.4),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isLast)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: AppTheme.borderSubtle,
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Stop Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              stop.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: (isFirst || isLast) ? FontWeight.w700 : FontWeight.w500,
                                                color: (isFirst || isLast) ? AppTheme.textPrimary : AppTheme.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              'Stop #${stop.sequence} • ${stop.id}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isFirst)
                                          const Text(
                                            'Origin',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.statusLive,
                                            ),
                                          )
                                        else if (isLast)
                                          const Text(
                                            'Destination',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
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
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
