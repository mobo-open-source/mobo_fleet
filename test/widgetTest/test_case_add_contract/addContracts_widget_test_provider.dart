import 'package:flutter/cupertino.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_provider.dart';

class FakeAddContractsLogProvider extends AddContractsLogProvider {
  bool saveCalled = false;

  @override
  Future<bool> createContractLog() async {
    saveCalled = true;
    notifyListeners();
    return true;
  }
}
