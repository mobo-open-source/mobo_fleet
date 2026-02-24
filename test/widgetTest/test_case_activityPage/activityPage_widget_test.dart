import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/activity/activity_page.dart';
import 'package:mobo_projects/features/activity/activity_page_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_provider.dart';
import 'package:mobo_projects/features/admin_permissioncheck/fleet_permission_view.dart';
import 'package:mobo_projects/features/settings/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'activityPage_widget_test_provider.dart';

void main() {
  Widget createTestWidget(ActivityPageProvider provider) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ActivityPageProvider>.value(value: provider),
        ChangeNotifierProvider<FleetPermissionProvider>(
          create: (_) => FleetPermissionProvider()..allowAllForTest(),
        ),
      ],
      child: const MaterialApp(home: ActivityPage(skipPermissionGate: true)),
    );
  }

  Widget createPermissionTestWidget({
    required ActivityPageProvider provider,
    required FleetPermissionProvider permissionProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ActivityPageProvider>.value(value: provider),
        ChangeNotifierProvider<FleetPermissionProvider>.value(
          value: permissionProvider,
        ),
      ],
      child: const MaterialApp(home: ActivityPage(skipPermissionGate: false)),
    );
  }

  testWidgets('Search text updates ActivityPageProvider', (
    WidgetTester tester,
  ) async {
    final fakeProvider = FakeActivityProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final searchField = find.byType(TextFormField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'abc');
    await tester.pump();
    expect(fakeProvider.lastSearchValue, 'abc');
    expect(fakeProvider.refreshCalled, true);
  });

  testWidgets('Clear icon clears search text', (WidgetTester tester) async {
    final fakeProvider = FakeActivityProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final searchField = find.byType(TextFormField);
    await tester.enterText(searchField, 'Petrol');
    await tester.pump();
    final clearIcon = find.byKey(const Key('activity_clear_search'));
    expect(clearIcon, findsOneWidget);
    await tester.tap(clearIcon);
    await tester.pump();
    expect(fakeProvider.searchActivityText.text, '');
  });

  testWidgets("Service filter bottomSheet opens", (WidgetTester tester) async {
    final fakeProvider = FakeActivityProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    fakeProvider.setSelectedActivityLog(2);
    await tester.pump();
    final filterIcon = find.byKey(const Key('activity_filter_select'));
    expect(filterIcon, findsOneWidget);
    await tester.tap(filterIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Filter'), findsOneWidget);
    final archived = find.text('Archived');
    expect(archived, findsOneWidget);
  });

  testWidgets("Contracts filter bottomSheet opens", (
    WidgetTester tester,
  ) async {
    final fakeProvider = FakeActivityProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    fakeProvider.setSelectedActivityLog(3);
    await tester.pump();
    final filterIcon = find.byKey(const Key('activity_filter_select'));
    expect(filterIcon, findsOneWidget);
    await tester.tap(filterIcon);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Filter'), findsOneWidget);
    final expired = find.text('Expired');
    final inProgress = find.text('In progress');
    expect(expired, findsOneWidget);
    expect(inProgress, findsOneWidget);
  });

  testWidgets("Service Filter list", (WidgetTester tester) async {
    final fakeProvider = FakeActivityProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    fakeProvider.setSelectedActivityLog(2);
    await tester.pump();
    final filterIcon = find.byKey(const Key('activity_filter_select'));
    expect(filterIcon, findsOneWidget);
    await tester.tap(filterIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Archived'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(fakeProvider.selectedServiceFilters.contains('Archived'), true);
    await tester.tap(find.text('Apply'));
    await tester.pump();
    expect(fakeProvider.serviceFetchCalled, true);
  });

  testWidgets('Contract Filter List', (WidgetTester tester) async {
    final fakeProvider = FakeActivityProvider();
    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    fakeProvider.setSelectedActivityLog(3);
    await tester.pump();
    final filterIcon = find.byKey(const Key('activity_filter_select'));
    expect(filterIcon, findsOneWidget);
    await tester.tap(filterIcon);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final expired = find.text('Expired');
    final inProgress = find.text('In progress');
    final apply = find.text('Apply');
    await tester.tap(expired);
    await tester.tap(inProgress);
    await tester.pump(const Duration(milliseconds: 300));
    expect(fakeProvider.selectedContractFilters.contains('Expired'), true);
    await tester.tap(apply);
    await tester.pump();
    expect(fakeProvider.contractFetchCalled, true);
  });

  testWidgets('Switching activity tabs', (WidgetTester tester) async {
    final fakeProvider = FakeActivityProvider();

    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fakeProvider.selectedActivityIndex, 0);

    await tester.tap(find.byKey(const Key('activity_tab_1')));
    await tester.pump();
    expect(fakeProvider.selectedActivityIndex, 1);
    expect(fakeProvider.refreshCalled, true);
    fakeProvider.refreshCalled = false;

    await tester.tap(find.byKey(const Key('activity_tab_2')));
    await tester.pump();
    expect(fakeProvider.selectedActivityIndex, 2);
    expect(fakeProvider.refreshCalled, true);
    fakeProvider.refreshCalled = false;

    await tester.tap(find.byKey(const Key('activity_tab_3')));
    await tester.pump();
    expect(fakeProvider.selectedActivityIndex, 3);
    expect(fakeProvider.refreshCalled, true);
  });

  testWidgets('Fleet permission Activity page', (WidgetTester tester) async {
    final fakeProvider = FakeActivityProvider();

    final fakePermission = FleetPermissionProvider()
      ..canAccessFleet = false
      ..checkedOnces = true
      ..isLoading = false;

    await tester.pumpWidget(
      createPermissionTestWidget(
        provider: fakeProvider,
        permissionProvider: fakePermission,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(FleetPermissionView), findsOneWidget);

    expect(find.byKey(const Key('activity_tab_0')), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
  });
}
