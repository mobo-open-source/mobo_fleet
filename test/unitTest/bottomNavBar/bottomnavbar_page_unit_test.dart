import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/bottom_navigation_bar/bottom_navigation_bar_provider.dart';

void main() {
  group('Bottom Navigation Bar Unit Tests', () {
    late BottomNavigationBarProvider provider;

    setUp(() {
      provider = BottomNavigationBarProvider();
    });

    test('Initial index - 0', () {
      expect(provider.index, 0);
    });

    test('Index should update when screenIndex is called', () {
      provider.screenIndex(1);
      expect(provider.index, 1);
      provider.screenIndex(2);
      expect(provider.index, 2);
      provider.screenIndex(3);
      expect(provider.index, 3);
    });

    test('notifyListeners is called', () {
      bool listenerCalled = false;
      provider.addListener(() {
        listenerCalled = true;
      });
      provider.screenIndex(1);
      expect(listenerCalled, true);
      provider.screenIndex(2);
      expect(listenerCalled, true);
      provider.screenIndex(3);
      expect(listenerCalled, true);
    });

    test('Index resets to 0 on logoutReset', () {
      provider.screenIndex(3);
      provider.clearOnLogout();
      expect(provider.index, 0);
    });
  });
}
