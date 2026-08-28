import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Polymorphic Search Result Model representing buses, routes, and transit stops
class SearchResult {
  final String type; // 'bus' | 'route' | 'stop'
  final String id;
  final String title;
  final String subtitle;
  final Map<String, dynamic>? metadata;
  final double relevanceScore;

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.metadata,
    this.relevanceScore = 1.0,
  });

  bool get isBus => type == 'bus';
  bool get isRoute => type == 'route';
  bool get isStop => type == 'stop';

  String get typeLabel {
    switch (type) {
      case 'bus':
        return 'BUS';
      case 'route':
        return 'ROUTE';
      case 'stop':
        return 'STOP';
      default:
        return 'TRANSIT';
    }
  }

  IconData get icon {
    switch (type) {
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'route':
        return Icons.alt_route_rounded;
      case 'stop':
        return Icons.location_on_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  Color get accentColor {
    switch (type) {
      case 'bus':
        return AppTheme.primaryBlueLight;
      case 'route':
        return AppTheme.accentPurple;
      case 'stop':
        return AppTheme.accentCyan;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color get badgeBg {
    switch (type) {
      case 'bus':
        return AppTheme.primaryBlue.withValues(alpha: 0.15);
      case 'route':
        return AppTheme.accentPurple.withValues(alpha: 0.15);
      case 'stop':
        return AppTheme.accentCyan.withValues(alpha: 0.15);
      default:
        return AppTheme.surfaceLayer2;
    }
  }
}
