class ModelFleetVehicleTags {
  final int length;
  final List<FleetTagItem> records;

  ModelFleetVehicleTags({required this.length, required this.records});

  factory ModelFleetVehicleTags.fromJson(dynamic json) {
    if (json is List) {
      final records = json
          .map((e) => FleetTagItem.fromJson(e as Map<String, dynamic>?))
          .toList();

      return ModelFleetVehicleTags(length: records.length, records: records);
    }

    if (json is Map<String, dynamic>) {
      final records = (json['records'] as List<dynamic>? ?? [])
          .map((e) => FleetTagItem.fromJson(e as Map<String, dynamic>?))
          .toList();

      return ModelFleetVehicleTags(
        length: json['length'] ?? records.length,
        records: records,
      );
    }

    return ModelFleetVehicleTags(length: 0, records: []);
  }
}

class FleetTagItem {
  final int id;
  final String name;
  final int color;

  FleetTagItem({required this.id, required this.name, required this.color});

  factory FleetTagItem.fromJson(Map<String, dynamic>? json) {
    return FleetTagItem(
      id: json?['id'] ?? 0,
      name: json?['name'] ?? '',
      color: json?['color'] ?? 0,
    );
  }
}
