class ModelDriverModelList {
  ModelDriverModelList({required this.length, required this.records});

  final num length;
  final List<Record> records;

  factory ModelDriverModelList.fromJson(Map<String, dynamic> json) {
    return ModelDriverModelList(
      length: json["length"] ?? 0,
      records: json["records"] == null
          ? []
          : List<Record>.from(json["records"]!.map((x) => Record.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "length": length,
    "records": records.map((x) => x?.toJson()).toList(),
  };
}

class Record {
  Record({required this.id, required this.completeName});

  final int id;
  final String completeName;

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json["id"] ?? 0,
      completeName: json["complete_name"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "complete_name": completeName};
}
