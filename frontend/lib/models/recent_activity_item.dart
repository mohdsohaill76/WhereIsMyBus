import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Data model for persistent Passenger Recent Activity
class RecentActivityItem {
  final String type; // 'bus' | 'route' | 'stop'
  final String id;
  final String title;
  final String subtitle;
  final int viewedAt;

  const RecentActivityItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.viewedAt,
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
        return 'RECENT';
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
        return Icons.history_rounded;
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

  String get formattedTime {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffMillis = now - viewedAt;
    final diffSec = (diffMillis / 1000).round();

    if (diffSec < 10) return 'Just now';
    if (diffSec < 60) return '${diffSec}s ago';

    final diffMin = (diffSec / 60).round();
    if (diffMin < 60) return '${diffMin}m ago';

    final diffHours = (diffMin / 60).round();
    if (diffHours < 24) return '${diffHours}h ago';

    final diffDays = (diffHours / 24).round();
    if (diffDays == 1) return 'Yesterday';
    return '${diffDays}d ago';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'viewedAt': viewedAt,
    };
  }

  factory RecentActivityItem.fromJson(Map<String, dynamic> json) {
    return RecentActivityItem(
      type: json['type']?.toString() ?? 'bus',
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Recent Item',
      subtitle: json['subtitle']?.toString() ?? '',
      viewedAt: (json['viewedAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentActivityItem && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}
