class StopModel {
  final String id;
  final String name;
  final String shortName;
  final double latitude;
  final double longitude;
  final int sequence;

  const StopModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.latitude,
    required this.longitude,
    required this.sequence,
  });

  factory StopModel.fromJson(dynamic keyOrJson, [dynamic jsonObj, int defaultSeq = 1]) {
    String key = '';
    Map<String, dynamic> json = {};

    if (jsonObj is Map<String, dynamic>) {
      key = keyOrJson.toString();
      json = jsonObj;
    } else if (keyOrJson is Map<String, dynamic>) {
      json = keyOrJson;
      key = json['id'] ?? json['stopId'] ?? '';
    }

    final idStr = key.isNotEmpty ? key : (json['id'] ?? 'STOP001');
    final nameStr = json['name'] ?? json['stopName'] ?? 'Bus Stop';

    return StopModel(
      id: idStr,
      name: nameStr,
      shortName: json['shortName'] ?? nameStr.split(' ').first,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 17.9784,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.5941,
      sequence: (json['sequence'] as num?)?.toInt() ?? defaultSeq,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
    };
  }
}
