import 'package:mobo_projects/features/activity/activity_page_provider.dart';

class FakeActivityProvider extends ActivityPageProvider {
  bool refreshCalled = false;
  bool serviceFetchCalled = false;
  bool contractFetchCalled = false;
  String lastSearchValue = "";

  @override
  void updateSearch(String value) {
    lastSearchValue = value.trim();
    super.updateSearch(value);
  }

  @override
  Future<void> onRefresh() async {
    refreshCalled = true;
  }

  @override
  Future<void> fetchServiceActivityDetails({bool resetPage = false}) async {
    serviceFetchCalled = true;
  }

  @override
  Future<void> fetchContractActivityDetails({bool resetPage = false}) async {
    contractFetchCalled = true;
  }
}
