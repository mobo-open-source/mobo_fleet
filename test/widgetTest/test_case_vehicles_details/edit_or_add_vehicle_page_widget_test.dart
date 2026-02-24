import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/vehicles_details/edit_vehicles_details_page.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';
import 'package:provider/provider.dart';
import 'vehicles_details_widget_test_provider.dart';

void main() {
  Widget createAddVehicleTestWidget(FakeVehiclesProvider provider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<VehiclesDetailsProvider>.value(value: provider),
        ChangeNotifierProvider<DashboardProvider>(
          create: (_) => FakeDashboardProvider(),
        ),
        ChangeNotifierProvider<VehiclesProvider>(
          create: (_) => FakeVehiclesListProvider(),
        ),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditVehiclesDetailsPage(vehicleId: 0),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );
  }

  // testWidgets('Add Vehicle button calls', (WidgetTester tester) async {
  //   final fakeProvider = FakeVehiclesProvider();
  //
  //   fakeProvider.selectedVehicle = VehiclesVehicleItem(
  //     id: 1,
  //     model: ListConvert(id: 1, name: 'Test Vehicle'),
  //     licensePlate: 'KL-01-1234',
  //     active: true,
  //     vehicleType: 'car',
  //     category: ListConvert(id: 1, name: 'Category'),
  //     manager: ListConvert(id: 1, name: 'Manager'),
  //     driver: ListConvert(id: 1, name: 'Driver'),
  //     driverEmployee: ListConvert(id: 1, name: 'DriverEmp'),
  //     futureDriver: ListConvert(id: 1, name: 'Future Driver'),
  //     futureDriverEmployee: ListConvert(id: 1, name: 'Future Driver Emp'),
  //     logDrivers: const [],
  //     co2: 12.5,
  //     acquisitionDate: '2025-01-01',
  //     tags: const [],
  //     state: ListConvert(id: 1, name: 'Active'),
  //     contractRenewalDueSoon: false,
  //     contractRenewalOverdue: false,
  //     contractState: 'running',
  //     company: ListConvert(id: 1, name: 'Company'),
  //   );
  //
  //   fakeProvider.vehicleController.text = 'Test Vehicle';
  //
  //   await tester.pumpWidget(createAddVehicleTestWidget(fakeProvider));
  //   await tester.tap(find.text('open'));
  //   await tester.pumpAndSettle();
  //
  //   final addButton = find.byKey(const Key('add_edit_vehicle_key'));
  //   expect(addButton, findsOneWidget);
  //
  //   await tester.ensureVisible(addButton);
  //   await tester.pump();
  //
  //   await tester.tap(addButton);
  //   await tester.pumpAndSettle(const Duration(seconds: 5));
  //
  //   expect(fakeProvider.addVehiclesCalled, isTrue);
  // });
}
