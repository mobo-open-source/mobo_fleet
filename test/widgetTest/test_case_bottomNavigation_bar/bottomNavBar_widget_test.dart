import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_page.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_provider.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/company/providers/company_provider.dart';
import 'package:mobo_projects/features/profile/providers/profile_provider.dart';

void main() {
  testWidgets("AppBar title matches index 1, 2, 3", (
    WidgetTester tester,
  ) async {
    const int indexToTest = 3;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BottomNavProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => VehiclesProvider()),
          ChangeNotifierProvider(create: (_) => DriversPageProvider()),
          ChangeNotifierProvider(create: (_) => ActivityPageProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => CompanyProvider()),
          ChangeNotifierProvider(create: (_) => FleetPermissionProvider()),
        ],
        child: const MaterialApp(
          home: BottomNavigationBarPage(initialIndex: indexToTest, isTest: true),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    String expectedTitle;

    if (indexToTest == 1) {
      expectedTitle = 'test_case_add_contract';
    } else if (indexToTest == 2) {
      expectedTitle = 'Drivers';
    } else if (indexToTest == 3) {
      expectedTitle = 'Activity';
    } else {
      expectedTitle = 'Dashboard';
    }

    final appBarTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.text(expectedTitle),
    );

    expect(appBarTitle, findsOneWidget);
  });
}
