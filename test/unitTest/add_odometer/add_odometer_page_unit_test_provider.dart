
import 'package:flutter/material.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_provider.dart';

class TestAddOdometerLogProvider extends AddOdometerLogProvider {
  bool createCalled = false;
  bool validationFailed = false;
  Map<String, dynamic>? capturedPayload;

  @override
  Future<bool> createOdometerLog() async {
    if (isSaveLoading) return false;

    if (!validateRequiredFields()) {
      validationFailed = true;
      return false;
    }

    isSaveLoading = true;
    notifyListeners();

    capturedPayload = {
      "vehicle_id": selectedVehicleId,
      "date": dateController.text,
      "value": odometerValue,
      "driver_id": selectedDriverId,
      "driver_employee_id": selectedDriverEmployeeId,
    };

    createCalled = true;

    isSaveLoading = false;
    notifyListeners();

    return true;
  }
}
