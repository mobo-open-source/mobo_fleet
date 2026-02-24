import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/drivers/drivers_details_page.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';
import 'package:provider/provider.dart';
import 'drivers_widget_test_provider.dart';

void main() {
  Widget createTestWidget(DriversPageProvider provider, Widget home) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DriversPageProvider>.value(value: provider),
      ],
      child: MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: RouteSettings(
              arguments: {
                'id': 10,
                'name': 'Alex',
                'phone': '9999999999',
                'photo': null,
              },
            ),
            builder: (_) => home,
          );
        },
      ),
    );
  }

  testWidgets("Title Driver's History", (WidgetTester tester) async {
    final fakeProvider = FakeDriversPageProvider();
    final page = Driverdetails();

    await tester.pumpWidget(createTestWidget(fakeProvider, page));
    await tester.pumpAndSettle();

    expect(find.text("Driver's History"), findsOneWidget);
    expect(find.text("Assigned Vehicles"), findsOneWidget);
    expect(find.text("Driving History"), findsOneWidget);
  });

  // testWidgets("Driver details & driving history dates are visible", (
  //   WidgetTester tester,
  // ) async {
  //   final fakeProvider = FakeDriversPageProvider();
  //
  //   await fakeProvider.fetchVehicles();
  //   await fakeProvider.fetchDrivingHistory();
  //
  //   await tester.pumpWidget(
  //     createTestWidget(fakeProvider, const Driverdetails()),
  //   );
  //
  //   await tester.pumpAndSettle();
  //
  //   final arrowFinder = find.byKey(const ValueKey('driver_history_arrow_1'));
  //
  //   expect(arrowFinder, findsOneWidget);
  //
  //   await tester.tap(arrowFinder);
  //   await tester.pumpAndSettle();
  //
  //   expect(
  //     find.byKey(const Key('test_case_driversHistory_start_date_value')),
  //     findsOneWidget,
  //   );
  // });
}
