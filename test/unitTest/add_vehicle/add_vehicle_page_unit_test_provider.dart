import 'package:flutter/widgets.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';

class TestVehiclesDetailsProvider extends VehiclesDetailsProvider {
  bool addCalled = false;
  bool updateCalled = false;
  bool validationFailed = false;
  Map<String, dynamic>? capturedPayload;

  @override
  bool validateVehicleModel() {
    if (vehicleController.text.trim().isEmpty) {
      validationFailed = true;
      return false;
    }
    return true;
  }

  @override
  Future<bool> addNewVehicleDetails() async {
    if (!validateVehicleModel()) return false;

    capturedPayload = {
      'model': vehicleController.text,
      'license_plate': licensePlateController.text,
      'location': locationController.text,
      'odometer': double.tryParse(lastOdometerController.text) ?? 0.0,
      'horsepower_tax':
          double.tryParse(horsePowerTaxationController.text) ?? 0.0,
    };

    addCalled = true;
    return true;
  }

  @override
  Future<bool> updateVehicleDetails() async {
    if (!validateVehicleModel()) return false;

    updateCalled = true;
    return true;
  }
}
