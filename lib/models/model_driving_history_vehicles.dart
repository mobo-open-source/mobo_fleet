import 'package:intl/intl.dart';

class ModelDrivingHistoryVehicles {
  final int id;
  final int vehicleId;
  final String vehicleName;
  final int driverId;
  final String driverName;
  final String driverEmployee;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final int attachmentNumber;

  ModelDrivingHistoryVehicles({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.driverId,
    required this.driverName,
    required this.driverEmployee,
    required this.dateStart,
    required this.dateEnd,
    required this.attachmentNumber,
  });

  factory ModelDrivingHistoryVehicles.fromJson(Map<String, dynamic> json) {
    return ModelDrivingHistoryVehicles(
      id: json['id'] ?? 0,

      vehicleId: parseM2OId(json['vehicle_id']),
      vehicleName: parseM2OName(json['vehicle_id']),

      driverId: parseM2OId(json['driver_id']),
      driverName: parseM2OName(json['driver_id']),

      driverEmployee: safeString(json['driver_employee_id']),

      dateStart: safeDate(json['date_start']),
      dateEnd: safeDate(json['date_end']),

      attachmentNumber: json['attachment_number'] ?? 0,
    );
  }

  String get dateStartFormatted => formatDate(dateStart);
  String get dateEndFormatted => formatDate(dateEnd);
}

String safeString(dynamic value) {
  if (value == null || value == false) return "";
  return value.toString();
}

DateTime? safeDate(dynamic value) {
  if (value == null || value == false) return null;

  if (value is DateTime) return value;

  return DateTime.tryParse(value.toString());
}

int parseM2OId(dynamic value) {
  if (value == null || value == false) return 0;

  if (value is List && value.isNotEmpty) {
    return value[0] ?? 0;
  }

  if (value is Map) {
    return value['id'] ?? 0;
  }

  return 0;
}

String parseM2OName(dynamic value) {
  if (value == null || value == false) return "";

  if (value is List && value.length > 1) {
    return value[1]?.toString() ?? "";
  }

  if (value is Map) {
    return value['display_name']?.toString() ?? "";
  }

  return "";
}

String formatDate(DateTime? date) {
  if (date == null) return "";
  return DateFormat('MMM dd yyyy').format(date);
}
