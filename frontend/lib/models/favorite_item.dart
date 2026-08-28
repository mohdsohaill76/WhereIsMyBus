import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Data model for persistent Passenger Favorites (buses, routes, stops)
class FavoriteItem {
  final String type; // 'bus' | 'route' | 'stop'
  final String id;
  final String title;
  final String subtitle;
  final int savedAt;

  const FavoriteItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.savedAt,
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
        return 'SAVED';
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
        return Icons.bookmark_rounded;
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
        return AppTheme.textPrimary;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'savedAt': savedAt,
    };
  }

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      type: json['type']?.toString() ?? 'bus',
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Saved Item',
      subtitle: json['subtitle']?.toString() ?? '',
      savedAt: (json['savedAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteItem && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}
