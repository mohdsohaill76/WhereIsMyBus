import 'stop_model.dart';

class RouteModel {
  final String id;
  final String name;
  final String description;
  final List<StopModel> stops;
  final List<String> assignedBusIds;

  const RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.stops,
    required this.assignedBusIds,
  });

  factory RouteModel.fromJson(dynamic keyOrJson, [dynamic jsonObj, Map<String, StopModel>? stopsLookup]) {
    String key = '';
    Map<String, dynamic> json = {};

    if (jsonObj is Map<String, dynamic>) {
      key = keyOrJson.toString();
      json = jsonObj;
    } else if (keyOrJson is Map<String, dynamic>) {
      json = keyOrJson;
      key = json['id'] ?? json['routeId'] ?? '';
    }

    final routeId = key.isNotEmpty ? key : (json['id'] ?? 'WGL01');
    final routeName = json['name'] ?? json['routeName'] ?? 'Warangal → Kazipet';

    List<StopModel> routeStops = [];

    // Check if stopIds array exists (e.g., ["STOP001", "STOP002", "STOP003"])
    if (json['stopIds'] != null && json['stopIds'] is List) {
      final stopIds = List<String>.from(json['stopIds']);
      for (int i = 0; i < stopIds.length; i++) {
        final sid = stopIds[i];
        if (stopsLookup != null && stopsLookup.containsKey(sid)) {
          routeStops.add(stopsLookup[sid]!);
        } else {
          routeStops.add(StopModel(
            id: sid,
            name: sid == 'STOP001'
                ? 'Hanamkonda'
                : (sid == 'STOP002' ? 'Subedari' : (sid == 'STOP003' ? 'NIT Warangal' : sid)),
            shortName: sid,
            latitude: sid == 'STOP001' ? 17.9784 : (sid == 'STOP002' ? 17.9870 : 17.9826),
            longitude: sid == 'STOP001' ? 79.5941 : (sid == 'STOP002' ? 79.5890 : 79.5307),
            sequence: i + 1,
          ));
        }
      }
    } else if (json['stops'] != null && json['stops'] is List) {
      routeStops = (json['stops'] as List)
          .asMap()
          .entries
          .map((e) => StopModel.fromJson(e.value, null, e.key + 1))
          .toList();
    }

    List<String> buses = [];
    if (json['assignedBusIds'] != null && json['assignedBusIds'] is List) {
      buses = List<String>.from(json['assignedBusIds']);
    } else if (json['buses'] != null && json['buses'] is List) {
      buses = List<String>.from(json['buses']);
    } else {
      buses = ['BUS101'];
    }

    return RouteModel(
      id: routeId,
      name: routeName,
      description: json['description'] ?? 'Warangal Corridor Express via Hanamkonda',
      stops: routeStops,
      assignedBusIds: buses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'stops': stops.map((s) => s.toJson()).toList(),
      'assignedBusIds': assignedBusIds,
    };
  }

  int get stopCount => stops.length;
}
