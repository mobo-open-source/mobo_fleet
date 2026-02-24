class ModelVehicleModelList {
  ModelVehicleModelList({required this.length, required this.records});

  final num length;
  final List<Record> records;

  factory ModelVehicleModelList.fromJson(Map<String, dynamic> json) {
    return ModelVehicleModelList(
      length: json["length"] ?? 0,
      records: json["records"] == null
          ? []
          : List<Record>.from(json["records"]!.map((x) => Record.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "length": length,
    "records": records.map((x) => x?.toJson()).toList(),
  };
}

class Record {
  Record({
    required this.id,
    required this.brand,
    required this.name,
    required this.vehicleCount,
    required this.vehicleType,
    required this.defaultCo2,
  });

  final int id;
  final Brand? brand;
  final String name;
  final num vehicleCount;
  final String vehicleType;
  final num defaultCo2;

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json["id"] ?? 0,
      brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
      name: json["name"] ?? "",
      vehicleCount: json["vehicle_count"] ?? 0,
      vehicleType: json["vehicle_type"] ?? "",
      defaultCo2: json["default_co2"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand": brand?.toJson(),
    "name": name,
    "vehicle_count": vehicleCount,
    "vehicle_type": vehicleType,
    "default_co2": defaultCo2,
  };
}

class Brand {
  Brand({required this.id, required this.name});

  final int id;
  final String name;

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(id: json["id"] ?? 0, name: json["name"] ?? "");
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
