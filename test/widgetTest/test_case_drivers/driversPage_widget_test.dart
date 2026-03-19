import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/drivers/drivers_page.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';
import 'package:provider/provider.dart';
import '../test_case_fleet_permission/fleetPermission_provider.dart';
import 'drivers_widget_test_provider.dart';

void main() {
  Widget createTestWidget(DriversPageProvider provider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DriversPageProvider>.value(value: provider),
        ChangeNotifierProvider<FleetPermissionProvider>(
          create: (_) => FleetPermissionProvider()..allowAllForTest(),
        ),
      ],
      child: const MaterialApp(home: DriversPage(skipPermissionGate: true)),
    );
  }

  Widget createPermissionTestWidget({
    required DriversPageProvider vehiclesProvider,
    required FleetPermissionProvider permissionProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DriversPageProvider>.value(
          value: vehiclesProvider,
        ),
        ChangeNotifierProvider<FleetPermissionProvider>.value(
          value: permissionProvider,
        ),
      ],
      child: MaterialApp(home: DriversPage(skipPermissionGate: false)),
    );
  }

  testWidgets("Driver search updates provider", (WidgetTester tester) async {
    final fakeProvider = FakeDriversPageProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 300));
    final searchField = find.byKey(const Key('driver_search_field'));
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'abc');
    await tester.pump(const Duration(milliseconds: 300));
    expect(fakeProvider.lastSearchQuery, 'abc');
    expect(fakeProvider.fetchCalled, isTrue);
  });
}
