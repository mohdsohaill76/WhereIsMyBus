import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/route_model.dart';
import 'live_status_dot.dart';

class RouteCard extends StatefulWidget {
  final RouteModel route;
  final VoidCallback onViewRoutePressed;

  const RouteCard({
    super.key,
    required this.route,
    required this.onViewRoutePressed,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final routeParts = widget.route.name.split('→');
    final origin = routeParts.isNotEmpty ? routeParts[0].trim() : widget.route.name;
    final destination = routeParts.length > 1 ? routeParts[1].trim() : '';
    final liveBusCount = widget.route.assignedBusIds.length;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration(
          background: _isHovered ? AppTheme.surfaceLayer2 : AppTheme.surfaceLayer1,
          border: _isHovered ? AppTheme.accentPurple : AppTheme.borderSubtle,
          glowColor: _isHovered ? AppTheme.accentPurple : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Route Code & Live Buses Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: AppTheme.accentPurple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          widget.route.id,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentPurple,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.route.stopCount} stops',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (liveBusCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.statusLiveBg,
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(color: AppTheme.statusLiveBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LiveStatusDot(size: 4, color: AppTheme.statusLive),
                          const SizedBox(width: 4),
                          Text(
                            '$liveBusCount ${liveBusCount == 1 ? 'bus' : 'buses'} live',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.statusLive,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Route Title: Origin → Destination
              Row(
                children: [
                  Text(
                    origin,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destination.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.east_rounded,
                        size: 14,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              if (widget.route.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.route.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 14),

              // Divider
              const Divider(color: AppTheme.borderSubtle, height: 1),
              const SizedBox(height: 12),

              // Action Row: View Route ->
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.alt_route_rounded, size: 14, color: AppTheme.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        'Transit corridor',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Semantics(
                    button: true,
                    label: 'View route ${widget.route.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onViewRoutePressed,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: _isHovered ? AppTheme.accentPurple : AppTheme.surfaceLayer3,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: _isHovered ? AppTheme.accentPurple : AppTheme.borderMedium,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View route',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _isHovered ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: _isHovered ? Colors.white : AppTheme.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
