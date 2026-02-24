import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_projects/models/model_fleet_dashboard_data.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';
import 'package:provider/provider.dart';

class DashboardProvider extends ChangeNotifier {
  bool isDashboardDataLoading = false;
  bool _isDisposed = false;

  ModelFleetDashboardData? modelFleetDashboardData;

  Uint8List? uint8list;

  String userName = "";
  String greetings = "";

  final today = DateTime.now();

  late final startOfMonth = DateTime(today.year, today.month, 1);
  late final endOfMonth = DateTime(today.year, today.month + 1, 0);

  String formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  void safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  /// Call Kw
  Future<dynamic> _callKw(Map<String, dynamic> params) async {
    return await OdooSessionManager.callKwWithCompany(params);
  }

  /// Greetings
  void setGreetings() {
    final hour = DateTime.now().hour;
    greetings = hour < 12
        ? "Morning"
        : hour < 18
        ? "Afternoon"
        : "Evening";
  }

  /// Fetch user details
  Future<void> fetchUserDetails(int userId) async {
    final List users = await _callKw({
      'model': 'res.users',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['id', '=', userId],
        ],
        'fields': ['name', 'image_1920'],
      },
    });

    if (users.isNotEmpty) {
      userName = users.first['name'] ?? "-";
      final img = users.first['image_1920'];
      if (img is String && img.isNotEmpty) {
        uint8list = base64Decode(img);
      } else {
        uint8list = null;
      }
    }
    safeNotify();
  }

  /// Dashboard Clear
  void clearDashboard() {
    modelFleetDashboardData = null;
    userName = "";
    uint8list = null;
    greetings = "";
    isDashboardDataLoading = false;
    notifyListeners();
  }

  /// Count calling
  Future<int> _count(String model, List domain) async {
    return await _callKw({
      'model': model,
      'method': 'search_count',
      'args': [domain],
      'kwargs': {},
    });
  }

  /// Fetch total service and Repair amount
  Future<num> _sumAmount(List domain) async {
    final List logs = await _callKw({
      'model': 'fleet.vehicle.log.services',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': domain,
        'fields': ['amount'],
      },
    });
    return logs.fold<num>(0, (s, e) => s + (e['amount'] ?? 0));
  }

  /// Fetch Dashboard Data
  Future<void> fetchDashboardNewData(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    if (modelFleetDashboardData != null && !forceRefresh) return;

    isDashboardDataLoading = true;
    safeNotify();

    try {
      final int totalVehicles = await _count('fleet.vehicle', []);

      final int activeDrivers = await _count('res.partner', []);

      final int vehiclesInService = await _count(
        'fleet.vehicle.log.services',
        [],
      );

      final int vehiclesInUse = await _count('fleet.vehicle', [
        ['active', '=', true],
        ['driver_id', '!=', false],
      ]);

      final num monthlyFleetCost = await _sumAmount([
        ['date', '>=', formatDate(startOfMonth)],
        ['date', '<=', formatDate(endOfMonth)],
      ]);

      final num fuelCost = await _sumAmount([
        ['service_type_id.name', '=', 'Fuel'],
      ]);

      final num serviceAndRepairCost = await _sumAmount([]);

      final int contractRenewal = await _count('fleet.vehicle.log.contract', [
        ['state', '=', 'expired'],
      ]);

      final int serviceDues = await _count('fleet.vehicle.log.services', [
        [
          'state',
          'in',
          ['new', 'running'],
        ],
      ]);

      final int insuranceExpiry = await _count('fleet.vehicle.log.contract', [
        ['cost_subtype_id.name', '=', 'Insurance'],
        ['expiration_date', '<', formatDate(DateTime.now())],
      ]);

      modelFleetDashboardData = ModelFleetDashboardData(
        quickStats: QuickStats(
          totalVehicles: totalVehicles,
          activeDrivers: activeDrivers,
          vehiclesInService: vehiclesInService,
          vehiclesInUse: vehiclesInUse,
        ),
        costOverview: CostOverview(
          monthlyFleetCost: monthlyFleetCost,
          fuelCost: fuelCost,
          serviceAndRepairCost: serviceAndRepairCost,
        ),
        upcoming: Upcoming(
          contractRenewal: contractRenewal,
          serviceDues: serviceDues,
          insuranceExpiry: insuranceExpiry,
        ),
      );
    } catch (e) {
    } finally {
      isDashboardDataLoading = false;
      safeNotify();
    }
  }

  /// Refresh Dashboard
  Future<void> refreshDashboard(BuildContext context) async {
    final fleetPerm = context.read<FleetPermissionProvider>();
    await fleetPerm.refreshFleetPermission();
    if (!fleetPerm.canAccessFleet) {
      clearDashboard();
      return;
    }
    clearDashboard();
    await fetchDashboardNewData(context, forceRefresh: true);
    final session = await OdooSessionManager.getCurrentSession();
    if (session?.userId != null) {
      await fetchUserDetails(session!.userId!);
      setGreetings();
    }
    safeNotify();
  }

  /// Clear on Logout
  void clearOnLogout() {
    modelFleetDashboardData = null;
    userName = "-";
    uint8list = null;
    greetings = "";
    isDashboardDataLoading = false;
    notifyListeners();
  }

  /// Icon handle for user profile
  Widget iconHandle({required Color color}) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedUserCircle02,
      size: 35,
      color: color,
    );
  }

  /// Dispose
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
    clearDashboard();
  }
}
