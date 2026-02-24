class ModelServiceAndRepairCostOnly {
  ModelServiceAndRepairCostOnly({
    required this.id,
    required this.amount,
  });

  final int id;
  final num? amount;

  factory ModelServiceAndRepairCostOnly.fromJson(Map<String, dynamic> json){
    return ModelServiceAndRepairCostOnly(
      id: json["id"] ?? 0,
      amount: json["amount"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "amount": amount,
  };
}
