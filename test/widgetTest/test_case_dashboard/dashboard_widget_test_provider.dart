import 'package:flutter/material.dart';
import 'package:mobo_projects/models/model_fleet_dashboard_data.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';

class FakeDashboardProvider extends DashboardProvider {
  bool refreshCalled = false;

  FakeDashboardProvider({bool startLoading = false}) {
    isDashboardDataLoading = startLoading;
    modelFleetDashboardData = startLoading ? null : modelFleetDashboardData;
  }

  @override
  Future<void> refreshDashboard(BuildContext context) async {
    refreshCalled = true;
    notifyListeners();
  }

  @override
  Future<void> fetchDashboardNewData(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    isDashboardDataLoading = false;
    modelFleetDashboardData = ModelFleetDashboardData(
      quickStats: QuickStats(
        totalVehicles: 20,
        activeDrivers: 15,
        vehiclesInService: 1,
        vehiclesInUse: 14,
      ),
      costOverview: CostOverview(
        monthlyFleetCost: 2300,
        fuelCost: 4500,
        serviceAndRepairCost: 3500,
      ),
      upcoming: Upcoming(
        contractRenewal: 4,
        serviceDues: 4,
        insuranceExpiry: 2,
      ),
    );

    userName = "My_self";
    greetings = "Morning";

    notifyListeners();
  }
}
