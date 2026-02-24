import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'add_vehicle_page_unit_test_provider.dart';

void main() {
  late TestVehiclesDetailsProvider provider;

  setUp(() {
    provider = TestVehiclesDetailsProvider();
  });

  test('No required fields', () async {
    await provider.addNewVehicleDetails();
    expect(provider.validationFailed, true);
    expect(provider.addCalled, false);
    expect(provider.capturedPayload, null);
  });

  test('Only required field', () async {
    provider.vehicleController.text = 'Honda City';
    await provider.addNewVehicleDetails();
    expect(provider.validationFailed, false);
    expect(provider.addCalled, true);
    expect(provider.capturedPayload!['model'], 'Honda City');
  });

  test('All fields filled', () async {
    provider.vehicleController.text = 'Tesla Model 3';
    provider.licensePlateController.text = 'KL-11-AB-1234';
    provider.locationController.text = 'Calicut';
    provider.lastOdometerController.text = '1200';
    provider.horsePowerTaxationController.text = '34';

    await provider.addNewVehicleDetails();

    expect(provider.addCalled, true);
    expect(provider.capturedPayload!['odometer'], 1200.0);
    expect(provider.capturedPayload!['horsepower_tax'], 34.0);
  });

  test('Update vehicle', () async {
    provider.vehicleController.text = 'BMW';
    await provider.updateVehicleDetails();
    expect(provider.updateCalled, true);
  });
}
