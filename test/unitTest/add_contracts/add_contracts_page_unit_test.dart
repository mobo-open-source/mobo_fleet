import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'add_contracts_unit_test_provider.dart';

void main() {
  late TestAddContractsLogProvider provider;

  setUp(() {
    provider = TestAddContractsLogProvider();
  });

  // ---------------- Required fields test

  test('No required fields', () async {
    await provider.createContractLog();
    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
    expect(provider.capturedPayload, null);
  });

  test('Initial state is correct', () {
    expect(provider.selectedVehicleId, null);
    expect(provider.canSave, false);
    expect(provider.selectedActivityIndex, 0);
  });

  test("Clearing vehicle text resets selection", () {
    provider.selectedVehicleId = 1;
    provider.vehicleTxtController.text = 'Swift';
    provider.resetData();
    expect(provider.selectedVehicleId, null);
    expect(provider.canSave, false);
  });

  test('resetData clears all fields', () {
    provider.referenceTxtController.text = 'REF123';
    provider.selectedVehicleId = 5;

    provider.resetData();

    expect(provider.referenceTxtController.text, '');
    expect(provider.selectedVehicleId, null);
    expect(provider.selectedActivityIndex, 0);
  });

  test('Activity tab switching works', () {
    provider.setSelectedActivityLog(2);
    expect(provider.selectedActivityIndex, 2);
  });

  test('Vehicle selected but no start date', () async {
    provider.selectedVehicleId = 10;
    await provider.createContractLog();
    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
  });

  test('Only Required fields', () async {
    provider.selectedVehicleId = 10;
    provider.contractStartDateTxtController.text = '2025-01-01';
    await provider.createContractLog();
    expect(provider.validationFailed, false);
    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['vehicle_id'], 10);
    expect(provider.capturedPayload!['start_date'], '2025-01-01');
  });

  test('Success with fields', () async {
    provider.selectedVehicleId = 5;
    provider.contractStartDateTxtController.text = '2025-02-01';
    provider.activationCostTxtController.text = '500';
    provider.recurringCostTxtController.text = '100';
    await provider.createContractLog();
    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['amount'], 500.0);
    expect(provider.capturedPayload!['cost_generated'], 100.0);
  });
}
