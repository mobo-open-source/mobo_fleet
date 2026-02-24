class ModelActivityContractLog {
  final int length;
  final List<VehicleContractItem> records;

  const ModelActivityContractLog({required this.length, required this.records});

  factory ModelActivityContractLog.fromJson(List<dynamic> json) {
    return ModelActivityContractLog(
      length: json.length,
      records: json
          .map((e) => VehicleContractItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VehicleContractItem {
  final int id;
  final bool active;
  final bool expiresToday;
  final String name;
  final String startDate;
  final String expirationDate;
  final int daysLeft;
  final ListConvert vehicle;
  final ListConvert insurer;
  final ListConvert purchaser;
  final ListConvert purchaserEmployee;
  final double costGenerated;
  final String costFrequency;
  final String state;
  final bool hasOpenContract;

  const VehicleContractItem({
    required this.id,
    required this.active,
    required this.expiresToday,
    required this.name,
    required this.startDate,
    required this.expirationDate,
    required this.daysLeft,
    required this.vehicle,
    required this.insurer,
    required this.purchaser,
    required this.purchaserEmployee,
    required this.costGenerated,
    required this.costFrequency,
    required this.state,
    required this.hasOpenContract,
  });

  factory VehicleContractItem.fromJson(Map<String, dynamic> json) {
    return VehicleContractItem(
      id: json['id'] ?? 0,
      active: json['active'] ?? false,
      expiresToday: json['expires_today'] ?? false,
      name: json['name']?.toString() ?? "-",
      startDate: json['start_date']?.toString() ?? "-",
      expirationDate: json['expiration_date']?.toString() ?? "-",
      daysLeft: json['days_left'] ?? 0,
      vehicle: ListConvert.fromJson(json['vehicle_id']),
      insurer: ListConvert.fromJson(json['insurer_id']),
      purchaser: ListConvert.fromJson(json['purchaser_id']),
      purchaserEmployee: ListConvert.fromJson(json['purchaser_employee_id']),
      costGenerated: (json['cost_generated'] as num?)?.toDouble() ?? 0.0,
      costFrequency: json['cost_frequency']?.toString() ?? "-",
      state: json['state']?.toString() ?? "-",
      hasOpenContract: json['has_open_contract'] ?? false,
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
        name: json.length > 1 ? json[1].toString() : "-",
      );
    }

    if (json is Map<String, dynamic>) {
      return ListConvert(
        id: json['id'] as int?,
        name: json['display_name']?.toString() ?? "-",
      );
    }

    return const ListConvert(id: null, name: "-");
  }
}
