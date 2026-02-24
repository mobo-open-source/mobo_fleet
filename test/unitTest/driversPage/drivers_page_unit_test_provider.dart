import 'package:mobo_projects/features/drivers/drivers_page_provider.dart';

class TestDriversProvider extends DriversPageProvider {
  bool fetchCalled = false;
  int fetchCallCount = 0;

  @override
  Future<void> fetchDrivers({bool resetPage = false}) async {
    fetchCalled = true;
    fetchCallCount++;

    if (resetPage) {
      resetPagination();
    }

    setTotalCountForTest(100);
  }

  @override
  Future<void> _fetchPageDataOnly() async {}
}
