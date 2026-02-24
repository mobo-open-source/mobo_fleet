class ModelDriverLists {
  final int length;
  final List<Record> records;

  ModelDriverLists({required this.length, required this.records});

  factory ModelDriverLists.fromJson(Map<String, dynamic> json) {
    return ModelDriverLists(
      length: json['length'] ?? 0,
      records:
          (json['records'] as List?)?.map((e) => Record.fromJson(e)).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "length": length,
    "records": records.map((e) => e.toJson()).toList(),
  };
}

class Record {
  final int id;
  final String? avatar128;
  final DateTime? writeDate;
  final String? completeName;

  final bool? vat;
  final bool? invoiceSendingMethod;
  final bool? invoiceEdiFormat;

  final String? email;
  final String? phone;
  final dynamic userId;

  final List<int> activityIds;

  final bool? activityExceptionDecoration;
  final bool? activityExceptionIcon;
  final bool? activityState;
  final bool? activitySummary;
  final bool? activityTypeIcon;
  final bool? activityTypeId;

  final String? street;
  final String? city;
  final dynamic stateId;

  final Country? country;
  final List<ApplicationStatistic> applicationStatistics;

  final List<int> categoryId;
  final List<dynamic> properties;

  final PropertiesBaseDefinition? propertiesBaseDefinition;

  Record({
    required this.id,
    this.avatar128,
    this.writeDate,
    this.completeName,
    this.vat,
    this.invoiceSendingMethod,
    this.invoiceEdiFormat,
    this.email,
    this.phone,
    this.userId,
    this.activityIds = const [],
    this.activityExceptionDecoration,
    this.activityExceptionIcon,
    this.activityState,
    this.activitySummary,
    this.activityTypeIcon,
    this.activityTypeId,
    this.street,
    this.city,
    this.stateId,
    this.country,
    this.applicationStatistics = const [],
    this.categoryId = const [],
    this.properties = const [],
    this.propertiesBaseDefinition,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] ?? 0,
      avatar128:
          json['avatar_128'] is String &&
              (json['avatar_128'] as String).isNotEmpty
          ? json['avatar_128']
          : null,

      writeDate: json['write_date'] != null && json['write_date'] is String
          ? DateTime.tryParse(json['write_date'])
          : null,
      completeName: json['complete_name']?.toString(),

      vat: json['vat'] is bool ? json['vat'] : null,
      invoiceSendingMethod: json['invoice_sending_method'] is bool
          ? json['invoice_sending_method']
          : null,
      invoiceEdiFormat: json['invoice_edi_format'] is bool
          ? json['invoice_edi_format']
          : null,

      email: json['email'] is String ? json['email'] : null,
      phone: json['phone'] is String ? json['phone'] : "",
      userId: json['user_id'] is Map<String, dynamic> ? json['user_id'] : null,

      activityIds:
          (json['activity_ids'] as List?)?.whereType<int>().toList() ?? [],

      activityExceptionDecoration: json['activity_exception_decoration'] is bool
          ? json['activity_exception_decoration']
          : null,
      activityExceptionIcon: json['activity_exception_icon'] is bool
          ? json['activity_exception_icon']
          : null,
      activityState: json['activity_state'] is bool
          ? json['activity_state']
          : null,
      activitySummary: json['activity_summary'] is bool
          ? json['activity_summary']
          : null,
      activityTypeIcon: json['activity_type_icon'] is bool
          ? json['activity_type_icon']
          : null,
      activityTypeId: json['activity_type_id'] is bool
          ? json['activity_type_id']
          : null,

      street: json['street'] is String ? json['street'] : null,
      city: json['city'] is String ? json['city'] : null,
      stateId: json['state_id'] is Map<String, dynamic>
          ? json['state_id']
          : null,

      country: json['country_id'] is Map<String, dynamic>
          ? Country.fromJson(json['country_id'])
          : null,

      applicationStatistics: (json['application_statistics'] is List
          ? (json['application_statistics'] as List)
                .map((e) => ApplicationStatistic.fromJson(e))
                .toList()
          : []),

      categoryId:
          (json['category_id'] as List?)?.whereType<int>().toList() ?? [],

      properties: json['properties'] ?? [],

      propertiesBaseDefinition:
          json['properties_base_definition_id'] is Map<String, dynamic>
          ? PropertiesBaseDefinition.fromJson(
              json['properties_base_definition_id'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "avatar_128": avatar128,
    "write_date": writeDate?.toIso8601String(),
    "complete_name": completeName,
    "vat": vat,
    "invoice_sending_method": invoiceSendingMethod,
    "invoice_edi_format": invoiceEdiFormat,
    "email": email,
    "phone": phone,
    "user_id": userId,
    "activity_ids": activityIds,
    "activity_exception_decoration": activityExceptionDecoration,
    "activity_exception_icon": activityExceptionIcon,
    "activity_state": activityState,
    "activity_summary": activitySummary,
    "activity_type_icon": activityTypeIcon,
    "activity_type_id": activityTypeId,
    "street": street,
    "city": city,
    "state_id": stateId,
    "country_id": country?.toJson(),
    "application_statistics": applicationStatistics
        .map((e) => e.toJson())
        .toList(),
    "category_id": categoryId,
    "properties": properties,
    "properties_base_definition_id": propertiesBaseDefinition?.toJson(),
  };
}

class Country {
  final int id;
  final String? displayName;

  Country({required this.id, this.displayName});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      displayName: json['display_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "display_name": displayName};
}

class ApplicationStatistic {
  final String? iconClass;
  final int? value;
  final String? label;
  final String? tagClass;

  ApplicationStatistic({this.iconClass, this.value, this.label, this.tagClass});

  factory ApplicationStatistic.fromJson(Map<String, dynamic> json) {
    return ApplicationStatistic(
      iconClass: json['iconClass']?.toString(),
      value: json['value'] is int ? json['value'] : null,
      label: json['label']?.toString(),
      tagClass: json['tagClass']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "iconClass": iconClass,
    "value": value,
    "label": label,
    "tagClass": tagClass,
  };
}

class PropertiesBaseDefinition {
  final int id;
  final String? displayName;

  PropertiesBaseDefinition({required this.id, this.displayName});

  factory PropertiesBaseDefinition.fromJson(Map<String, dynamic> json) {
    return PropertiesBaseDefinition(
      id: json['id'] ?? 0,
      displayName: json['display_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "display_name": displayName};
}
