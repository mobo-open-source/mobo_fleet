import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobo_projects/models/model_service_type_list.dart';
import 'package:mobo_projects/models/model_vehicles_list.dart' as vehicles;
import 'package:mobo_projects/models/model_vendors_list.dart' as vendors;
import 'package:mobo_projects/models/model_add_log_drivers_list.dart';
import 'add_service_or_fuel_page_unit_test_provider.dart';

void main() {
  late TestAddFuelLogProvider provider;

  setUp(() {
    provider = TestAddFuelLogProvider();
  });

  test('No required fields', () async {
    await provider.createServiceLog();

    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
    expect(provider.capturedPayload, null);
  });

  test('Only Vehicle selected', () async {
    provider.selectedVehicle = _fakeVehicle(id: 1);

    await provider.createServiceLog();

    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
  });

  test('Only service type selected', () async {
    provider.selectedServiceType = _fakeService(id: 10);

    await provider.createServiceLog();

    expect(provider.validationFailed, true);
    expect(provider.createCalled, false);
  });

  test('Only required fields', () async {
    provider.selectedVehicle = _fakeVehicle(id: 2);
    provider.selectedServiceType = _fakeService(id: 20);
    await provider.createServiceLog();
    expect(provider.validationFailed, false);
    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['vehicle_id'], 2);
    expect(provider.capturedPayload!['service_type_id'], 20);
  });

  test('Required and optional fields', () async {
    provider.selectedVehicle = _fakeVehicle(id: 3);
    provider.selectedServiceType = _fakeService(id: 30);
    provider.odometerController.text = '12345';
    provider.costController.text = '500';
    provider.notesController.text = 'Fuel filled';
    await provider.createServiceLog();

    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['odometer'], 12345.0);
    expect(provider.capturedPayload!['amount'], 500.0);
    expect(provider.capturedPayload!['notes'], 'Fuel filled');
  });

  test('All fields filled', () async {
    provider.selectedVehicle = _fakeVehicle(id: 4);
    provider.selectedServiceType = _fakeService(id: 40);
    provider.selectedVendor = _fakeVendor(id: 100);
    provider.selectedDriver = _fakeDriver(id: 200);
    provider.odometerController.text = '888';
    provider.costController.text = '999';
    await provider.createServiceLog();
    expect(provider.createCalled, true);
    expect(provider.capturedPayload!['vendor_id'], 100);
    expect(provider.capturedPayload!['purchaser_id'], 200);
  });

  test('Save loading prevents duplicate create', () async {
    provider.selectedVehicle = _fakeVehicle(id: 5);
    provider.selectedServiceType = _fakeService(id: 50);
    provider.isSaveLoading = true;
    await provider.createServiceLog();
    expect(provider.createCalled, false);
  });
}

// ---------------- FAKE MODELS ----------------

_fakeVehicle({required int id}) => vehicles.VehicleItem(
  id: id,
  licensePlate: 'KL-01-AB-1234',
  vehicleType: 'car',
  model: vehicles.ListConvert(name: 'Swift'),
  driverEmployee: vehicles.ListConvert(name: "driverEmployeeName"),
  state: vehicles.ListConvert(name: "current_state"),
  manager: vehicles.ListConvert(name: "manager"),
  futureDriverEmployee: vehicles.ListConvert(name: "futureDriverEmployee"),
  contractState: "ContractState",
  contractRenewalOverdue: false,
  contractRenewalDueSoon: false,
  co2: 9.0,
  category: vehicles.ListConvert(name: "category"),
  acquisitionDate: "",
  tags: [],
  futureDriver: vehicles.ListConvert(name: "future_driver"),
  active: false,
  company: vehicles.ListConvert(name: "company"),
  driver: vehicles.ListConvert(name: "driver"),
  logDrivers: [],
);

_fakeService({required int id}) =>
    ServiceTypeItem(id: id, name: 'Fuel', category: '');

_fakeVendor({required int id}) => vendors.VendorItem(
  id: id,
  name: 'Vendor',
  email: '',
  avatar128: null,
  phone: '',
  user: vendors.ListConvert(name: '', id: 1),
  vat: '',
  writeDate: DateTime(01, 05, 2025),
);

_fakeDriver({required int id}) =>
    DriverItem(id: id, name: 'Driver', phone: '', email: '');
