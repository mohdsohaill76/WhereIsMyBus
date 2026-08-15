class LiveLocation {
  final String busId;
  final String tripId;
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final int timestamp;
  final String currentStop;
  final String nextStop;
  final String status;

  LiveLocation({
    required this.busId,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.currentStop,
    required this.nextStop,
    required this.status,
  });

  factory LiveLocation.fromJson(Map<String, dynamic> json) {
    return LiveLocation(
      busId: json['busId'] ?? 'BUS101',
      tripId: json['tripId'] ?? 'TRIP001',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 17.9784,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.5941,
      speed: (json['speed'] as num?)?.toDouble() ?? 35.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 180.0,
      timestamp: json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      currentStop: json['currentStop'] ?? 'Hanamkonda',
      nextStop: json['nextStop'] ?? 'Subedari',
      status: json['status'] ?? 'moving',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busId': busId,
      'tripId': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp,
      'currentStop': currentStop,
      'nextStop': nextStop,
      'status': status,
    };
  }

  // Contract requirement: If current time - timestamp > 30 seconds, data is stale
  bool get isStale {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) > 30000;
  }

  String get formattedSpeed => '${speed.toStringAsFixed(0)} km/h';

  String get formattedTime {
    final now = DateTime.now().millisecondsSinceEpoch;
    final diffSeconds = ((now - timestamp) / 1000).round();
    if (diffSeconds < 5) return 'Just now';
    if (diffSeconds < 60) return '$diffSeconds sec ago';
    final diffMins = (diffSeconds / 60).round();
    return '$diffMins min${diffMins > 1 ? 's' : ''} ago';
  }
}
