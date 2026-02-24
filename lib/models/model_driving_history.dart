import 'package:intl/intl.dart';

class ModelDrivingHistory {
  ModelDrivingHistory({required this.length, required this.records});

  final num length;
  final List<Record> records;

  factory ModelDrivingHistory.fromJson(Map<String, dynamic> json) {
    return ModelDrivingHistory(
      length: json["length"] ?? 0,
      records: (json["records"] as List? ?? [])
          .map((x) => Record.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    "length": length,
    "records": records.map((x) => x.toJson()).toList(),
  };
}


class Record {
  Record({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.driverEmployeeId,
    required this.dateStart,
    required this.dateEnd,
    required this.attachmentNumber,
  });

  final int id;
  final Id? vehicleId;
  final Id? driverId;
  final Id? driverEmployeeId;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final num attachmentNumber;

  factory Record.fromJson(Map<String, dynamic> json) {
    Id? parseRelationalField(dynamic field) {
      if (field == null || field == false) return null;
      if (field is List && field.length >= 2) {
        return Id(id: field[0], displayName: field[1]);
      }
      if (field is Map<String, dynamic>) {
        return Id.fromJson(field);
      }
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null || value == false || value is! String) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return Record(
      id: json["id"] ?? 0,
      vehicleId: parseRelationalField(json["vehicle_id"]),
      driverId: parseRelationalField(json["driver_id"]),
      driverEmployeeId: parseRelationalField(json["driver_employee_id"]),
      dateStart: parseDate(json["date_start"]),
      dateEnd: parseDate(json["date_end"]),
      attachmentNumber: json["attachment_number"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "vehicle_id": vehicleId?.toJson(),
    "driver_id": driverId?.toJson(),
    "driver_employee_id": driverEmployeeId?.toJson(),
    "date_start": dateStart?.toIso8601String(),
    "date_end": dateEnd?.toIso8601String(),
    "attachment_number": attachmentNumber,
  };

  /// UI-safe helpers
  String get safeDateStart =>
      dateStart == null ? "-" : DateFormat('dd MMM yyyy').format(dateStart!);

  String get safeDateEnd =>
      dateEnd == null ? "-" : DateFormat('dd MMM yyyy').format(dateEnd!);
}


class Id {
  Id({required this.id, required this.displayName});

  final int id;
  final String displayName;

  factory Id.fromJson(Map<String, dynamic> json) {
    return Id(
      id: json["id"] ?? 0,
      displayName:
      (json["display_name"] == null || json["display_name"] == false)
          ? "-"
          : json["display_name"],
    );
  }

  Map<String, dynamic> toJson() =>
      {"id": id, "display_name": displayName};

  String get safeName => displayName.isEmpty ? "-" : displayName;
}

