import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/route_model.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onViewRoutePressed;

  const RouteCard({
    super.key,
    required this.route,
    required this.onViewRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    final routeParts = route.name.split('→');
    final origin = routeParts.isNotEmpty ? routeParts[0].trim() : route.name;
    final destination = routeParts.length > 1 ? routeParts[1].trim() : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Route ID Badge & Stops Count Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.alt_route_rounded,
                          color: AppTheme.accentPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.id,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'Transit Line',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.accentPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pin_drop_rounded, size: 14, color: AppTheme.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        '${route.stopCount} Stops',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
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
            const SizedBox(height: 10),

            Text(
              route.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            // CTA Button: View Route (48px height for accessibility)
            Semantics(
              button: true,
              label: 'View Route ${route.id}',
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onViewRoutePressed,
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
                      Text(
                        'View Route',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18),
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
