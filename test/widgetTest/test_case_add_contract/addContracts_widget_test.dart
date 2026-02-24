import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_page.dart';
import 'package:mobo_projects/features/add_contracts/add_contracts_log_provider.dart';
import 'package:provider/provider.dart';
import 'addContracts_widget_test_provider.dart';

void main() {
  Widget createTestWidget(FakeAddContractsLogProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<AddContractsLogProvider>.value(
        value: provider,
        child: const AddContractsLogPage(),
      ),
    );
  }

  testWidgets("AddContractsLogPage loads and shows title", (tester) async {
    final fakeProvider = FakeAddContractsLogProvider();

    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();

    expect(find.text('Create Contracts Log'), findsOneWidget);
  });

  testWidgets('Tabs switch correctly', (tester) async {
    final fakeProvider = FakeAddContractsLogProvider();

    await tester.pumpWidget(createTestWidget(fakeProvider));
    await tester.pump();

    expect(find.text('Vehicle'), findsWidgets);

    final costTab = find.text('Cost');
    await tester.ensureVisible(costTab);
    await tester.tap(costTab);
    await tester.pump();

    expect(find.text('Activation Cost'), findsOneWidget);

    final termsTab = find.text('Terms and Conditions');
    await tester.ensureVisible(termsTab);
    await tester.tap(termsTab);
    await tester.pump();

    expect(
      find.textContaining('Write here all other information'),
      findsOneWidget,
    );
  });
}
