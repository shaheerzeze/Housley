import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housely/app/housely_app.dart';
import 'package:housely/design_system/components/buttons.dart';
import 'package:housely/features/access/access_draft.dart';
import 'package:housely/features/access/household_member.dart';

Future<void> confirmDetectedTenancyMemberIfNeeded(WidgetTester tester) async {
  final confirmMember = find.widgetWithText(
    HouselyButton,
    'Confirm as tenancy member',
  );

  if (confirmMember.evaluate().isEmpty) return;

  await tester.ensureVisible(confirmMember);
  await tester.tap(confirmMember);
  await tester.pumpAndSettle();
}

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

    final laterButton = find.text('Do this later').last;

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

    final laterButton = find.text('Do this later').last;

    await tester.ensureVisible(laterButton);

    await tester.pumpAndSettle();
    await tester.tap(laterButton);
    await tester.pumpAndSettle();

    expect(find.text('Your tenancy setup is saved'), findsOneWidget);
  });
  testWidgets('tenancy member can open phone connection flow', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);

    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Muhammad Shaheer Shoukathali'));

    await tester.pumpAndSettle();

    final continueButton = find.text('Continue');

    await tester.ensureVisible(continueButton);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    final confirmButton = find.text('Yes, this is me');

    await tester.ensureVisible(confirmButton);

    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);

    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);

    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    expect(find.text('Connect Alex Morgan'), findsOneWidget);

    expect(find.text('Phone number'), findsOneWidget);
  });

  testWidgets('existing Housely user can be found and invited', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Muhammad Shaheer Shoukathali'));
    await tester.pumpAndSettle();

    final firstContinue = find.text('Continue');

    await tester.ensureVisible(firstContinue);
    await tester.tap(firstContinue);
    await tester.pumpAndSettle();

    final confirm = find.text('Yes, this is me');

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);
    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);
    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    final phoneField = find.byType(TextField);

    await tester.enterText(phoneField.last, '+447700900123');

    await tester.pumpAndSettle();

    final findAccountButton = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    expect(findAccountButton, findsOneWidget);

    await tester.ensureVisible(findAccountButton);

    await tester.pumpAndSettle();

    await tester.tap(findAccountButton);

    await tester.pump();

    await tester.pump(const Duration(milliseconds: 700));

    await tester.pumpAndSettle();

    expect(find.text('Housely account found'), findsOneWidget);

    // Now we are on the account-found screen,
    // so the invitation button should exist.
    final sendInviteButton = find.widgetWithText(
      HouselyButton,
      'Send Home invitation',
    );

    expect(sendInviteButton, findsOneWidget);

    await tester.ensureVisible(sendInviteButton);

    await tester.pumpAndSettle();

    await tester.tap(sendInviteButton);

    await tester.pumpAndSettle();

    expect(find.text('Invitation sent'), findsOneWidget);

    expect(find.text('Invite pending'), findsOneWidget);
  });

  testWidgets('unknown phone can create off-app member', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    // Wait for mock tenancy processing.
    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    // Review detected tenancy names.
    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    // Select current user.
    final currentUser = find.text('Muhammad Shaheer Shoukathali');

    await tester.ensureVisible(currentUser);
    await tester.tap(currentUser);
    await tester.pumpAndSettle();

    // Continue to confirmation.
    final firstContinue = find.text('Continue');

    await tester.ensureVisible(firstContinue);
    await tester.tap(firstContinue);
    await tester.pumpAndSettle();

    // Confirm tenancy identity.
    final confirm = find.text('Yes, this is me');

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    // Continue through role/setup.
    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);
    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    // Select Alex.
    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);
    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    expect(find.text('Connect Alex Morgan'), findsOneWidget);

    // Enter a phone number that does NOT
    // belong to our mock Housely user.
    final phoneField = find.byType(TextField);

    expect(phoneField, findsWidgets);

    await tester.enterText(phoneField.last, '+447700888888');

    await tester.pumpAndSettle();

    // Search Housely.
    final findAccountButton = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    expect(findAccountButton, findsOneWidget);

    await tester.ensureVisible(findAccountButton);

    await tester.pumpAndSettle();

    await tester.tap(findAccountButton);

    await tester.pump();

    // Wait for mock lookup.
    await tester.pump(const Duration(milliseconds: 700));

    await tester.pumpAndSettle();

    // Unknown number should reach
    // the account-not-found screen.
    expect(find.text('No Housely account found'), findsOneWidget);

    // Add Alex without a Housely account.
    final addOffAppButton = find.widgetWithText(
      HouselyButton,
      'Add as off-app member',
    );

    expect(addOffAppButton, findsOneWidget);

    await tester.ensureVisible(addOffAppButton);

    await tester.pumpAndSettle();

    await tester.tap(addOffAppButton);

    await tester.pumpAndSettle();

    // Confirmation screen.
    expect(find.text('Off-app member added'), findsOneWidget);

    expect(find.textContaining('Alex Morgan'), findsWidgets);
  });

  testWidgets('pending Home invitation can be accepted', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Muhammad Shaheer Shoukathali'));

    await tester.pumpAndSettle();

    final continueButton = find.text('Continue');

    await tester.ensureVisible(continueButton);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    final confirm = find.text('Yes, this is me');

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);

    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);
    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    await tester.enterText(find.byType(TextField).last, '+447700900123');

    await tester.pumpAndSettle();

    final findAccount = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    expect(findAccount, findsOneWidget);

    await tester.ensureVisible(findAccount);

    await tester.pumpAndSettle();

    // Close the keyboard so it cannot cover the CTA.
    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    await tester.ensureVisible(findAccount);

    await tester.pumpAndSettle();

    await tester.tap(findAccount);

    await tester.pump();

    await tester.pump(const Duration(milliseconds: 700));

    await tester.pumpAndSettle();

    final sendInvite = find.widgetWithText(
      HouselyButton,
      'Send Home invitation',
    );

    await tester.ensureVisible(sendInvite);

    await tester.tap(sendInvite);
    await tester.pumpAndSettle();

    final preview = find.widgetWithText(
      HouselyButton,
      'Preview recipient invitation',
    );

    await tester.ensureVisible(preview);
    await tester.tap(preview);
    await tester.pumpAndSettle();

    expect(find.text('You’ve been invited to a Home'), findsOneWidget);

    final accept = find.widgetWithText(HouselyButton, 'Accept invitation');

    await tester.ensureVisible(accept);
    await tester.tap(accept);
    await tester.pumpAndSettle();

    expect(find.text('Invitation accepted'), findsOneWidget);

    expect(find.text('Alex Morgan is connected'), findsOneWidget);
  });

  testWidgets('pending Home invitation can be declined', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Muhammad Shaheer Shoukathali'));

    await tester.pumpAndSettle();

    final continueButton = find.text('Continue');

    await tester.ensureVisible(continueButton);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    final confirm = find.text('Yes, this is me');

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);

    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);
    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    await tester.enterText(find.byType(TextField).last, '+447700900123');

    await tester.pumpAndSettle();

    final findAccount = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    expect(findAccount, findsOneWidget);

    await tester.ensureVisible(findAccount);

    await tester.pumpAndSettle();

    // Close the keyboard so it cannot cover the CTA.
    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    await tester.ensureVisible(findAccount);

    await tester.pumpAndSettle();

    await tester.tap(findAccount);

    await tester.pump();

    await tester.pump(const Duration(milliseconds: 700));

    await tester.pumpAndSettle();

    final sendInvite = find.widgetWithText(
      HouselyButton,
      'Send Home invitation',
    );

    await tester.ensureVisible(sendInvite);

    await tester.tap(sendInvite);
    await tester.pumpAndSettle();

    final preview = find.widgetWithText(
      HouselyButton,
      'Preview recipient invitation',
    );

    await tester.ensureVisible(preview);
    await tester.tap(preview);
    await tester.pumpAndSettle();

    final decline = find.widgetWithText(HouselyButton, 'Decline invitation');

    await tester.ensureVisible(decline);
    await tester.tap(decline);
    await tester.pumpAndSettle();

    expect(find.text('Invitation declined'), findsOneWidget);

    expect(find.text('Alex Morgan declined'), findsOneWidget);
  });
  testWidgets('connected member access can be changed to Home admin', (
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
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Muhammad Shaheer Shoukathali'));

    await tester.pumpAndSettle();

    final continueButton = find.text('Continue');

    await tester.ensureVisible(continueButton);

    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    final confirm = find.text('Yes, this is me');

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);

    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);
    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    await tester.enterText(find.byType(TextField).last, '+447700900123');

    await tester.pumpAndSettle();

    final findAccount = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    expect(findAccount, findsOneWidget);

    await tester.ensureVisible(findAccount);

    await tester.pumpAndSettle();

    // Close the keyboard so it cannot cover the CTA.
    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    await tester.ensureVisible(findAccount);

    await tester.pumpAndSettle();

    await tester.tap(findAccount);

    await tester.pump();

    await tester.pump(const Duration(milliseconds: 700));

    await tester.pumpAndSettle();

    final sendInvite = find.widgetWithText(
      HouselyButton,
      'Send Home invitation',
    );

    await tester.ensureVisible(sendInvite);

    await tester.tap(sendInvite);
    await tester.pumpAndSettle();

    final preview = find.widgetWithText(
      HouselyButton,
      'Preview recipient invitation',
    );

    await tester.ensureVisible(preview);
    await tester.tap(preview);
    await tester.pumpAndSettle();

    final accept = find.widgetWithText(HouselyButton, 'Accept invitation');

    await tester.ensureVisible(accept);
    await tester.tap(accept);
    await tester.pumpAndSettle();

    final reviewHousehold = find.widgetWithText(
      HouselyButton,
      'Review household',
    );

    await tester.ensureVisible(reviewHousehold);

    await tester.tap(reviewHousehold);
    await tester.pumpAndSettle();

    final connectedAlex = find.text('Alex Morgan');

    await tester.ensureVisible(connectedAlex);

    await tester.tap(connectedAlex);
    await tester.pumpAndSettle();

    expect(find.text('Manage Alex Morgan'), findsOneWidget);

    final homeAdmin = find.text('Home admin');

    await tester.ensureVisible(homeAdmin);
    await tester.tap(homeAdmin);
    await tester.pumpAndSettle();

    final saveAccess = find.widgetWithText(HouselyButton, 'Save access');

    await tester.ensureVisible(saveAccess);

    await tester.tap(saveAccess);
    await tester.pumpAndSettle();

    expect(find.text('Access updated'), findsOneWidget);

    expect(find.text('Role: Home admin'), findsOneWidget);
  });
  testWidgets('can add a normal household member', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Complete tenancy identity setup.
    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    final currentUser = find.text('Muhammad Shaheer Shoukathali');

    await tester.ensureVisible(currentUser);
    await tester.tap(currentUser);
    await tester.pumpAndSettle();

    final firstContinue = find.text('Continue');

    await tester.ensureVisible(firstContinue);
    await tester.tap(firstContinue);
    await tester.pumpAndSettle();

    final confirm = find.text('Yes, this is me');

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);
    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    // We are now on tenancy member review.
    // Use Alex to create an off-app member first,
    // which gives us the management-screen route.
    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);
    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    await tester.enterText(find.byType(TextField).last, '+447700888888');

    await tester.pumpAndSettle();

    final findAccount = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    await tester.ensureVisible(findAccount);

    tester.testTextInput.hide();

    await tester.pumpAndSettle();
    await tester.ensureVisible(findAccount);
    await tester.tap(findAccount);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    final addOffApp = find.widgetWithText(
      HouselyButton,
      'Add as off-app member',
    );

    await tester.ensureVisible(addOffApp);
    await tester.tap(addOffApp);
    await tester.pumpAndSettle();

    final backToHousehold = find.widgetWithText(
      HouselyButton,
      'Back to household',
    );

    await tester.ensureVisible(backToHousehold);
    await tester.tap(backToHousehold);
    await tester.pumpAndSettle();

    expect(find.text('Manage your household'), findsOneWidget);

    // Add new member.
    final addMember = find.widgetWithText(
      HouselyButton,
      'Add household member',
    );

    await tester.ensureVisible(addMember);
    await tester.tap(addMember);
    await tester.pumpAndSettle();

    expect(find.text('Add household member'), findsOneWidget);

    final nameField = find.byType(TextField).first;

    await tester.enterText(nameField, 'John Smith');

    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(HouselyButton, 'Add member');

    expect(addButton, findsOneWidget);

    await tester.ensureVisible(addButton);

    tester.testTextInput.hide();

    await tester.pumpAndSettle();
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Household member added'), findsOneWidget);

    expect(find.text('John Smith'), findsOneWidget);

    expect(find.text('Added as a household member.'), findsOneWidget);
  });

  testWidgets('can add a guest temporary resident', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    // 1. Open tenancy identity matching.
    final reviewMatch = find.text('Review my match');

    expect(reviewMatch, findsOneWidget);

    await tester.ensureVisible(reviewMatch);

    await tester.tap(reviewMatch);

    await tester.pumpAndSettle();

    // 2. Select current user.
    final currentUser = find.text('Muhammad Shaheer Shoukathali');

    expect(currentUser, findsOneWidget);

    await tester.ensureVisible(currentUser);

    await tester.tap(currentUser);

    await tester.pumpAndSettle();

    // 3. Continue to confirmation.
    final firstContinue = find.text('Continue');

    expect(firstContinue, findsOneWidget);

    await tester.ensureVisible(firstContinue);

    await tester.tap(firstContinue);

    await tester.pumpAndSettle();

    // 4. Confirm tenancy identity.
    final confirm = find.text('Yes, this is me');

    expect(confirm, findsOneWidget);

    await tester.ensureVisible(confirm);

    await tester.tap(confirm);

    await tester.pumpAndSettle();

    // 5. Continue through role/setup.
    final roleContinue = find.text('Continue');

    expect(roleContinue, findsOneWidget);

    await tester.ensureVisible(roleContinue);

    await tester.tap(roleContinue);

    await tester.pumpAndSettle();

    // 6. Open Alex connection flow.
    final alex = find.text('Alex Morgan');

    expect(alex, findsOneWidget);

    await tester.ensureVisible(alex);

    await tester.tap(alex);

    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    expect(find.text('Connect Alex Morgan'), findsOneWidget);

    // 7. Enter unknown phone.
    final phoneFields = find.byType(TextField);

    expect(phoneFields, findsWidgets);

    await tester.enterText(phoneFields.last, '+447700888888');

    await tester.pumpAndSettle();

    // 8. Search Housely.
    final findAccount = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    expect(findAccount, findsOneWidget);

    await tester.ensureVisible(findAccount);

    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    await tester.ensureVisible(findAccount);

    await tester.tap(findAccount);

    await tester.pump();

    await tester.pump(const Duration(milliseconds: 700));

    await tester.pumpAndSettle();

    expect(find.text('No Housely account found'), findsOneWidget);

    // 9. Add Alex as off-app member.
    final addOffApp = find.widgetWithText(
      HouselyButton,
      'Add as off-app member',
    );

    expect(addOffApp, findsOneWidget);

    await tester.ensureVisible(addOffApp);

    await tester.tap(addOffApp);

    await tester.pumpAndSettle();

    expect(find.text('Off-app member added'), findsOneWidget);

    // 10. Go to household management.
    final backToHousehold = find.widgetWithText(
      HouselyButton,
      'Back to household',
    );

    expect(backToHousehold, findsOneWidget);

    await tester.ensureVisible(backToHousehold);

    await tester.tap(backToHousehold);

    await tester.pumpAndSettle();

    expect(find.text('Manage your household'), findsOneWidget);

    // 11. Open add household member.
    final addHouseholdMember = find.widgetWithText(
      HouselyButton,
      'Add household member',
    );

    expect(addHouseholdMember, findsOneWidget);

    await tester.ensureVisible(addHouseholdMember);

    await tester.tap(addHouseholdMember);

    await tester.pumpAndSettle();

    expect(find.text('Add household member'), findsOneWidget);

    // 12. Enter guest name.
    final textFields = find.byType(TextField);

    expect(textFields, findsWidgets);

    await tester.enterText(textFields.first, 'Sarah Guest');

    await tester.pumpAndSettle();

    // Hide keyboard BEFORE selecting the role.
    tester.testTextInput.hide();

    await tester.pumpAndSettle();

    // 13. Select guest / temporary resident.
    final guestOption = find.text('Guest / temporary resident');

    expect(guestOption, findsOneWidget);

    await tester.ensureVisible(guestOption);

    await tester.pumpAndSettle();

    await tester.tap(guestOption);

    await tester.pumpAndSettle();

    // Make sure the guest option is still there
    // after selection.
    expect(find.text('Guest / temporary resident'), findsOneWidget);

    // 14. Add the member.
    final addMemberButton = find.widgetWithText(HouselyButton, 'Add member');

    expect(addMemberButton, findsOneWidget);

    await tester.ensureVisible(addMemberButton);

    await tester.pumpAndSettle();

    await tester.tap(addMemberButton);

    await tester.pumpAndSettle();

    // 15. Verify confirmation.
    expect(find.text('Household member added'), findsOneWidget);

    expect(find.text('Sarah Guest'), findsOneWidget);

    expect(find.text('Added as a guest / temporary resident.'), findsOneWidget);
  });
  testWidgets('ordinary household member can be removed', (tester) async {
    await tester.pumpWidget(
      const HouselyApp(initialLocation: '/tenancy-processing'),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Complete tenancy identity setup.
    final reviewMatch = find.text('Review my match');

    await tester.ensureVisible(reviewMatch);
    await tester.tap(reviewMatch);
    await tester.pumpAndSettle();

    final currentUser = find.text('Muhammad Shaheer Shoukathali');

    await tester.ensureVisible(currentUser);
    await tester.tap(currentUser);
    await tester.pumpAndSettle();

    final firstContinue = find.text('Continue');

    await tester.ensureVisible(firstContinue);
    await tester.tap(firstContinue);
    await tester.pumpAndSettle();

    final confirm = find.text('Yes, this is me');

    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    final roleContinue = find.text('Continue');

    await tester.ensureVisible(roleContinue);
    await tester.tap(roleContinue);
    await tester.pumpAndSettle();

    // We are now on tenancy member review.
    // Use Alex to create an off-app member first,
    // which gives us the management-screen route.
    final alex = find.text('Alex Morgan');

    await tester.ensureVisible(alex);
    await tester.tap(alex);
    await tester.pumpAndSettle();

    // A detected document name must be reviewed before phone lookup.
    await confirmDetectedTenancyMemberIfNeeded(tester);

    await tester.enterText(find.byType(TextField).last, '+447700888888');

    await tester.pumpAndSettle();

    final findAccount = find.widgetWithText(
      HouselyButton,
      'Find Housely account',
    );

    await tester.ensureVisible(findAccount);

    tester.testTextInput.hide();

    await tester.pumpAndSettle();
    await tester.ensureVisible(findAccount);
    await tester.tap(findAccount);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    final addOffApp = find.widgetWithText(
      HouselyButton,
      'Add as off-app member',
    );

    await tester.ensureVisible(addOffApp);
    await tester.tap(addOffApp);
    await tester.pumpAndSettle();

    final backToHousehold = find.widgetWithText(
      HouselyButton,
      'Back to household',
    );

    await tester.ensureVisible(backToHousehold);
    await tester.tap(backToHousehold);
    await tester.pumpAndSettle();

    expect(find.text('Manage your household'), findsOneWidget);

    // Add new member.
    final addMember = find.widgetWithText(
      HouselyButton,
      'Add household member',
    );

    await tester.ensureVisible(addMember);
    await tester.tap(addMember);
    await tester.pumpAndSettle();

    expect(find.text('Add household member'), findsOneWidget);

    final nameField = find.byType(TextField).first;

    await tester.enterText(nameField, 'John Smith');

    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(HouselyButton, 'Add member');

    expect(addButton, findsOneWidget);

    await tester.ensureVisible(addButton);

    tester.testTextInput.hide();

    await tester.pumpAndSettle();
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Household member added'), findsOneWidget);

    expect(find.text('John Smith'), findsOneWidget);

    expect(find.text('Added as a household member.'), findsOneWidget);
    final backToHouseholdAfterAdd = find.widgetWithText(
      HouselyButton,
      'Back to household',
    );

    await tester.ensureVisible(backToHouseholdAfterAdd);

    await tester.tap(backToHouseholdAfterAdd);

    await tester.pumpAndSettle();

    expect(find.text('Manage your household'), findsOneWidget);

    final john = find.text('John Smith');

    expect(john, findsOneWidget);

    await tester.ensureVisible(john);
    await tester.tap(john);
    await tester.pumpAndSettle();

    expect(find.text('Manage John Smith'), findsOneWidget);

    final remove = find.widgetWithText(HouselyButton, 'Remove from Home');

    expect(remove, findsOneWidget);

    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();

    expect(find.text('Remove member?'), findsOneWidget);

    final confirmRemove = find.widgetWithText(
      HouselyButton,
      'Remove from Home',
    );

    await tester.ensureVisible(confirmRemove);

    await tester.tap(confirmRemove);

    await tester.pumpAndSettle();

    expect(find.text('Manage your household'), findsOneWidget);

    expect(find.text('John Smith'), findsNothing);
  });
  test(
    'changing tenancy identity reconciles the current member immediately',
    () {
      final draft = AccessDraft()
        ..phone = '+447700900000'
        ..detectedTenantNames.addAll([
          'Muhammad Shaheer Shoukathali',
          'Alex Morgan',
          'Meera Thomas',
        ]);

      draft.setMatchedTenantName('Muhammad Shaheer Shoukathali');
      draft.confirmTenancyIdentity();
      draft.setHomeSetupAdmin(true);

      expect(
        draft.householdMembers
            .singleWhere(
              (member) => member.name == 'Muhammad Shaheer Shoukathali',
            )
            .isCurrentUser,
        isTrue,
      );

      draft.setMatchedTenantName('Alex Morgan');
      draft.confirmTenancyIdentity();
      draft.setHomeSetupAdmin(true);

      final shaheer = draft.householdMembers.singleWhere(
        (member) => member.name == 'Muhammad Shaheer Shoukathali',
      );
      final alex = draft.householdMembers.singleWhere(
        (member) => member.name == 'Alex Morgan',
      );

      expect(shaheer.isCurrentUser, isFalse);
      expect(shaheer.houselyUserId, isNull);
      expect(
        shaheer.tenancyReviewStatus,
        TenancyMemberReviewStatus.needsReview,
      );

      expect(alex.isCurrentUser, isTrue);
      expect(alex.isVerifiedNamedTenant, isTrue);
      expect(alex.houselyUserId, 'current-user');
      expect(alex.appRole, HouseholdAppRole.setupAdmin);
    },
  );

  testWidgets(
    'excluding a detected tenancy person updates the review immediately',
    (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/tenancy-processing'),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      final reviewMatch = find.text('Review my match');
      await tester.ensureVisible(reviewMatch);
      await tester.tap(reviewMatch);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Muhammad Shaheer Shoukathali'));
      await tester.pumpAndSettle();

      final continueButton = find.text('Continue').last;
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      final confirmButton = find.text('Yes, this is me');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      final roleContinue = find.text('Continue').last;
      await tester.ensureVisible(roleContinue);
      await tester.tap(roleContinue);
      await tester.pumpAndSettle();

      final meera = find.text('Meera Thomas');
      expect(meera, findsOneWidget);
      await tester.ensureVisible(meera);
      await tester.tap(meera);
      await tester.pumpAndSettle();

      final exclude = find.widgetWithText(
        HouselyButton,
        'Not part of this household',
      );
      expect(exclude, findsOneWidget);
      await tester.tap(exclude);
      await tester.pumpAndSettle();

      expect(find.text('Meera Thomas'), findsNothing);
      expect(find.text('Review people in your tenancy'), findsOneWidget);
    },
  );
}
