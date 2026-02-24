import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'add_odometer_page_unit_test_provider.dart';

void main() {
  late TestAddOdometerLogProvider provider;

  setUp(() {
    provider = TestAddOdometerLogProvider();
  });

  test('Fails when no required fields are provided', () async {
    await provider.createOdometerLog();
    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
    expect(provider.capturedPayload, null);
  });

  test('Fails when vehicle selected,no date', () async {
    provider.selectedVehicleId = 10;
    await provider.createOdometerLog();
    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
  });

  test('Fails when date selected,no vehicle', () async {
    provider.dateController.text = '2025-01-01';
    await provider.createOdometerLog();
    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
  });

  test('Success with only required fields', () async {
    provider.selectedVehicleId = 5;
    provider.dateController.text = '2025-01-01';
    await provider.createOdometerLog();
    expect(provider.validationFailed, false);
    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['vehicle_id'], 5);
    expect(provider.capturedPayload!['date'], '2025-01-01');
    expect(provider.capturedPayload!['value'], null);
  });

  test('Success with required and odometer value', () async {
    provider.selectedVehicleId = 8;
    provider.dateController.text = '2025-02-10';
    provider.odometerValue = 12345.5;
    await provider.createOdometerLog();
    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['value'], 12345.5);
  });

  test('Success with all fields filled', () async {
    provider.selectedVehicleId = 3;
    provider.dateController.text = '2025-03-15';
    provider.odometerValue = 8888;
    provider.selectedDriverId = 22;
    provider.selectedDriverEmployeeId = 99;
    await provider.createOdometerLog();
    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['vehicle_id'], 3);
    expect(provider.capturedPayload!['driver_id'], 22);
    expect(provider.capturedPayload!['driver_employee_id'], 99);
    expect(provider.capturedPayload!['value'], 8888);
  });

  test('Save loading prevents duplicate create', () async {
    provider.selectedVehicleId = 1;
    provider.dateController.text = '2025-04-01';
    provider.isSaveLoading = true;
    await provider.createOdometerLog();
    expect(provider.createCalled, false);
  });
}
