import 'package:mobo_projects/models/model_driving_history.dart';
import 'package:mobo_projects/models/model_fleet_dashboard_vehicle_data.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';

class FakeDriversPageProvider extends DriversPageProvider {
  String lastSearchQuery = '';
  bool fetchCalled = false;

  FakeDriversPageProvider() : super() {
    isInitialLoad = false;
    isLoading = false;
    modelDriverLists = null;
  }

  @override
  Future<void> fetchDrivers({bool resetPage = false}) async {
    fetchCalled = true;
  }

  @override
  void updateDriverSearch(String query) {
    lastSearchQuery = query;
    fetchCalled = true;
  }

  @override
  Future<void> fetchVehicles({bool force = false}) async {
    modelFleetDashboardVehicleData = ModelFleetDashboardVehicleData.fromJson([
      {
        "id": 1,
        "model": "Toyota",
        "license_plate": "KL-11-AA-1234",
        "driver": [10, "Alex"],
      },
    ]);
    notifyListeners();

    notifyListeners();
  }

  @override
  Future<void> fetchDrivingHistory({bool force = false}) async {
    modelDrivingHistory = ModelDrivingHistory.fromJson({
      "length": 1,
      "records": [
        {
          "id": 1,
          "vehicle_id": [1, "Toyota"],
          "driver_id": [10, "Alex"],
          "date_start": "2024-01-01",
          "date_end": "2024-01-10",
          "attachment_number": 0,
        },
      ],
    });
    notifyListeners();
  }

  @override
  Future<void> fetchVehicleDrivingHistory({int? vehicleId}) async {
    drivingHistory = [];
    notifyListeners();
  }
}
