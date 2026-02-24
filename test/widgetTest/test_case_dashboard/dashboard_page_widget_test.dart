import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/dashboard/dashboard_page.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/company/providers/company_provider.dart';
import 'package:provider/provider.dart';
import '../test_case_fleet_permission/fleetPermission_provider.dart';
import 'dashboard_widget_test_provider.dart';

void main() {
  final fakeProvider = FakeDashboardProvider();
  final companyProvider = CompanyProvider;

  Widget createTestWidget({
    required DashboardProvider provider,
    required FleetPermissionProvider fleetPermissionProvider,
    required bool isTest,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardProvider>.value(value: provider),
        ChangeNotifierProvider<FleetPermissionProvider>.value(
          value: fleetPermissionProvider,
        ),
      ],
      child: MaterialApp(home: DashboardPage(isTest: isTest)),
    );
  }

  Widget createFleetPermissionTestWidget({
    required DashboardProvider dashboardProvider,
    required FleetPermissionProvider fleetPermissionProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DashboardProvider>.value(
          value: dashboardProvider,
        ),
        ChangeNotifierProvider<FleetPermissionProvider>.value(
          value: fleetPermissionProvider,
        ),
      ],
      child: const MaterialApp(home: DashboardPage(isTest: false)),
    );
  }

  Finder findTextContaining(String value) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text && widget.data != null && widget.data!.contains(value),
    );
  }

  Finder findText(String value, String key) {
    return find.descendant(
      of: find.byKey(Key(key)),
      matching: find.text(value),
    );
  }

  testWidgets("Is refresh called", (WidgetTester tester) async {
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: true,
    );
    await tester.pumpWidget(
      createTestWidget(
        provider: fakeProvider,
        fleetPermissionProvider: fleetPermissionProvider,
        isTest: true,
      ),
    );
    expect(fakeProvider.refreshCalled, false);
    final refreshFinder = find.byType(RefreshIndicator);
    expect(refreshFinder, findsOneWidget);
    await tester.drag(refreshFinder, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(fakeProvider.refreshCalled, true);
  });

  testWidgets("Find Greetings", (WidgetTester tester) async {
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: true,
    );
    await tester.pumpWidget(
      createTestWidget(
        fleetPermissionProvider: fleetPermissionProvider,
        provider: fakeProvider,
        isTest: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Good Morning My_self!'), findsOneWidget);
    expect(find.text('Quick Stats'), findsOneWidget);
    expect(find.text('Cost Overview'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets("Find Card Containers", (WidgetTester tester) async {
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: true,
    );
    await tester.pumpWidget(
      createTestWidget(
        provider: fakeProvider,
        fleetPermissionProvider: fleetPermissionProvider,
        isTest: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('test_case_quick_stats_container_key')),
      findsNWidgets(4),
    );
    expect(
      find.byKey(const Key('test_case_cost_overview_container_key')),
      findsNWidgets(3),
    );
    expect(
      find.byKey(const Key('test_case_upcoming_container_key')),
      findsNWidgets(3),
    );
  });

  testWidgets("Find Quick Stats", (WidgetTester tester) async {
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: true,
    );
    await tester.pumpWidget(
      createTestWidget(
        fleetPermissionProvider: fleetPermissionProvider,
        provider: fakeProvider,
        isTest: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Total vehicles'), findsOneWidget);
    expect(find.text('Active Drivers'), findsOneWidget);
    expect(find.text('Vehicle Service'), findsOneWidget);
    expect(find.text('Vehicle (in use)'), findsOneWidget);
    expect(
      findText("20", 'test_case_quick_stats_container_key'),
      findsOneWidget,
    );
    expect(
      findText("15", 'test_case_quick_stats_container_key'),
      findsOneWidget,
    );
    expect(
      findText("1", 'test_case_quick_stats_container_key'),
      findsOneWidget,
    );
    expect(
      findText("14", 'test_case_quick_stats_container_key'),
      findsOneWidget,
    );
  });

  testWidgets("Find Cost Overview ", (WidgetTester tester) async {
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: true,
    );
    await tester.pumpWidget(
      createTestWidget(
        provider: fakeProvider,
        fleetPermissionProvider: fleetPermissionProvider,
        isTest: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Monthly Fleet cost'), findsOneWidget);
    expect(find.text('Fuel Cost'), findsOneWidget);
    expect(find.text('Service & Repair'), findsOneWidget);
    expect(findTextContaining('2300'), findsOneWidget);
    expect(findTextContaining('4500'), findsOneWidget);
    expect(findTextContaining('3500'), findsOneWidget);
  });

  testWidgets("Find upcoming", (WidgetTester tester) async {
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: true,
    );
    await tester.pumpWidget(
      createTestWidget(
        provider: fakeProvider,
        fleetPermissionProvider: fleetPermissionProvider,
        isTest: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Contract renewals'), findsOneWidget);
    expect(find.text('Services due'), findsOneWidget);
    expect(find.text('Insurance expiry'), findsOneWidget);
    expect(
      findText("4.0", 'test_case_upcoming_container_key'),
      findsNWidgets(2),
    );
    expect(findText("2.0", 'test_case_upcoming_container_key'), findsOneWidget);
  });

  testWidgets("Shimmer working", (WidgetTester tester) async {
    final fakeProvider = FakeDashboardProvider(startLoading: true);
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: true,
    );
    await tester.pumpWidget(
      createTestWidget(
        fleetPermissionProvider: fleetPermissionProvider,
        provider: fakeProvider,
        isTest: true,
      ),
    );
    await tester.pump();
    expect(
      find.byKey(const Key('test_case_dashboard_shimmer_check')),
      findsOneWidget,
    );
  });

  testWidgets("Fleet permission Dashboard page", (WidgetTester tester) async {
    final dashboardProvider = FakeDashboardProvider();
    final fleetPermissionProvider = FakeFleetPermissionProvider(
      canAccess: false,
    );
    await tester.pumpWidget(
      createFleetPermissionTestWidget(
        dashboardProvider: dashboardProvider,
        fleetPermissionProvider: fleetPermissionProvider,
      ),
    );
    await tester.pump();
    expect(find.text('Access Denied'), findsOneWidget);
    expect(
      find.textContaining(
        'You do not have access to the Fleet Dashboard page.',
      ),
      findsOneWidget,
    );
  });
}
