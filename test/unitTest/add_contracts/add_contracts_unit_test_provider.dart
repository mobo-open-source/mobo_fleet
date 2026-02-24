import 'package:flutter/material.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_provider.dart';

class TestAddContractsLogProvider extends AddContractsLogProvider {
  bool createCalled = false;
  bool validationFailed = false;
  Map<String, dynamic>? capturedPayload;

  @override
  Future<bool> createContractLog() async {
    if (isSaveLoading) return false;

    if (selectedVehicleId == null || contractStartDateTxtController.text.isEmpty) {
      validationFailed = true;
      return false;
    }

    isSaveLoading = true;
    notifyListeners();

    capturedPayload = {
      'vehicle_id': selectedVehicleId,
      'start_date': contractStartDateTxtController.text,
      'amount': double.tryParse(activationCostTxtController.text) ?? 0.0,
      'cost_generated': double.tryParse(recurringCostTxtController.text) ?? 0.0,
    };

    createCalled = true;

    isSaveLoading = false;
    notifyListeners();

    return true;
  }
}
