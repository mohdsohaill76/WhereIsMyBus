import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'live_status_dot.dart';

class BusCard extends StatefulWidget {
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

  @override
  State<BusCard> createState() => _BusCardState();
}

class _BusCardState extends State<BusCard> {
  bool _isHovered = false;

  Widget _buildStatusBadge(String statusText) {
    final lower = statusText.toLowerCase();
    final isLive = lower == 'moving' || lower == 'active' || lower == 'in_transit' || lower == 'live';
    final isStopped = lower == 'stopped' || lower == 'waiting';

    Color bg;
    Color textColor;
    Color border;
    Color dotColor;
    String label;

    if (isLive) {
      bg = AppTheme.statusLiveBg;
      textColor = AppTheme.statusLive;
      border = AppTheme.statusLiveBorder;
      dotColor = AppTheme.statusLive;
      label = 'LIVE';
    } else if (isStopped) {
      bg = AppTheme.statusStoppedBg;
      textColor = AppTheme.statusStopped;
      border = AppTheme.statusStoppedBorder;
      dotColor = AppTheme.statusStopped;
      label = 'STOPPED';
    } else {
      bg = AppTheme.statusOfflineBg;
      textColor = AppTheme.statusOffline;
      border = AppTheme.statusOfflineBorder;
      dotColor = AppTheme.statusOffline;
      label = lower == 'stale' ? 'STALE' : 'OFFLINE';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            LiveStatusDot(size: 5, color: dotColor)
          else
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeParts = widget.route.split('→');
    final origin = routeParts.isNotEmpty ? routeParts[0].trim() : widget.route;
    final destination = routeParts.length > 1 ? routeParts[1].trim() : '';

    final lowerStatus = widget.status.toLowerCase();
    final isMoving = lowerStatus == 'moving' || lowerStatus == 'active' || lowerStatus == 'in_transit' || lowerStatus == 'live';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration(
          background: _isHovered ? AppTheme.surfaceLayer2 : AppTheme.surfaceLayer1,
          border: _isHovered
              ? (isMoving ? AppTheme.primaryBlue : AppTheme.borderLight)
              : (isMoving ? AppTheme.borderAccent : AppTheme.borderSubtle),
          glowColor: _isHovered ? (isMoving ? AppTheme.primaryBlue : null) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Bus ID + Live Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isMoving
                              ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                              : AppTheme.surfaceLayer2,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: isMoving
                                ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                                : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          Icons.directions_bus_rounded,
                          color: isMoving ? AppTheme.primaryBlueLight : AppTheme.textSecondary,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.busNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(widget.status),
                ],
              ),
              const SizedBox(height: 12),

              // Route Line: Origin → Destination
              Row(
                children: [
                  Text(
                    origin,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (destination.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        Icons.east_rounded,
                        size: 13,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              const Divider(color: AppTheme.borderSubtle, height: 1),
              const SizedBox(height: 12),

              // Bottom Info: Next Stop Preview & Track Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Next Stop Preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next stop',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textTertiary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          destination.isNotEmpty ? destination : origin,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Track -> Button
                  Semantics(
                    button: true,
                    label: 'Track ${widget.busNumber}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTrackPressed,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: _isHovered ? AppTheme.accentButtonGradient : null,
                            color: _isHovered ? null : AppTheme.surfaceLayer3,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(
                              color: _isHovered ? AppTheme.primaryBlueLight : AppTheme.borderMedium,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Track',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _isHovered ? Colors.white : AppTheme.primaryBlueLight,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: _isHovered ? Colors.white : AppTheme.primaryBlueLight,
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
