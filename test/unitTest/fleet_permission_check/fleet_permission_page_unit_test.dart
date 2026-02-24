import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';

void main() {
  late FleetPermissionProvider provider;

  setUp(() {
    provider = FleetPermissionProvider();
  });

  test("initial state", () {
    expect(provider.canAccessFleet, false);
    expect(provider.isFleetAdmin, false);
    expect(provider.hasChecked, false);
    expect(provider.isChecking, false);
  });

  test('allowAllForTest - fleet access', () {
    provider.allowAllForTest();
    expect(provider.canAccessFleet, true);
  });

  test("reset clear", () {
    provider.allowAllForTest();
    provider.clearOnLogout();
    expect(provider.canAccessFleet, false);
    expect(provider.hasChecked, false);
    expect(provider.isChecking, false);
  });
}
