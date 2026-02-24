import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';

class FakeFleetPermissionProvider extends FleetPermissionProvider {
  FakeFleetPermissionProvider({required bool canAccess}) {
    canAccessFleet = canAccess;
    isLoading = false;

    checkedOnces = true;
  }

  @override
  Future<void> ensurePermissionChecked() async {}

  @override
  Future<void> refreshFleetPermission() async {}
}
