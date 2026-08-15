import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/app/housely_app.dart';

void main() {
  testWidgets('accessibility review exposes the Phase 13 checks', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/accessibility-review'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accessibility review'), findsOneWidget);
    expect(find.text('Content remains usable at 200% text'), findsOneWidget);
    expect(find.text('Preview 200% text on Home'), findsOneWidget);
  });

  testWidgets('wide layouts use an adaptive side rail', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HouselyApp(initialLocation: '/home'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('state lab switches the live Home screen to an empty state', (
    tester,
  ) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/state-lab'));
    await tester.pumpAndSettle();

    expect(find.text('State lab'), findsOneWidget);
    await tester.ensureVisible(find.text('Empty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empty'));
    await tester.ensureVisible(find.text('Preview on Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preview on Home'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Return to populated state'), findsOneWidget);
  });

  testWidgets('welcome opens account creation', (tester) async {
    await tester.pumpWidget(const HouselyApp());
    await tester.pumpAndSettle();

    expect(find.text('Your home, connected.'), findsOneWidget);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('five-tab shell preserves labelled navigation', (tester) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/home'));
    await tester.pumpAndSettle();

    expect(find.text('George Street Flat'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Split'), findsOneWidget);
    expect(find.text('Vault'), findsOneWidget);
    expect(find.text('Stuff'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);

    await tester.tap(find.text('Vault'));
    await tester.pumpAndSettle();
    expect(find.text('Recent files'), findsOneWidget);
  });

  testWidgets('Home attention opens the safe change journey', (tester) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/home'));
    await tester.pumpAndSettle();

    expect(find.text('3 things need\nyour attention'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Alex is leaving'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Alex is leaving'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Review every connected Household record before access changes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Resolve changes'), findsOneWidget);
  });

  testWidgets('Home add menu uses a dismissible scrim and close state', (
    tester,
  ) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/home'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Document'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-menu-scrim')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.text('Expense'), findsNothing);
  });

  testWidgets('Split opens the expense creation flow', (tester) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/split'));
    await tester.pumpAndSettle();

    expect(find.text('Recent expenses'), findsOneWidget);
    await tester.ensureVisible(find.text('Add expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Record the source facts first. You’ll choose participants next.',
      ),
      findsOneWidget,
    );
    expect(find.text('Expense title'), findsOneWidget);
  });

  testWidgets('Vault opens Deposit Guard', (tester) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/vault'));
    await tester.pumpAndSettle();

    expect(find.text('Deposit Guard'), findsOneWidget);
    await tester.tap(find.text('Deposit Guard'));
    await tester.pumpAndSettle();
    expect(find.text('Start move-in record'), findsOneWidget);
  });

  testWidgets('Stuff opens item detail and account is populated', (
    tester,
  ) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/stuff'));
    await tester.pumpAndSettle();

    expect(find.text('Living room sofa'), findsWidgets);
    await tester.tap(find.text('Living room sofa').first);
    await tester.pumpAndSettle();
    expect(find.text('Furniture receipt.pdf'), findsOneWidget);
  });

  testWidgets('Account exposes privacy and data controls', (tester) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/you'));
    await tester.pumpAndSettle();
    expect(find.text('Export your data'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Delete account'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Delete account'), findsOneWidget);
  });
}
