
class ModelFetchFleetManager {
  final int length;
  final List<UserRecord> records;

  ModelFetchFleetManager({required this.length, required this.records});

  factory ModelFetchFleetManager.fromJson(Map<String, dynamic> json) {
    return ModelFetchFleetManager(
      length: json['length'] ?? 0,
      records: (json['records'] as List<dynamic>? ?? [])
          .map((e) => UserRecord.fromJson(e))
          .toList(),
    );
  }
}

class UserRecord {
  final int id;
  final String? avatar128;
  final DateTime? writeDate;
  final String name;
  final String login;
  final String? lang;
  final DateTime? loginDate;
  final String? role;
  final String? state;

  UserRecord({
    required this.id,
    this.avatar128,
    this.writeDate,
    required this.name,
    required this.login,
    this.lang,
    this.loginDate,
    this.role,
    this.state,
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) {
    return UserRecord(
      id: json['id'] ?? 0,
      avatar128: json['avatar_128']?.toString(),
      writeDate: _parseDate(json['write_date']),
      name: json['name'] ?? '',
      login: json['login'] ?? '',
      lang: json['lang'],
      loginDate: _parseDate(json['login_date']),
      role: json['role'],
      state: json['state'],
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}