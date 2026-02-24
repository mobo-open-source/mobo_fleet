class ModelVehicleList {
  final int length;
  final List<VehicleItem> records;

  const ModelVehicleList({required this.length, required this.records});

  factory ModelVehicleList.fromJson(List<dynamic> json) {
    return ModelVehicleList(
      length: json.length,
      records: json
          .map((e) => VehicleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
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
        id: json[0] is int ? json[0] as int : null,
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

class VehicleItem {
  int id;
  final bool active;
  final String licensePlate;
  final String vehicleType;
  final ListConvert model;
  final ListConvert category;
  final ListConvert manager;
  final ListConvert driver;
  final ListConvert driverEmployee;
  final ListConvert futureDriver;
  final ListConvert futureDriverEmployee;
  final List<int> logDrivers;
  final double co2;
  final String acquisitionDate;
  final List<ListConvert> tags;
  final ListConvert state;
  final bool contractRenewalDueSoon;
  final bool contractRenewalOverdue;
  final String contractState;
  final ListConvert company;

  VehicleItem({
    required this.id,
    required this.active,
    required this.licensePlate,
    required this.vehicleType,
    required this.model,
    required this.category,
    required this.manager,
    required this.driver,
    required this.driverEmployee,
    required this.futureDriver,
    required this.futureDriverEmployee,
    required this.logDrivers,
    required this.co2,
    required this.acquisitionDate,
    required this.tags,
    required this.state,
    required this.contractRenewalDueSoon,
    required this.contractRenewalOverdue,
    required this.contractState,
    required this.company,
  });

  factory VehicleItem.fromJson(Map<String, dynamic> json) {
    return VehicleItem(
      id: json['id'] ?? 0,
      active: json['active'] ?? false,
      licensePlate:
          (json['license_plate'] == null || json['license_plate'] == false)
          ? "No plate"
          : json['license_plate']?.toString() ?? "-",
      vehicleType:
          (json['vehicle_type'] == null || json['vehicle_type'] == false)
          ? ""
          : json['vehicle_type'].toString().toLowerCase(),
      model: ListConvert.fromJson(json['model_id']),
      category: ListConvert.fromJson(json['category_id']),
      manager: ListConvert.fromJson(json['manager_id']),
      driver: ListConvert.fromJson(json['driver_id']),
      driverEmployee: ListConvert.fromJson(json['driver_employee_id']),
      futureDriver: ListConvert.fromJson(json['future_driver_id']),
      futureDriverEmployee: ListConvert.fromJson(
        json['future_driver_employee_id'],
      ),

      logDrivers: (json['log_drivers'] as List<dynamic>? ?? [])
          .whereType<int>()
          .toList(),

      co2: (json['co2'] as num?)?.toDouble() ?? 0.0,

      acquisitionDate:
          json['acquisition_date'] == null || json['acquisition_date'] == false
          ? "-"
          : json['acquisition_date'].toString(),

      tags: (json['tag_ids'] as List<dynamic>? ?? [])
          .map((e) => ListConvert.fromJson(e))
          .toList(),

      state: ListConvert.fromJson(json['state_id']),
      contractRenewalDueSoon: json['contract_renewal_due_soon'] ?? false,
      contractRenewalOverdue: json['contract_renewal_overdue'] ?? false,

      contractState:
          json['contract_state'] == null || json['contract_state'] == false
          ? "-"
          : json['contract_state'].toString(),

      company: ListConvert.fromJson(json['company_id']),
    );
  }
}

class TagItem {
  final int id;
  final String name;
  final int color;

  const TagItem({required this.id, required this.name, required this.color});

  factory TagItem.fromJson(Map<String, dynamic> json) {
    return TagItem(
      id: json['id'] ?? 0,
      name: json['display_name']?.toString() ?? "-",
      color: json['color'] ?? 0,
    );
  }
}
