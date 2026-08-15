class BusModel {
  final String id;
  final String busNumber;
  final String routeId;
  final String status;
  final String routeName;

  const BusModel({
    required this.id,
    required this.busNumber,
    required this.routeId,
    required this.status,
    required this.routeName,
  });

  factory BusModel.fromJson(String key, Map<String, dynamic> json, {String defaultRouteName = ''}) {
    final rawNum = json['busNumber'] ?? json['number'] ?? key;
    final formattedNum = rawNum.toString().toLowerCase().startsWith('bus')
        ? rawNum.toString()
        : 'Bus $rawNum';

    final route = json['routeName'] ?? json['route'] ?? defaultRouteName;

    return BusModel(
      id: key.isNotEmpty ? key : (json['id'] ?? 'BUS101'),
      busNumber: formattedNum,
      routeId: json['routeId'] ?? json['route'] ?? 'WGL01',
      status: (json['status'] ?? 'offline').toString(),
      routeName: route.isNotEmpty ? route : 'Warangal → Kazipet',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'routeId': routeId,
      'status': status,
      'routeName': routeName,
    };
  }
}
