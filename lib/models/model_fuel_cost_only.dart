class ModelFuelCostOnly {
  ModelFuelCostOnly({required this.id, required this.cost});

  final int id;
  final num cost;

  factory ModelFuelCostOnly.fromJson(Map<String, dynamic> json) {
    return ModelFuelCostOnly(id: json["id"] ?? 0, cost: json["cost"] ?? 0);
  }

  Map<String, dynamic> toJson() => {"id": id, "cost": cost};
}
