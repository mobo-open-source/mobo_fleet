class ModelAddLogDriversList {
  final int length;
  final List<DriverItem> records;

  const ModelAddLogDriversList({required this.length, required this.records});

  factory ModelAddLogDriversList.fromJson(List<dynamic> json) {
    return ModelAddLogDriversList(
      length: json.length,
      records: json
          .map((e) => DriverItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DriverItem {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String? avatar128;

  const DriverItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatar128,
  });

  factory DriverItem.fromJson(Map<String, dynamic> json) {
    return DriverItem(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? "-",
      phone: (json['phone'] == null || json['phone'] == false)
          ? "-"
          : json['phone'].toString(),
      email: (json['email'] == null || json['email'] == false)
          ? "-"
          : json['email'].toString(),
      avatar128: json['avatar_128']?.toString(),
    );
  }
}
