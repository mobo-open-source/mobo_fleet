class ModelServiceTypeList {
  final int length;
  final List<ServiceTypeItem> records;

  const ModelServiceTypeList({required this.length, required this.records});

  factory ModelServiceTypeList.fromJson(List<dynamic> json) {
    return ModelServiceTypeList(
      length: json.length,
      records: json
          .map((e) => ServiceTypeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceTypeItem {
  final int id;
  final String name;
  final String category;

  const ServiceTypeItem({
    required this.id,
    required this.name,
    required this.category,
  });

  factory ServiceTypeItem.fromJson(Map<String, dynamic> json) {
    return ServiceTypeItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? "-",
      category: json['category']?.toString() ?? "-",
    );
  }
}
