import 'package:mobo_projects/models/model_fleet_dashboard_vehicle_data.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';

class FakeVehiclesPageProvider extends VehiclesProvider {
  late List<FleetVehicle> allVehicles;

  FakeVehiclesPageProvider() {
    allVehicles = [
      FleetVehicle(
        id: 1,
        licensePlate: 'licensePlate',
        imageBytes: null,
        tags: [1, 3],
        model: 'model',
        category: 'Car',
        manager: 'manager',
        driver: 'driver',
        driverEmployee: 'driverEmployee',
        futureDriver: 'futureDriver',
        futureDriverEmployee: 'futureDriverEmployee',
        vinSn: 'vinSn',
        co2: 9.0,
        acquisitionDate: 'acquisitionDate',
        tagIds: [1, 4],
        state: 'state',
        contractRenewalDueSoon: 'contractRenewalDueSoon',
        contractRenewalOverdue: 'contractRenewalOverdue',
        contractState: 'contractState',
      ),
      FleetVehicle(
        id: 2,
        licensePlate: "licensePlate2",
        imageBytes: null,
        tags: [2, 4],
        model: 'model2',
        category: 'Bike',
        manager: 'manager2',
        driver: 'driver2',
        driverEmployee: 'driverEmployee2',
        futureDriver: 'futureDriver2',
        futureDriverEmployee: 'futureDriverEmployee2',
        vinSn: 'vinSn2',
        co2: 8.0,
        acquisitionDate: 'acquisitionDate2',
        tagIds: [2, 3],
        state: 'state2',
        contractRenewalDueSoon: 'contractRenewalDueSoon2',
        contractRenewalOverdue: 'contractRenewalOverdue2',
        contractState: 'contractState2',
      ),
    ];

    filteredVehicles = List.from(allVehicles);
    isLoading = false;
    hasLoadedOnce = true;
  }

  @override
  Future<void> fetchUserDetails() async {}

  @override
  Future<void> filterVehicleModel() async {}

  @override
  Future<void> filterDriverModel() async {}

  @override
  Future<void> fetchVehiclesPageData() async {
    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> fetchVehicles({
    List<dynamic> domain = const [],
    bool resetPage = false,
    bool fetchCount = false,
  }) async {
    List<FleetVehicle> result = List.from(allVehicles);

    final query = searchFilterController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((v) {
        return v.licensePlate.toLowerCase().contains(query) ||
            v.model.toLowerCase().contains(query) ||
            v.driver.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedFilters.contains("Car")) {
      result = result.where((v) => v.category == "Car").toList();
    }
    if (selectedFilters.contains("Bike")) {
      result = result.where((v) => v.category == "Bike").toList();
    }
    filteredVehicles = result;
    notifyListeners();
  }

  @override
  int get totalCount => filteredVehicles.length;

  @override
  int get currentPage => 0;
}
