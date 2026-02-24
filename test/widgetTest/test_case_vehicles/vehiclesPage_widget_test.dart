import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_page.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:provider/provider.dart';
import '../test_case_fleet_permission/fleetPermission_provider.dart';
import 'vehicles_widget_test_provider.dart';

void main() {
  Widget createTestWidget(VehiclesProvider provider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VehiclesProvider>.value(value: provider),
        ChangeNotifierProvider<FleetPermissionProvider>(
          create: (_) => FleetPermissionProvider()..allowAllForTest(),
        ),
      ],
      child: MaterialApp(home: VehiclesPage(skipPermissionGate: true)),
    );
  }

  Widget createPermissionTestWidget({
    required VehiclesProvider vehiclesProvider,
    required FleetPermissionProvider permissionProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VehiclesProvider>.value(value: vehiclesProvider),
        ChangeNotifierProvider<FleetPermissionProvider>.value(
          value: permissionProvider,
        ),
      ],
      child: MaterialApp(home: VehiclesPage(skipPermissionGate: false)),
    );
  }

  testWidgets("Vehicles page shows search bar", (WidgetTester tester) async {
    final fakeProvider = FakeVehiclesPageProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final searchBar = find.byKey(const Key("test_case_vehicles_"));
    expect(searchBar, findsOneWidget);
  });

  testWidgets("Vehicles Page shows pagination controls", (
    WidgetTester tester,
  ) async {
    final fakeProvider = FakeVehiclesPageProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets("Filtering concept", (WidgetTester tester) async {
    final fakeProvider = FakeVehiclesPageProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    final key = 'vehiclesPage_filter_open_key';
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Car"));
    await tester.pump();
    await tester.tap(find.text("Bike"));
    await tester.pump();
    await tester.tap(find.text("Apply"));
    await tester.pump();
    await tester.pump(Duration(milliseconds: 300));
    expect(find.text("2 Active"), findsOneWidget);
  });

  testWidgets("searchField Vehicles", (WidgetTester tester) async {
    final fakeProvider = FakeVehiclesPageProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pumpAndSettle();
    final searchBar = find.byKey(const Key("test_case_vehicles_"));
    expect(searchBar, findsOneWidget);
    await tester.enterText(searchBar, 'model2');
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.data == 'model2',
      ),
      findsOneWidget,
    );
    await tester.enterText(searchBar, '');
    await tester.pumpAndSettle();
    expect(find.text('model'), findsOneWidget);
  });

  testWidgets('Fleet permission Vehicles page', (WidgetTester tester) async {
    final fakeVehiclesProvider = FakeVehiclesPageProvider();
    final fakePermissionProvider = FakeFleetPermissionProvider(
      canAccess: false,
    );

    await tester.pumpWidget(
      createPermissionTestWidget(
        vehiclesProvider: fakeVehiclesProvider,
        permissionProvider: fakePermissionProvider,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('You do not have access to the Fleet Vehicles page.'),
      findsOneWidget,
    );
  });
}
