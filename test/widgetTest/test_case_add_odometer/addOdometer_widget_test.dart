import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_page.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_provider.dart';
import 'package:provider/provider.dart';
import 'addOdometer_widget_test_provider.dart';

void main() {
  late AddOdometerLogProvider provider;

  setUp(() {
    provider = AddOdometerLogProvider();
  });

  test("Initial state is correct", () {
    expect(provider.selectedVehicleId, null);
    expect(provider.canSave, false);
  });

  test("Clearing vehicle text resets selection", () {
    provider.selectedVehicleId = 1;
    provider.vehicleController.text = "Swirft";
    provider.resetData();
    expect(provider.canSave, false);
  });
}
