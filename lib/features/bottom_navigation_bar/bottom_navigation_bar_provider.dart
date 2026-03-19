import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:provider/provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';

class BottomNavigationBarProvider extends ChangeNotifier {
  int index = 0;

  screenIndex(int clickedIndex) {
    index = clickedIndex;
    notifyListeners();
  }

  Future<void> refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<DashboardProvider>().refreshDashboard(context),
      context.read<VehiclesProvider>().refreshVehicles(),
      context.read<DriversPageProvider>().fetchDrivers(),
      context.read<ActivityPageProvider>().onRefresh(),
    ]);
  }

  void clearOnLogout() {
    index = 0;
  }
}
