import 'dart:convert';
import 'dart:typed_data';

class ModelFleetDashboardVehicleData {
  final int length;
  final List<FleetVehicle> records;

  ModelFleetDashboardVehicleData({required this.length, required this.records});

  factory ModelFleetDashboardVehicleData.fromJson(List<Map<String, dynamic>> jsonList) {
    final records = jsonList.map((e) => FleetVehicle.fromJson(e)).toList();
    return ModelFleetDashboardVehicleData(length: records.length, records: records);
  }
}

class FleetVehicle {
  final int id;
  final String licensePlate;
  final Uint8List? imageBytes;
  final List<dynamic> tags;
  final String model;
  final String category;
  final String manager;
  final String driver;
  final String driverEmployee;
  final String futureDriver;
  final String futureDriverEmployee;
  final String vinSn;
  final double co2;
  final String acquisitionDate;
  final List<int> tagIds;
  final String state;
  final String contractRenewalDueSoon;
  final String contractRenewalOverdue;
  final String contractState;

  FleetVehicle({
    required this.id,
    required this.licensePlate,
    required this.imageBytes,
    required this.tags,
    required this.model,
    required this.category,
    required this.manager,
    required this.driver,
    required this.driverEmployee,
    required this.futureDriver,
    required this.futureDriverEmployee,
    required this.vinSn,
    required this.co2,
    required this.acquisitionDate,
    required this.tagIds,
    required this.state,
    required this.contractRenewalDueSoon,
    required this.contractRenewalOverdue,
    required this.contractState,
  });

  factory FleetVehicle.fromJson(Map<String, dynamic> json) {
    Uint8List? image;

    if (json['image_128'] != null && json['image_128'] != false) {
      try {
        image = base64Decode(json['image_128']);
      } catch (e) {
        image = null;
      }
    }
    return FleetVehicle(
      imageBytes: image,

      id: json['id'] ?? 0,

      licensePlate:
          (json['license_plate'] == null || json['license_plate'] == false)
          ? "-"
          : json['license_plate'].toString(),

      tags: (json['tags'] == null || json['tags'] == false)
          ? []
          : List<dynamic>.from(json['tags']),

      model: (json['model_id'] == null || json['model_id'] == false)
          ? "-"
          : json['model_id'] is List
          ? json['model_id'][1].toString()
          : "-",

      category: (json['category_id'] == null || json['category_id'] == false)
          ? "-"
          : json['category_id'] is List
          ? json['category_id'][1].toString()
          : "-",

      manager: (json['manager_id'] == null || json['manager_id'] == false)
          ? "-"
          : json['manager_id'] is List
          ? json['manager_id'][1].toString()
          : "-",

      driver: (json['driver_id'] == null || json['driver_id'] == false)
          ? "-"
          : json['driver_id'] is List
          ? json['driver_id'][1].toString()
          : "-",

      driverEmployee:
          (json['driver_employee_id'] == null ||
              json['driver_employee_id'] == false)
          ? "-"
          : json['driver_employee_id'] is List
          ? json['driver_employee_id'][1].toString()
          : "-",

      futureDriver:
          (json['future_driver_id'] == null ||
              json['future_driver_id'] == false)
          ? "-"
          : json['future_driver_id'] is List
          ? json['future_driver_id'][1].toString()
          : "-",

      futureDriverEmployee:
          (json['future_driver_employee_id'] == null ||
              json['future_driver_employee_id'] == false)
          ? "-"
          : json['future_driver_employee_id'] is List
          ? json['future_driver_employee_id'][1].toString()
          : "-",

      vinSn: (json['vin_sn'] == null || json['vin_sn'] == false)
          ? "-"
          : json['vin_sn'].toString(),

      co2: (json['co2'] == null || json['co2'] == false)
          ? 0.0
          : (json['co2'] as num).toDouble(),

      acquisitionDate:
          (json['acquisition_date'] == null ||
              json['acquisition_date'] == false)
          ? "-"
          : json['acquisition_date'].toString(),

      tagIds: (json['tag_ids'] == null || json['tag_ids'] == false)
          ? []
          : List<int>.from(json['tag_ids']),

      state: (json['state_id'] == null || json['state_id'] == false)
          ? "-"
          : json['state_id'] is List
          ? json['state_id'][1].toString()
          : "-",

      contractRenewalDueSoon:
          (json['contract_renewal_due_soon'] == null ||
              json['contract_renewal_due_soon'] == false)
          ? "-"
          : json['contract_renewal_due_soon'].toString(),

      contractRenewalOverdue:
          (json['contract_renewal_overdue'] == null ||
              json['contract_renewal_overdue'] == false)
          ? "-"
          : json['contract_renewal_overdue'].toString(),

      contractState:
          (json['contract_state'] == null || json['contract_state'] == false)
          ? "-"
          : json['contract_state'].toString(),
    );
  }
}
