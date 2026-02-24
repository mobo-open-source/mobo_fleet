class ModelFetchVehicleCategory {
  final int length;
  final List<VehicleCategoryItem> records;

  ModelFetchVehicleCategory({required this.length, required this.records});

  factory ModelFetchVehicleCategory.fromJson(Map<String, dynamic> json) {
    return ModelFetchVehicleCategory(
      length: json['length'] ?? 0,
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => VehicleCategoryItem.fromJson(e))
          .toList(),
    );
  }
}

class VehicleCategoryItem {
  final int id;
  final int sequence;
  final String name;

  VehicleCategoryItem({
    required this.id,
    required this.sequence,
    required this.name,
  });

  factory VehicleCategoryItem.fromJson(Map<String, dynamic> json) {
    return VehicleCategoryItem(
      id: json['id'] ?? 0,
      sequence: json['sequence'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}