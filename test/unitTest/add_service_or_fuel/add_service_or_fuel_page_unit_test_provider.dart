import 'package:flutter/material.dart';
import 'package:mobo_projects/features/add_service_fuel/add_service_fuel_log_provider.dart';

class TestAddFuelLogProvider extends AddServiceFuelLogProvider {
  bool createCalled = false;
  bool validationFailed = false;
  Map<String, dynamic>? capturedPayload;

  @override
  Future<bool> createServiceLog() async {
    if (isSaveLoading) return false;

    if (!validateRequiredFields()) {
      validationFailed = true;
      return false;
    }

    isSaveLoading = true;
    notifyListeners();

    capturedPayload = {
      'vehicle_id': selectedVehicle?.id,
      'service_type_id': selectedServiceType?.id,
      'odometer': double.tryParse(odometerController.text) ?? 0.0,
      'vendor_id': selectedVendor?.id,
      'purchaser_id': selectedDriver?.id,
      'amount': double.tryParse(costController.text) ?? 0.0,
      'notes': notesController.text,
    };

    createCalled = true;

    isSaveLoading = false;
    notifyListeners();

    return true;
  }
}
