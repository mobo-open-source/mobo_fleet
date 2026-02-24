import 'dart:typed_data';
import 'dart:convert';

class ModelVendorsList {
  final int length;
  final List<VendorItem> records;

  const ModelVendorsList({required this.length, required this.records});

  factory ModelVendorsList.fromJson(List<dynamic> json) {
    return ModelVendorsList(
      length: json.length,
      records: json
          .map((e) => VendorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VendorItem {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String? vat;
  final DateTime? writeDate;
  final Uint8List? avatar128;
  final ListConvert user;

  const VendorItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.vat,
    required this.writeDate,
    required this.avatar128,
    required this.user,
  });

  factory VendorItem.fromJson(Map<String, dynamic> json) {
    return VendorItem(
      id: json['id'] ?? 0,

      name: json['complete_name'] ?? json['name'] ?? "-",

      phone: (json['phone'] == null || json['phone'] == false)
          ? "-"
          : json['phone'].toString(),

      email: (json['email'] == null || json['email'] == false)
          ? "-"
          : json['email'].toString(),

      vat: json['vat'] == false ? null : json['vat']?.toString(),

      writeDate: json['write_date'] != null
          ? DateTime.tryParse(json['write_date'].toString())
          : null,

      avatar128: json['avatar_128'] != null && json['avatar_128'] != false
          ? base64Decode(json['avatar_128'])
          : null,

      user: ListConvert.fromJson(json['user_id']),
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
