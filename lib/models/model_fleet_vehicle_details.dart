class ModelFleetVehicleDetails {
  final int length;
  final List<VehicleItem> records;

  const ModelFleetVehicleDetails({required this.length, required this.records});

  factory ModelFleetVehicleDetails.fromJson(List<dynamic> json) {
    return ModelFleetVehicleDetails(
      length: json.length,
      records: json
          .map((e) => VehicleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

String safeString(dynamic value, [String fallback = ""]) {
  if (value == null || value == false) return fallback;
  return value.toString();
}

DateTime? safeDate(dynamic value) {
  if (value == null || value == false) return null;
  return DateTime.tryParse(value.toString());
}

class VehicleItem {
  final int id;
  final String licensePlate;
  final String displayName;
  final bool active;

  final ListConvert state;
  final ListConvert model;
  final ListConvert driver;
  final ListConvert driverEmployee;
  final ListConvert futureDriver;
  final ListConvert futureDriverEmployee;
  final ListConvert category;
  final ListConvert manager;
  final ListConvert company;
  final ListConvert currency;

  final int billCount;
  final int historyCount;
  final int contractCount;
  final int serviceCount;
  final int odometerCount;

  final String vehicleType;
  final String fuelType;
  final String transmission;
  final String color;
  final String location;
  final String countryCode;
  final String mobilityCard;
  final String vinSn;

  final double odometer;
  final String odometerUnit;
  final double carValue;
  final double netCarValue;
  final double residualValue;
  final double horsepowerTax;
  final double power;
  final String powerUnit;
  final double horsepower;
  final int vehicleRange;
  final String rangeUnit;
  final double co2;
  final String co2EmissionUnit;
  final String co2Standard;

  final DateTime? writeDate;
  final DateTime? nextAssignationDate;
  final DateTime? orderDate;
  final DateTime? acquisitionDate;
  final DateTime? writeOffDate;
  final DateTime? contractDateStart;

  final String modelYear;
  final int seats;
  final int doors;

  final bool planToChangeCar;
  final bool planToChangeBike;
  final bool trailerHook;
  final String frameType;
  final double frameSize;
  final bool electricAssistance;

  final List<int> tagIds;
  final String description;

  const VehicleItem({
    required this.id,
    required this.licensePlate,
    required this.displayName,
    required this.active,
    required this.state,
    required this.model,
    required this.driver,
    required this.driverEmployee,
    required this.futureDriver,
    required this.futureDriverEmployee,
    required this.category,
    required this.manager,
    required this.company,
    required this.currency,
    required this.billCount,
    required this.historyCount,
    required this.contractCount,
    required this.serviceCount,
    required this.odometerCount,
    required this.vehicleType,
    required this.fuelType,
    required this.transmission,
    required this.color,
    required this.location,
    required this.countryCode,
    required this.mobilityCard,
    required this.vinSn,
    required this.odometer,
    required this.odometerUnit,
    required this.carValue,
    required this.netCarValue,
    required this.residualValue,
    required this.horsepowerTax,
    required this.power,
    required this.powerUnit,
    required this.horsepower,
    required this.vehicleRange,
    required this.rangeUnit,
    required this.co2,
    required this.co2EmissionUnit,
    required this.co2Standard,
    required this.writeDate,
    required this.nextAssignationDate,
    required this.orderDate,
    required this.acquisitionDate,
    required this.writeOffDate,
    required this.contractDateStart,
    required this.modelYear,
    required this.seats,
    required this.doors,
    required this.planToChangeCar,
    required this.planToChangeBike,
    required this.trailerHook,
    required this.frameType,
    required this.frameSize,
    required this.electricAssistance,
    required this.tagIds,
    required this.description,
  });

  factory VehicleItem.fromJson(Map<String, dynamic> json) {
    return VehicleItem(
      id: json['id'] ?? 0,
      licensePlate: safeString(json['license_plate']),
      displayName: safeString(json['display_name']),
      active: json['active'] ?? false,

      state: ListConvert.fromJson(json['state_id']),
      model: ListConvert.fromJson(json['model_id']),
      driver: ListConvert.fromJson(json['driver_id']),
      driverEmployee: ListConvert.fromJson(json['driver_employee_id']),
      futureDriver: ListConvert.fromJson(json['future_driver_id']),
      futureDriverEmployee: ListConvert.fromJson(
        json['future_driver_employee_id'],
      ),
      category: ListConvert.fromJson(json['category_id']),
      manager: ListConvert.fromJson(json['manager_id']),
      company: ListConvert.fromJson(json['company_id']),
      currency: ListConvert.fromJson(json['currency_id']),

      billCount: json['bill_count'] ?? 0,
      historyCount: json['history_count'] ?? 0,
      contractCount: json['contract_count'] ?? 0,
      serviceCount: json['service_count'] ?? 0,
      odometerCount: json['odometer_count'] ?? 0,

      vehicleType: safeString(json['vehicle_type']),
      fuelType: safeString(json['fuel_type']),
      transmission: safeString(json['transmission']),
      color: safeString(json['color']),
      location: safeString(json['location']),
      countryCode: safeString(json['country_code']),
      mobilityCard: safeString(json['mobility_card']),
      vinSn: safeString(json['vin_sn']),
      description: safeString(json['description'], ""),

      odometer: (json['odometer'] as num?)?.toDouble() ?? 0.0,
      odometerUnit: safeString(json['odometer_unit']),
      carValue: (json['car_value'] as num?)?.toDouble() ?? 0.0,
      netCarValue: (json['net_car_value'] as num?)?.toDouble() ?? 0.0,
      residualValue: (json['residual_value'] as num?)?.toDouble() ?? 0.0,
      horsepowerTax: (json['horsepower_tax'] as num?)?.toDouble() ?? 0.0,
      power: (json['power'] as num?)?.toDouble() ?? 0.0,
      powerUnit: safeString(json['power_unit']),
      horsepower: (json['horsepower'] as num?)?.toDouble() ?? 0.0,
      vehicleRange: json['vehicle_range'] ?? 0,
      rangeUnit: safeString(json['range_unit']),
      co2: (json['co2'] as num?)?.toDouble() ?? 0.0,
      co2EmissionUnit: safeString(json['co2_emission_unit']),
      co2Standard: safeString(json['co2_standard']),
      writeDate: safeDate(json['write_date']),
      nextAssignationDate: safeDate(json['next_assignation_date']),
      orderDate: safeDate(json['order_date']),
      acquisitionDate: safeDate(json['acquisition_date']),
      writeOffDate: safeDate(json['write_off_date']),
      contractDateStart: safeDate(
        json['contract_date_start'] ?? json['first_contract_date'],
      ),
      modelYear: safeString(json['model_year']),
      seats: json['seats'] ?? 0,
      doors: json['doors'] ?? 0,
      planToChangeCar: json['plan_to_change_car'] ?? false,
      planToChangeBike: json['plan_to_change_bike'] ?? false,
      trailerHook: json['trailer_hook'] ?? false,
      frameType: safeString(json['frame_type']),
      frameSize: (json['frame_size'] as num?)?.toDouble() ?? 0.0,
      electricAssistance: json['electric_assistance'] ?? false,
      tagIds: (json['tag_ids'] as List?)?.whereType<int>().toList() ?? [],
    );
  }
}

class ListConvert {
  final int? id;
  final String name;

  const ListConvert({this.id, required this.name});

  factory ListConvert.fromJson(dynamic json) {
    if (json == null || json == false) {
      return const ListConvert(id: null, name: "");
    }

    if (json is int) {
      return ListConvert(id: json, name: "");
    }

    if (json is List && json.isNotEmpty) {
      return ListConvert(
        id: json[0] is int ? json[0] : null,
        name: json.length > 1 ? json[1].toString() : "",
      );
    }

    if (json is Map<String, dynamic>) {
      return ListConvert(
        id: json['id'] as int?,
        name: json['display_name']?.toString() ?? "",
      );
    }

    return const ListConvert(id: null, name: "");
  }
}

class TagItem {
  final int id;
  final String name;
  final int color;

  const TagItem({required this.id, required this.name, required this.color});
}
