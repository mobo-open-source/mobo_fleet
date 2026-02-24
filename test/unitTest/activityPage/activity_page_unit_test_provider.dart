import 'package:mobo_projects/features/activity/activity_page_provider.dart';

class TestActivityProvider extends ActivityPageProvider {
  bool fetchFuelService = false;
  bool fetchService = false;
  bool fetchOdometer = false;
  bool fetchContract = false;

  void ServiceTotalCount(int value) {
    setServiceTotalCountForTest(value);
  }

  void FuelTotalCount(int value) {
    setFuelTotalCountForTest(value);
  }

  void ContracTotalcount(int value) {
    setContractTotalCountForTest(value);
  }

  void OdometerTotalCount(int value) {
    setOdometerTotalCountForTest(value);
  }

  @override
  Future<void> fetchFuelLogActivity({bool resetPage = false}) async {
    fetchFuelService = true;
    setFuelTotalCountForTest(100);
  }

  @override
  Future<void> fetchOdometerActivityDetails({bool resetPage = false}) async {
    fetchOdometer = true;
    setOdometerTotalCountForTest(100);
  }

  @override
  Future<void> fetchServiceActivityDetails({bool resetPage = false}) async {
    fetchService = true;
    setServiceTotalCountForTest(100);
  }

  @override
  Future<void> fetchContractActivityDetails({bool resetPage = false}) async {
    fetchContract = true;
    setContractTotalCountForTest(100);
  }
}
