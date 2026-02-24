import 'package:flutter_test/flutter_test.dart';
import 'drivers_page_unit_test_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestDriversProvider provider;

  setUp(() {
    provider = TestDriversProvider();
  });

  tearDown(() {
    provider.dispose();
  });

  group("Drivers Page Unit Tests", () {
    test("Pagination Next page", () async {
      provider.setTotalCountForTest(100);
      await provider.nextPage();
      expect(provider.currentPage, 1);
    });
  });

  test("pagination previous page", () async {
    provider.setTotalCountForTest(100);
    await provider.nextPage();
    await provider.previousPage();
    expect(provider.currentPage, 0);
  });

  test("Update Driver Search", () async {
    provider.updateDriverSearch("abcde");
    await Future.delayed(Duration(milliseconds: 300));
    expect(provider.fetchCalled, true);
    expect(provider.currentPage, 0);
  });
}
