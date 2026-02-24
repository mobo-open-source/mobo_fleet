class ModelActivityFuelLog {
  final int length;
  final List<ServiceLog> records;

  ModelActivityFuelLog({required this.length, required this.records});

  factory ModelActivityFuelLog.fromList(List<dynamic> list) {
    return ModelActivityFuelLog(
      length: list.length,
      records: list.map((e) => ServiceLog.fromJson(e)).toList(),
    );
  }

  factory ModelActivityFuelLog.fromJson(Map<String, dynamic> json) {
    return ModelActivityFuelLog(
      length: json['length'] ?? 0,
      records: (json['records'] as List<dynamic>)
          .map((e) => ServiceLog.fromJson(e))
          .toList(),
    );
  }
}

class ServiceLog {
  final int id;
  final String date;
  final String description;
  final String serviceType;
  final String vehicle;
  final String purchaser;
  final String purchaserEmployee;
  final String vendor;
  final String invRef;
  final String notes;
  final double amount;
  final String currency;
  final String state;

  ServiceLog({
    required this.id,
    required this.date,
    required this.description,
    required this.serviceType,
    required this.vehicle,
    required this.purchaser,
    required this.purchaserEmployee,
    required this.vendor,
    required this.invRef,
    required this.notes,
    required this.amount,
    required this.currency,
    required this.state,
  });

  static String safe(dynamic value) {
    if (value == null || value == false) return "-";

    if (value is List && value.length >= 2) {
      return value[1]?.toString() ?? "-";
    }

    if (value is Map && value.containsKey("display_name")) {
      return value["display_name"]?.toString() ?? "-";
    }

    if (value is DateTime) {
      return value.toIso8601String().split("T")[0];
    }

    return value.toString();
  }

  factory ServiceLog.fromJson(Map<String, dynamic> json) {
    return ServiceLog(
      id: json["id"] ?? 0,
      date: safe(json["date"]),
      description: safe(json["description"]),
      serviceType: safe(json["service_type_id"]),
      vehicle: safe(json["vehicle_id"]),
      purchaser: safe(json["purchaser_id"]),
      purchaserEmployee: safe(json["purchaser_employee_id"]),
      vendor: safe(json["vendor_id"]),
      invRef: safe(json["inv_ref"]),
      notes: safe(json["notes"]),
      amount: (json["amount"] is num) ? json["amount"].toDouble() : 0.0,
      currency: safe(json["currency_id"]),
      state: safe(json["state"]),
    );
  }
}
