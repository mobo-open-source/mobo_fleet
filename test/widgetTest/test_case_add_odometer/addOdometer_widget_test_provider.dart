import 'package:flutter/cupertino.dart';
import 'package:mobo_projects/features/add_odometer/add_odometer_log_provider.dart';

class FakeOdometerLogProvider extends AddOdometerLogProvider {
  bool odometerSaveCalled = false;

  @override
  Future<bool> createOdometerLog() async {
    odometerSaveCalled = true;
    notifyListeners();
    return true;
  }
}
