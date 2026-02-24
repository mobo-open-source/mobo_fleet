import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';

class TestVehiclesProvider extends VehiclesProvider {
  List<dynamic>? lastDomain;
  bool fetchedCalled = false;

  TestVehiclesProvider() {
    searchFilterController.addListener(onSearchChanged);
  }

  @override
  Future<void> fetchUserDetails() async {}

  @override
  Future<void> filterVehicleModel() async {}

  @override
  Future<void> filterDriverModel() async {}

  @override
  Future<void> fetchVehicles({
    List<dynamic> domain = const [],
    bool resetPage = false,
    bool fetchCount = false,
  }) async {
    lastDomain = domain;
    fetchedCalled = true;
    notifyListeners();
  }
}
