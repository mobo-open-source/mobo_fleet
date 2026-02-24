import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/vehicles/vehicles_provider.dart';

import 'vehicles_page_unit_test_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestVehiclesProvider provider;

  setUp(() {
    provider = TestVehiclesProvider();
  });

  tearDown(() {
    provider.dispose();
  });

  group("Vehicles Page Unit Tests", () {
    test('Filters Vehicles', () {
      expect(provider.selectedFilters.isEmpty, true);

      provider.toggleFilter('Car');
      expect(provider.selectedFilters.isNotEmpty, true);

      provider.toggleFilter('Bike');
      expect(provider.selectedFilters.isNotEmpty, true);

      provider.toggleFilter('Car');
      expect(provider.selectedFilters.isNotEmpty, true);

      provider.toggleFilter('Bike');
      expect(provider.selectedFilters.isNotEmpty, false);
    });

    test("No filter applied", () async {
      await provider.applyVehicleTypeFilter();
      expect(provider.lastDomain, []);
    });

    test('Active filter count checking', () {
      provider.toggleFilter('Car');
      provider.toggleFilter('Bike');
      expect(provider.activeFiltersCount, 2);
    });

    test("Clear selected filters", () {
      provider.toggleFilter('Car');
      provider.toggleFilter('Bike');
      provider.clearSelectedFilters();
      expect(provider.selectedFilters.isEmpty, true);
    });

    test('Search controller', () async {
      bool listenerCalled = false;
      provider.addListener(() {
        listenerCalled = true;
      });
      provider.searchFilterController.text = "KA";
      await Future.delayed(Duration.zero);
      expect(listenerCalled, true);
    });

    test('Clear all filters including search', () async {
      provider.toggleFilter('Car');
      provider.toggleFilter('Bike');
      provider.searchFilterController.text = "Abd";
      expect(provider.selectedFilters.isNotEmpty, true);
      provider.clearAllFilter();
      expect(provider.selectedFilters.isNotEmpty, false);
      expect(provider.searchFilterController.text, '');
    });

    test("Filtering Data viewing", () async {
      provider.toggleFilter('Car');
      provider.toggleFilter('Bike');
      await provider.applyVehicleTypeFilter();
      expect(provider.fetchedCalled, true);
      expect(provider.lastDomain, [
        '|',
        ['vehicle_type', '=', 'car'],
        ['vehicle_type', '=', 'bike'],
      ]);
    });

    test("Initial Pagination check", () {
      expect(provider.currentPage, 0);
      expect(provider.canGoPrevious, false);
    });

    test("Can go to the Next Page", () {
      provider.setTotalCountForTest(100);
      expect(provider.canGoNext, true);
    });

    test("next page and fetch data", () async {
      provider.setTotalCountForTest(100);
      await provider.nextPage();
      expect(provider.currentPage, 1);
      expect(provider.fetchedCalled, true);
    });

    test("previous page ", () async {
      provider.setTotalCountForTest(100);
      await provider.nextPage();
      expect(provider.fetchedCalled, true);
      await provider.previousPage();
      expect(provider.currentPage, 0);
      expect(provider.fetchedCalled, true);
    });

    test("no previous page", () async {
      provider.setTotalCountForTest(100);
      await provider.previousPage();
      expect(provider.currentPage, 0);
      expect(provider.fetchedCalled, false);
    });
  });
}
