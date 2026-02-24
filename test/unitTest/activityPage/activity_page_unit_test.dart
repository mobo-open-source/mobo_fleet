import 'package:flutter_test/flutter_test.dart';

import 'activity_page_unit_test_provider.dart';

void main() {
  late TestActivityProvider provider;

  setUp(() {
    provider = TestActivityProvider();
  });

  test('Service filter working', () {
    provider.toggleServiceFilter('Archived');
    expect(provider.selectedServiceFilters.contains('Archived'), true);
    provider.toggleServiceFilter('Archived');
    expect(provider.selectedServiceFilters.isEmpty, true);
  });

  test('Clear service filters resets', () {
    provider.toggleServiceFilter('Archived');
    provider.clearServiceFilters();
    expect(provider.selectedServiceFilters.isEmpty, true);
  });

  test("Contracts filter working", () {
    provider.toggleContractFilter('Archived');
    expect(provider.selectedContractFilters.contains('Archived'), true);
    provider.toggleContractFilter('Archived');
    expect(provider.selectedContractFilters.isEmpty, true);
  });

  test('Clear Contracts filter reset', () {
    provider.toggleContractFilter('Archived');
    provider.clearContractFilters();
    expect(provider.selectedContractFilters.isEmpty, true);
  });

  test('Search updates query and resets pages', () {
    provider.updateSearch('diesel');
    expect(provider.searchActivityText.text, 'diesel');
    expect(provider.canFuelPrevious, false);
  });

  test('Service pagination', () async {
    provider.resetServicePagination();
    provider.ServiceTotalCount(80);
    expect(provider.canServiceNext, true);
    await provider.nextServicePage();
    expect(provider.canServicePrevious, true);
  });
}
