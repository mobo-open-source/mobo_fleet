class ModelActivityOdometerLog {
  final List<OdometerLogItem> records;

  const ModelActivityOdometerLog({required this.records});

  factory ModelActivityOdometerLog.fromJson(List<dynamic> json) {
    return ModelActivityOdometerLog(
      records: json
          .map((e) => OdometerLogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OdometerLogItem {
  final int id;
  final String date;
  final ListConvert vehicle;
  final ListConvert driver;
  final ListConvert driverEmployee;
  final double value;
  final String unit;

  const OdometerLogItem({
    required this.id,
    required this.date,
    required this.vehicle,
    required this.driver,
    required this.driverEmployee,
    required this.value,
    required this.unit,
  });

  factory OdometerLogItem.fromJson(Map<String, dynamic> json) {
    return OdometerLogItem(
      id: json['id'] is int ? json['id'] : 0,
      date: json['date']?.toString() ?? "-",
      vehicle: ListConvert.fromJson(json['vehicle_id']),
      driver: ListConvert.fromJson(json['driver_id']),
      driverEmployee: ListConvert.fromJson(json['driver_employee_id']),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? "-",
    );
  }
}

class ListConvert {
  final int? id;
  final String name;

  const ListConvert({this.id, required this.name});

  factory ListConvert.fromJson(dynamic json) {
    if (json == null || json == false) {
      return const ListConvert(id: null, name: "-");
    }

    if (json is List && json.isNotEmpty) {
      return ListConvert(
        id: json[0] is int ? json[0] : null,
        name: json.length > 1 && json[1] != null ? json[1].toString() : "-",
      );
    }

    return const ListConvert(id: null, name: "-");
  }
}
