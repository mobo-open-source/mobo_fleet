import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_page.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';
import 'package:provider/provider.dart';

import 'vehicles_details_widget_test_provider.dart';

void main() {
  final fakeProvider = FakeVehiclesProvider();

  Widget createTestWidget(VehiclesDetailsProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<VehiclesDetailsProvider>.value(
        value: provider,
        child: VehiclesDetailsPage(vehicleId: 1, imageBytes: Uint8List(0)),
      ),
    );
  }

  testWidgets("Check Appbar title", (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(fakeProvider));
    String vehicleDetailsAppbar = 'Vehicles Details';
    final appBarTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.text(vehicleDetailsAppbar),
    );
    expect(appBarTitle, findsOneWidget);
  });

  testWidgets("Check Appbar Icons is there", (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(fakeProvider));
    String editIconKey = 'edit_icon_key';
    String popupMenuIcon = 'popup_menu_key';
    final editIcon = find.byKey(Key(editIconKey));
    final popupIcon = find.byKey(Key(popupMenuIcon));
    expect(editIcon, findsOneWidget);
    expect(popupIcon, findsOneWidget);
  });

  testWidgets("Check fields", (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pumpAndSettle();
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("Future Driver"), findsOneWidget);
    expect(find.text("Plan To Change Car"), findsOneWidget);
    expect(find.text("Assignment Date"), findsOneWidget);
    expect(find.text("Category"), findsOneWidget);
    expect(find.text("Order Date"), findsOneWidget);
    expect(find.text("Registration Date"), findsOneWidget);
    expect(find.text("Cancellation Date"), findsOneWidget);
    expect(find.text("Chassis Number"), findsOneWidget);
    expect(find.text("Last Odometer"), findsOneWidget);
    expect(find.text("Fleet Manager"), findsOneWidget);
    expect(find.text("Location"), findsOneWidget);
  });

  testWidgets("Vehicle detail values are shown", (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pumpAndSettle();
    expect(find.text("Driver"), findsOneWidget);
    expect(find.text("Future Driver"), findsOneWidget);
    expect(find.text("drivers"), findsWidgets);
    expect(find.text("futureDrivers"), findsOneWidget);
    expect(find.text("category"), findsOneWidget);
    expect(find.text("locations"), findsOneWidget);
    expect(find.text("vinSn"), findsOneWidget);
  });

  testWidgets("Tax Info fields and values viewing", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget(fakeProvider));
    fakeProvider.setSelectedVehicleDetailsLog(0); // Tax Info tab
    await tester.pumpAndSettle();
    //fields check
    expect(find.text("Tax Info"), findsOneWidget);
    expect(find.text("FISCALITY"), findsOneWidget);
    expect(find.text("Horse Power Taxation"), findsOneWidget);
    expect(find.text("CONTRACT"), findsOneWidget);
    expect(find.text("First Contract Date"), findsOneWidget);
    expect(find.text("Catalog Value (VAT Incl.)"), findsOneWidget);
    expect(find.text("Purchase Value"), findsOneWidget);
    expect(find.text("Residual Value"), findsOneWidget);
    //value check
    expect(fakeProvider.horsePowerTaxationController.text, "34.0");
    expect(fakeProvider.firstContractDateController.text, "2025-09-06");
    expect(fakeProvider.catalogValueController.text, "23.0");
    expect(fakeProvider.purchaseValueController.text, "13.0");
    expect(fakeProvider.residualValueController.text, "23.0");
  });

  testWidgets("Model fields and values viewing", (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pumpAndSettle();
    final modelTab = find.byKey(
      const Key("test_case_switch_vehicleDetails_model_key"),
    );
    await tester.ensureVisible(modelTab);
    await tester.tap(modelTab);
    await tester.pumpAndSettle();
    final modelScrollView = find.byKey(const Key("test_case_model_widget_key"));
    expect(modelScrollView, findsOneWidget);
    await tester.drag(modelScrollView, const Offset(0, -300));
    await tester.pumpAndSettle();
    //field checks
    expect(find.text("MODEL"), findsOneWidget);
    expect(find.text("Model Year"), findsOneWidget);
    expect(find.text("Color"), findsOneWidget);
    expect(find.text("Seating Capacity"), findsOneWidget);
    expect(find.text("Number of Doors"), findsOneWidget);
    expect(find.text("Trailer Hitch"), findsOneWidget);
    expect(find.text("Fuel Type"), findsOneWidget);
    expect(find.text("Transmission Type"), findsOneWidget);
    expect(find.text("Power"), findsOneWidget);
    expect(find.text("Range"), findsOneWidget);
    expect(find.text("CO₂ Emissions"), findsOneWidget);
    expect(find.text("Emission Standard"), findsOneWidget);
    //field values
    expect(fakeProvider.modelColorController.text, "Red");
    expect(fakeProvider.modelYearController.text, "2025");
    expect(fakeProvider.modelSeatingCapacityController.text, 5.toString());
    expect(fakeProvider.modelNoOfDoorsController.text, 4.toString());
    expect(fakeProvider.engineFuelTypeController.text, "fuelType");
    expect(fakeProvider.engineTransmissionController.text, "transmission");
    expect(fakeProvider.enginePowerController.text, '67.0');
    expect(fakeProvider.engineRangeController.text, '5');
    expect(fakeProvider.engineC02EmissionController.text, '78.0');
    expect(fakeProvider.engineEmissionStandardController.text, "co2Standard");
  });

  testWidgets("Notes fields and values viewing", (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pumpAndSettle();
    final notesTab = find.byKey(
      const Key("test_case_switch_vehicleDetails__notes_key"),
    );
    await tester.ensureVisible(notesTab);
    await tester.tap(notesTab);
    await tester.pumpAndSettle();
    expect(fakeProvider.vehicleDetailsNotes.text, "description");
  });

  testWidgets("Edit Tax Info fields and update", (WidgetTester tester) async {
    final fakeDashboardProvider = FakeDashboardProvider();
    final vehiclesProvider = VehiclesProvider();
    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<VehiclesDetailsProvider>.value(
            value: fakeProvider,
          ),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: fakeDashboardProvider,
          ),

          ChangeNotifierProvider<VehiclesProvider>(
            create: (_) => vehiclesProvider,
          ),
        ],
        child: MaterialApp(
          home: VehiclesDetailsPage(vehicleId: 1, imageBytes: Uint8List(0)),
        ),
      );
    }

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    fakeProvider.setSelectedVehicleDetailsLog(0);
    await tester.pumpAndSettle();

    final editIcon = find.byKey(const Key('edit_tax_info_icon'));
    expect(editIcon, findsOneWidget);

    await tester.ensureVisible(editIcon);
    await tester.pumpAndSettle();

    await tester.tap(editIcon);
    await tester.pumpAndSettle();
    expect(fakeProvider.horsePowerTaxationController.text, '34.0');

    fakeProvider.horsePowerTaxationController.text = '50';
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(fakeProvider.catalogValueController.text, '23.0');
    expect(fakeProvider.isTaxInfoEdit, isTrue);
    fakeProvider.horsePowerTaxationController.text = '50';
    fakeProvider.catalogValueController.text = '100';
    await tester.pumpAndSettle();
    final updateButton = find.text('Update');
    await tester.ensureVisible(updateButton);
    await tester.tap(updateButton);
    await tester.pumpAndSettle();
    expect(fakeProvider.updateCalled, isTrue);
    expect(fakeProvider.horsePowerTaxationController.text, '50');
    expect(fakeProvider.catalogValueController.text, '100');
  });
}
