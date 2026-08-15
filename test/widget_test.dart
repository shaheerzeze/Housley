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
  testWidgets('start choice exposes create and join Home paths', (
    tester,
  ) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/start-choice'));

    await tester.pumpAndSettle();

    expect(find.text('Create a Home'), findsOneWidget);
    expect(find.text('Join a Home'), findsOneWidget);

    expect(find.text('Continue without a Home'), findsNothing);
  });
  testWidgets('tenancy status exposes all relationship choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-status'),
    );

    await tester.pumpAndSettle();

    expect(find.text('Yes, I’m named on the tenancy'), findsOneWidget);

    expect(find.text('No, I’m not on the tenancy'), findsOneWidget);

    expect(find.text('I’m not sure'), findsOneWidget);
  });
  testWidgets('property details continue to tenancy setup', (tester) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/create-home'));

    await tester.pumpAndSettle();

    // Enter Home name
    await tester.enterText(
      find.widgetWithText(TextField, 'Home name'),
      'George Street Flat',
    );

    // Enter postcode
    await tester.enterText(
      find.widgetWithText(TextField, 'Postcode'),
      'EH2 2LE',
    );

    // Open manual address fields
    final manualAddressButton = find.text('Enter address manually');

    await tester.ensureVisible(manualAddressButton);
    await tester.pumpAndSettle();

    await tester.tap(manualAddressButton);
    await tester.pumpAndSettle();

    // Enter address
    await tester.enterText(
      find.widgetWithText(TextField, 'Address line 1'),
      '24 George Street',
    );

    await tester.enterText(find.widgetWithText(TextField, 'City'), 'Edinburgh');

    await tester.pumpAndSettle();

    // Make sure the Continue button is actually visible
    final continueButton = find.text('Continue');

    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.text('Are you named on the tenancy?'), findsOneWidget);
  });
  testWidgets('Join a Home opens the safe placeholder', (tester) async {
    await tester.pumpWidget(const HouselyApp(initialLocation: '/start-choice'));

    await tester.pumpAndSettle();

    final joinHome = find.text('Join a Home');

    expect(joinHome, findsOneWidget);

    await tester.tap(joinHome);
    await tester.pumpAndSettle();

    expect(find.text('Join your household'), findsOneWidget);

    expect(
      find.text(
        'You won’t see Household information until your membership has been accepted.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tenancy upload exposes document choice', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/upload-tenancy'),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add your tenancy agreement'), findsOneWidget);

    expect(find.text('Choose document'), findsOneWidget);
  });

  testWidgets('mock tenancy upload enables Continue', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/upload-tenancy'),
    );

    await tester.pumpAndSettle();

    final chooseDocument = find.text('Choose document');

    expect(chooseDocument, findsOneWidget);

    await tester.ensureVisible(chooseDocument);
    await tester.pumpAndSettle();

    await tester.tap(chooseDocument);

    await tester.pump();

    // Fake upload takes 650ms.
    await tester.pump(const Duration(milliseconds: 700));

    await tester.pumpAndSettle();

    expect(find.text('tenancy-agreement.pdf'), findsOneWidget);

    final continueButton = find.text('Continue');

    expect(continueButton, findsOneWidget);

    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();

    await tester.tap(continueButton);

    // Allow the /tenancy-processing route to render.
    // Allow the full mock processing sequence to complete.
    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    expect(find.textContaining('We found'), findsOneWidget);
  });
  testWidgets('tenancy processing reaches detected tenants', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    expect(find.text('Reading your agreement'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    expect(find.textContaining('We found'), findsOneWidget);
  });

  testWidgets('tenant match shows detected tenancy names', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatchButton = find.text('Review my match');

    await tester.ensureVisible(reviewMatchButton);

    await tester.pumpAndSettle();

    await tester.tap(reviewMatchButton);

    await tester.pumpAndSettle();

    expect(find.text('Which name is yours?'), findsOneWidget);

    expect(find.text('Muhammad Shaheer Shoukathali'), findsOneWidget);
  });

  testWidgets('user can confirm detected tenancy identity', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatchButton = find.text('Review my match');

    await tester.ensureVisible(reviewMatchButton);

    await tester.pumpAndSettle();

    await tester.tap(reviewMatchButton);

    await tester.pumpAndSettle();

    await tester.tap(find.text('Muhammad Shaheer Shoukathali'));

    await tester.pumpAndSettle();

    final continueButton = find.text('Continue');

    expect(continueButton, findsOneWidget);

    await tester.ensureVisible(continueButton);

    await tester.pumpAndSettle();

    await tester.tap(continueButton);

    await tester.pumpAndSettle();

    expect(find.text('Confirm this is you'), findsOneWidget);

    final confirmButton = find.text('Yes, this is me');

    await tester.ensureVisible(confirmButton);

    await tester.pumpAndSettle();

    await tester.tap(confirmButton);

    await tester.pumpAndSettle();

    expect(find.text('Your tenancy status is confirmed'), findsOneWidget);
  });
  testWidgets('tenant match supports no matching name', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatchButton = find.text('Review my match');

    await tester.ensureVisible(reviewMatchButton);

    await tester.pumpAndSettle();

    await tester.tap(reviewMatchButton);

    await tester.pumpAndSettle();

    final noMatchButton = find.text('None of these are me');

    await tester.ensureVisible(noMatchButton);

    await tester.pumpAndSettle();

    await tester.tap(noMatchButton);

    await tester.pumpAndSettle();

    expect(find.text('We couldn’t match your name'), findsOneWidget);
  });
  testWidgets('verified tenancy flow reaches setup complete', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.pumpAndSettle();
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Muhammad Shaheer Shoukathali'));

    await tester.pumpAndSettle();

    final continueButton = find.text('Continue');

    await tester.ensureVisible(continueButton);

    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    final confirmButton = find.text('Yes, this is me');

    await tester.ensureVisible(confirmButton);

    await tester.pumpAndSettle();
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);

    await tester.pumpAndSettle();
    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    final laterButton = find.text('Do this later');

    await tester.ensureVisible(laterButton);

    await tester.pumpAndSettle();
    await tester.tap(laterButton);
    await tester.pumpAndSettle();

    expect(find.text('Your tenancy setup is complete'), findsOneWidget);
  });

  testWidgets('unverified tenancy flow can still complete setup', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.pumpAndSettle();
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    final noMatch = find.text('None of these are me');

    await tester.ensureVisible(noMatch);
    await tester.pumpAndSettle();
    await tester.tap(noMatch);
    await tester.pumpAndSettle();

    final continueUnverified = find.text('Continue without verification');

    await tester.ensureVisible(continueUnverified);

    await tester.pumpAndSettle();
    await tester.tap(continueUnverified);

    await tester.pumpAndSettle();

    final laterButton = find.text('Do this later');

    await tester.ensureVisible(laterButton);

    await tester.pumpAndSettle();
    await tester.tap(laterButton);
    await tester.pumpAndSettle();

    expect(find.text('Your tenancy setup is saved'), findsOneWidget);
  });
}
