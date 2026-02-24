class ModelActivityServiceLog {
  final int length;
  final List<ServiceFuelLogItem> records;

  const ModelActivityServiceLog({required this.length, required this.records});

  factory ModelActivityServiceLog.fromJson(List<dynamic> json) {
    return ModelActivityServiceLog(
      length: json.length,
      records: json
          .map((e) => ServiceFuelLogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceFuelLogItem {
  final int id;
  final String date;
  final String description;
  final ListConvert serviceType;
  final ListConvert vehicle;
  final ListConvert purchaser;
  final ListConvert purchaserEmployee;
  final ListConvert vendor;
  final String notes;
  final double amount;
  final String state;

  const ServiceFuelLogItem({
    required this.id,
    required this.date,
    required this.description,
    required this.serviceType,
    required this.vehicle,
    required this.purchaser,
    required this.purchaserEmployee,
    required this.vendor,
    required this.notes,
    required this.amount,
    required this.state,
  });

  factory ServiceFuelLogItem.fromJson(Map<String, dynamic> json) {
    return ServiceFuelLogItem(
      id: json['id'] ?? 0,
      date: json['date']?.toString() ?? "-",
      description: json['description'] == false
          ? "-"
          : json['description']?.toString() ?? "-",
      serviceType: ListConvert.fromJson(json['service_type_id']),
      vehicle: ListConvert.fromJson(json['vehicle_id']),
      purchaser: ListConvert.fromJson(json['purchaser_id']),
      purchaserEmployee: ListConvert.fromJson(json['purchaser_employee_id']),
      vendor: ListConvert.fromJson(json['vendor_id']),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] == false ? "-" : json['notes']?.toString() ?? "-",
      state: json['state']?.toString() ?? "-",
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
