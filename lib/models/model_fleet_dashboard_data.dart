class ModelFleetDashboardData {
  ModelFleetDashboardData({
    required this.quickStats,
    required this.costOverview,
    required this.upcoming,
  });

  final QuickStats? quickStats;
  final CostOverview? costOverview;
  final Upcoming? upcoming;

  factory ModelFleetDashboardData.fromJson(Map<String, dynamic> json){
    return ModelFleetDashboardData(
      quickStats: json["quickStats"] == null ? null : QuickStats.fromJson(json["quickStats"]),
      costOverview: json["costOverview"] == null ? null : CostOverview.fromJson(json["costOverview"]),
      upcoming: json["upcoming"] == null ? null : Upcoming.fromJson(json["upcoming"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "quickStats": quickStats?.toJson(),
    "costOverview": costOverview?.toJson(),
    "upcoming": upcoming?.toJson(),
  };

}

class CostOverview {
  CostOverview({
    required this.monthlyFleetCost,
    required this.fuelCost,
    required this.serviceAndRepairCost,
  });

  final num monthlyFleetCost;
  final num fuelCost;
  final num serviceAndRepairCost;

  factory CostOverview.fromJson(Map<String, dynamic> json){
    return CostOverview(
      monthlyFleetCost: json["Monthly fleet cost"] ?? 0,
      fuelCost: json["Fuel cost"] ?? 0,
      serviceAndRepairCost: json["Service and repair cost"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "Monthly fleet cost": monthlyFleetCost,
    "Fuel cost": fuelCost,
    "Service and repair cost": serviceAndRepairCost,
  };

}

class QuickStats {
  QuickStats({
    required this.totalVehicles,
    required this.activeDrivers,
    required this.vehiclesInService,
    required this.vehiclesInUse,
  });

  final num totalVehicles;
  final num activeDrivers;
  final num vehiclesInService;
  final num vehiclesInUse;

  factory QuickStats.fromJson(Map<String, dynamic> json){
    return QuickStats(
      totalVehicles: json["Total vehicles"] ?? 0,
      activeDrivers: json["Active Drivers"] ?? 0,
      vehiclesInService: json["vehicles in Service"] ?? 0,
      vehiclesInUse: json["vehicles in Use"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "Total vehicles": totalVehicles,
    "Active Drivers": activeDrivers,
    "vehicles in Service": vehiclesInService,
    "vehicles in Use": vehiclesInUse,
  };

}

class Upcoming {
  Upcoming({
    required this.contractRenewal,
    required this.serviceDues,
    required this.insuranceExpiry,
  });

  final num contractRenewal;
  final num serviceDues;
  final num insuranceExpiry;

  factory Upcoming.fromJson(Map<String, dynamic> json){
    return Upcoming(
      contractRenewal: json["Contract renewal"] ?? 0,
      serviceDues: json["Service dues"] ?? 0,
      insuranceExpiry: json["Insurance expiry"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "Contract renewal": contractRenewal,
    "Service dues": serviceDues,
    "Insurance expiry": insuranceExpiry,
  };

}
