import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mobo_projects/core/services/odoo_session_manager.dart';

class FleetPermissionProvider extends ChangeNotifier {
  bool isCheckingg = false;
  bool checkedOnces = false;

  bool canAccessFleet = false;
  bool isFleetAdmin = false;
  bool isLoading = false;

  bool get hasChecked => checkedOnces;
  bool get isChecking => isCheckingg;

  Future<void> _checkPermission() async {
    if (isCheckingg) return;

    isCheckingg = true;
    isLoading = true;
    notifyListeners();

    bool hasFleetAdmin = false;
    bool hasFleetUser = false;

    try {
      final client = await OdooSessionManager.getClient();
      final session = client?.sessionId;
      log(" current sessions : ${client!.sessionId.toString()}");

      final userId = session?.userId;

      if (session?.userId == null) {
        canAccessFleet = false;
        isFleetAdmin = false;
        return;
      }

      final String serverVersionString = session!.serverVersion;

      final int majorVersion =
          int.tryParse(serverVersionString.split('.').first) ?? 0;
      if (majorVersion >= 18) {
        hasFleetAdmin = await OdooSessionManager.callKwWithCompany({
          'model': 'res.users',
          'method': 'has_group',
          'args': [
            [userId],
            'fleet.fleet_group_manager',
          ],
        });

        hasFleetUser = await OdooSessionManager.callKwWithCompany({
          'model': 'res.users',
          'method': 'has_group',
          'args': [
            [userId],
            'fleet.fleet_group_user',
          ],
        });
      } else {
        hasFleetAdmin = await OdooSessionManager.callKwWithCompany({
          'model': 'res.users',
          'method': 'has_group',
          'args': ['fleet.fleet_group_manager'],
        });

        hasFleetUser = await OdooSessionManager.callKwWithCompany({
          'model': 'res.users',
          'method': 'has_group',
          'args': ['fleet.fleet_group_user'],
        });
      }
      isFleetAdmin = hasFleetAdmin;
      canAccessFleet = hasFleetAdmin || hasFleetUser;
      log('Odoo major version: $majorVersion');
      log(
        'Fleet permission → Admin: $hasFleetAdmin | User: $hasFleetUser | Access: $canAccessFleet',
      );
    } catch (e) {
      log('Fleet permission error: $e');
      canAccessFleet = false;
      isFleetAdmin = false;
    } finally {
      checkedOnces = true;
      isCheckingg = false;
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ TEST-ONLY helper (safe)
  // @visibleForTesting
  // void setTestPermission({
  //   required bool hasAccess,
  // }) {
  //   checkedOnces = true;
  //   isCheckingg = false;
  //   isLoading = false;
  //   canAccessFleet = hasAccess;
  //   notifyListeners();
  // }

  Future<void> refreshFleetPermission() async {
    checkedOnces = false;
    isCheckingg = false;
    isLoading = false;
    canAccessFleet = false;
    notifyListeners();
    await _checkPermission();
  }

  Future<void> refreshPermission() async {
    checkedOnces = false;
    await _checkPermission();
  }

  Future<void> ensurePermissionChecked() async {
    if (checkedOnces || isCheckingg) return;
    await _checkPermission();
  }

  void allowAllForTest() {
    canAccessFleet = true;
  }

  void clearOnLogout() {
    checkedOnces = false;
    isCheckingg = false;
    canAccessFleet = false;
    isLoading = false;
    log("state reset successful");
    notifyListeners();
  }
}
