import 'package:flutter/material.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_provider.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_provider.dart';
import 'package:mobo_projects/features/add_service_fuel/add_service_fuel_log_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_provider.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';
import 'package:provider/provider.dart';

class ClearProviders {
  static Future<void> clearAllProviders(BuildContext context) async {
    context.read<AddOdometerLogProvider>().clearOnLogout();
    context.read<AddServiceFuelLogProvider>().clearOnLogout();
    context.read<AddContractsLogProvider>().clearOnLogout();
    context.read<ActivityPageProvider>().clearOnLogout();
    context.read<BottomNavigationBarProvider>().clearOnLogout();
    context.read<VehiclesProvider>().clearOnLogout();
    context.read<DashboardProvider>().clearOnLogout();
    context.read<DriversPageProvider>().clearOnLogout();
    context.read<VehiclesDetailsProvider>().clearOnLogout();
    context.read<FleetPermissionProvider>().clearOnLogout();
  }
}
