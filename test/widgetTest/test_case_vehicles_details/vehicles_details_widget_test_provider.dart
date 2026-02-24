import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/models/model_fleet_vehicle_details.dart';
import 'package:mobo_projects/features/dashboard/dashboard_provider.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';
import 'package:mobo_projects/features/vehicles_details/vehicles_details_provider.dart';

class FakeVehiclesProvider extends VehiclesDetailsProvider {
  bool disableNavigation = true;

  bool addVehiclesCalled = false;
  bool updateCalled = false;

  FakeVehiclesProvider() {
    isVehicleDetailsLoading = false;
    setVehicleTypeForTest('car');
    vehicleId = null;
    selectedVehicleDetailsIndex = 0;

    modelFleetVehicleDetails = ModelFleetVehicleDetails(
      length: 1,
      records: [
        VehicleItem(
          id: 1,
          licensePlate: 'licensePlate',
          displayName: 'displayName',
          active: true,
          state: ListConvert(name: "state", id: 1),
          model: ListConvert(name: "model", id: 1),
          driver: ListConvert(name: "drivers", id: 1),
          driverEmployee: ListConvert(name: "DriverEmployees", id: 1),
          futureDriver: ListConvert(name: "futureDrivers", id: 1),
          futureDriverEmployee: ListConvert(
            name: "futureDriverEmployee",
            id: 1,
          ),
          category: ListConvert(name: "category", id: 1),
          manager: ListConvert(name: "manager", id: 1),
          company: ListConvert(name: "company", id: 1),
          currency: ListConvert(name: "company", id: 1),
          billCount: 7,
          historyCount: 5,
          contractCount: 2,
          serviceCount: 54,
          odometerCount: 56,
          vehicleType: 'vehicleType',
          fuelType: 'fuelType',
          transmission: 'transmission',
          color: 'Red',
          location: 'locations',
          countryCode: 'countryCodes',
          mobilityCard: 'mobilityCards',
          vinSn: 'vinSn',
          odometer: 87,
          odometerUnit: 'odometerUnit',
          carValue: 23.0,
          netCarValue: 13.0,
          residualValue: 23.0,
          horsepowerTax: 34.0,
          power: 67.0,
          powerUnit: 'powerUnit',
          horsepower: 78,
          vehicleRange: 5,
          rangeUnit: 'rangeUnit',
          co2: 78,
          co2EmissionUnit: 'co2EmissionUnit',
          co2Standard: 'co2Standard',
          writeDate: DateTime(2025, 9, 6),
          nextAssignationDate: DateTime(2025, 9, 6),
          orderDate: DateTime(2025, 9, 6),
          acquisitionDate: DateTime(2025, 9, 6),
          writeOffDate: DateTime(2025, 9, 6),
          contractDateStart: DateTime(2025, 9, 6),
          modelYear: '2025',
          seats: 5,
          doors: 4,
          planToChangeCar: planToChangeCar,
          planToChangeBike: planToChangeBike,
          trailerHook: true,
          frameType: 'frameType',
          frameSize: 67,
          electricAssistance: true,
          tagIds: [],
          description: 'description',
        ),
      ],
    );
    reassignFromModel();

    vehicleTags = [];
  }

  @override
  void initializeAddVehicle() {}

  @override
  Future<bool> updateVehicleDetails() async {
    updateCalled = true;
    return true;
  }

  @override
  Future<bool> addNewVehicleDetails() async {
    addVehiclesCalled = true;
    return true;
  }

  @protected
  void setVehicleTypeForTest(String type) {
    selectedVehicleType = type;
  }

  @override
  Future<void> fetchVehicleDetails(int id) async {}

  @override
  Future<void> loadFuelTypes() async {}
}

class FakeDashboardProvider extends DashboardProvider {
  @override
  void dispose() {}
  Future<void> refreshDashboard(BuildContext context) async {}
}

class FakeBuildContext extends Fake implements BuildContext {}

class FakeVehiclesListProvider extends VehiclesProvider {
  @override
  Future<void> fetchVehicles({
    List<dynamic> domain = const [],
    bool fetchCount = false,
    bool resetPage = false,
  }) async {}
}
