import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:housely/app/housely_app.dart';
import 'package:housely/data/mvp_app_state.dart';
import 'package:housely/design_system/components/buttons.dart';
import 'package:housely/developer/state_lab_screen.dart';
import 'package:housely/features/access/access_draft.dart';
import 'package:housely/features/access/household_member.dart';
import 'package:housely/features/home/home_state.dart';
import 'package:housely/features/home/home_setup_state.dart';
import 'package:housely/features/mvp/mvp_catalog.dart';

Future<void> _finishStreamlinedTenancyProcessing(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1700));
  await tester.pumpAndSettle();

  expect(find.text('Which name is yours?'), findsOneWidget);
}

Future<void> _reachTenancyNameChoice(WidgetTester tester) async {
  await tester.pumpWidget(
    const HouselyApp(initialLocation: '/tenancy-processing'),
  );

  await _finishStreamlinedTenancyProcessing(tester);
}

Future<void> _claimCreatorAndReachHome(WidgetTester tester) async {
  await _reachTenancyNameChoice(tester);

  final currentUser = find.text('Muhammad Shaheer Shoukathali');
  expect(currentUser, findsOneWidget);

  await tester.ensureVisible(currentUser);
  await tester.tap(currentUser);
  await tester.pumpAndSettle();

  final continueButton = find.widgetWithText(HouselyButton, 'Continue');
  expect(continueButton, findsOneWidget);

  await tester.ensureVisible(continueButton);
  await tester.tap(continueButton);
  await tester.pumpAndSettle();

  expect(find.text('Confirm this is you'), findsOneWidget);

  final confirmButton = find.widgetWithText(
    HouselyButton,
    'Confirm and enter my Home',
  );
  expect(confirmButton, findsOneWidget);

  await tester.ensureVisible(confirmButton);
  await tester.tap(confirmButton);
  await tester.pumpAndSettle();

  expect(find.text('Make George Street Flat ready'), findsOneWidget);
}

Future<void> _reachHouseholdManagement(WidgetTester tester) async {
  await _claimCreatorAndReachHome(tester);

  final manage = find.text('Manage');
  await tester.scrollUntilVisible(
    manage,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();

  await tester.tap(manage);
  await tester.pumpAndSettle();

  expect(find.text('Manage your household'), findsOneWidget);
}

Future<void> _confirmDetectedTenancyMemberIfNeeded(WidgetTester tester) async {
  final confirmMember = find.widgetWithText(
    HouselyButton,
    'Confirm as tenancy member',
  );

  if (confirmMember.evaluate().isEmpty) return;

  await tester.ensureVisible(confirmMember);
  await tester.tap(confirmMember);
  await tester.pumpAndSettle();
}

Future<void> _openAlexConnectionFlow(WidgetTester tester) async {
  await _reachHouseholdManagement(tester);

  final alex = find.text('Alex Morgan');
  expect(alex, findsOneWidget);

  await tester.ensureVisible(alex);
  await tester.tap(alex);
  await tester.pumpAndSettle();

  await _confirmDetectedTenancyMemberIfNeeded(tester);

  expect(find.text('Connect Alex Morgan'), findsOneWidget);
}

Future<void> _lookupAlex(WidgetTester tester, {required String phone}) async {
  await _openAlexConnectionFlow(tester);

  final phoneFields = find.byType(TextField);
  expect(phoneFields, findsWidgets);

  await tester.enterText(phoneFields.last, phone);
  await tester.pumpAndSettle();

  final findAccount = find.widgetWithText(
    HouselyButton,
    'Find Housely account',
  );

  expect(findAccount, findsOneWidget);

  tester.testTextInput.hide();
  await tester.pumpAndSettle();

  await tester.ensureVisible(findAccount);
  await tester.pumpAndSettle();

  final findAccountWidget = tester.widget<HouselyButton>(findAccount);
  expect(findAccountWidget.onPressed, isNotNull);
  findAccountWidget.onPressed!.call();

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 750));
  await tester.pumpAndSettle();
}

void main() {
  group('Offline end-to-end domain journeys', () {
    test('Home setup contains exactly the four agreed milestones', () {
      final state = HomeSetupState();
      expect(state.completedSteps(tenancyComplete: true), 1);

      state.saveRent(amountPence: 85000, dueDay: 1);
      state.addRecurringCost(name: 'Council tax', amountPence: 16500, frequency: 'Monthly');
      state.markHouseholdOpened();
      expect(state.completedSteps(tenancyComplete: true), 3);

      state.markMoveInProtectionStarted();
      expect(state.completedSteps(tenancyComplete: true), 4);
      expect(state.isComplete(tenancyComplete: true), isTrue);
    });

    test('admin invitation updates the household record', () {
      final state = MvpAppState();
      state.invite('Alex Morgan');

      expect(state.members.singleWhere((member) => member.name == 'Alex Morgan').status, 'Invited · Waiting to join');
      expect(state.successTitle, 'Invitation sent');
    });

    test('member and temporary resident cannot access admin actions', () {
      final state = MvpAppState()..selectRole(HouselyRole.member);
      expect(state.canAccess('/invite-person'), isFalse);
      expect(state.canAccess('/propose-change'), isFalse);
      expect(state.canAccess('/split'), isTrue);

      state.selectRole(HouselyRole.temporaryResident);
      expect(state.canAccess('/household-overview'), isFalse);
      expect(state.canAccess('/capture-evidence'), isFalse);
      expect(state.canAccess('/vault'), isTrue);
    });

    test('change approval persists in the central state', () {
      final state = MvpAppState();
      state.approveChange();

      expect(state.changes.first.status, 'Approved');
      expect(state.successTitle, 'Approval recorded');
    });

    test('task completion persists and produces a contextual outcome', () {
      final state = MvpAppState();
      state.completeTask();

      expect(state.tasks.first.complete, isTrue);
      expect(state.successTitle, 'Task completed');
    });

    test('move-out remains blocked until required checks are complete', () {
      final state = MvpAppState()..selectLifecycle(HomeLifecycle.movingOut);
      state.finishMoveOut();
      expect(state.lifecycle, HomeLifecycle.movingOut);

      for (final step in state.moveOutSteps.keys.toList()) {
        if (step != 'Compare move-in evidence') state.setMoveOutStep(step, true);
      }
      expect(state.moveOutReady, isTrue);
      state.finishMoveOut();
      expect(state.lifecycle, HomeLifecycle.archived);
      expect(state.home.scenario, HomeScenario.archived);
    });

    test('notification and recurring payment mutations persist', () {
      final state = MvpAppState();
      state.markNotificationRead(0);
      state.recordCouncilTax();

      expect(state.notifications.first.read, isTrue);
      expect(state.councilTaxPaid, isTrue);
      expect(state.successTitle, 'Payment recorded');
    });

    testWidgets('member is redirected away from an admin-only deep link', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/state-lab'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Member'));
      await tester.pumpAndSettle();
      final router = GoRouter.of(tester.element(find.byType(StateLabScreen)));
      router.go('/invite-person');
      await tester.pumpAndSettle();

      expect(find.text('Access restricted'), findsOneWidget);
    });
  });

  group('Complete MVP interface architecture', () {
    test('every catalogue screen has a unique id and route', () {
      expect(mvpScreenCatalog.length, greaterThanOrEqualTo(70));
      expect(
        mvpScreenCatalog.map((screen) => screen.id).toSet().length,
        mvpScreenCatalog.length,
      );
      expect(
        mvpScreenCatalog.map((screen) => screen.path).toSet().length,
        mvpScreenCatalog.length,
      );
      expect(mvpScreenCatalog.every((screen) => screen.path.startsWith('/')), isTrue);
      expect(mvpScreenCatalog.every((screen) => screen.title.isNotEmpty), isTrue);
      expect(mvpScreenCatalog.every((screen) => screen.subtitle.isNotEmpty), isTrue);
    });

    testWidgets('screen library exposes all MVP product areas', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/mvp-screens'));
      await tester.pumpAndSettle();

      expect(find.text('MVP screen library'), findsOneWidget);
      expect(find.text('Household'), findsOneWidget);
      expect(find.text('Split'), findsOneWidget);
      expect(find.text('Move-in protection'), findsOneWidget);
      expect(find.text('Home changes'), findsOneWidget);
      expect(find.text('Move out'), findsOneWidget);
    });

    testWidgets('privacy centre explains protected household areas', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/privacy-centre'));
      await tester.pumpAndSettle();

      expect(find.text('Privacy centre'), findsOneWidget);
      expect(find.text('Private by default'), findsOneWidget);
      expect(find.textContaining('Landlords cannot see private balances'), findsOneWidget);
    });

    testWidgets('move-out flow has an evidence-first next action', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/move-out-overview'));
      await tester.pumpAndSettle();

      expect(find.text('Your move-out'), findsOneWidget);
      expect(find.text('Continue move-out'), findsOneWidget);
      expect(find.text('Move-in record protected'), findsOneWidget);
    });
  });

  group('Core shell and existing feature regression', () {
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

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Split'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Stuff'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);

      await tester.tap(find.text('Vault'));
      await tester.pumpAndSettle();

      expect(find.text('Recent files'), findsOneWidget);
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
      expect(find.text('Recurring payment'), findsOneWidget);
      expect(find.text('Document'), findsOneWidget);
      expect(find.text('Belonging'), findsOneWidget);

      final scrim = find.byKey(const ValueKey('home-add-scrim'));
      expect(scrim, findsOneWidget);

      final scrimWidget = tester.widget<GestureDetector>(scrim);
      expect(scrimWidget.onTap, isNotNull);
      scrimWidget.onTap!.call();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(find.text('Expense'), findsNothing);
    });

    testWidgets('Split opens the expense creation flow', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/split'));
      await tester.pumpAndSettle();

      expect(find.text('Recent expenses'), findsOneWidget);

      final addExpense = find.widgetWithText(HouselyButton, 'Add expense');
      expect(addExpense, findsOneWidget);
      await tester.ensureVisible(addExpense);
      await tester.pumpAndSettle();
      await tester.tap(addExpense);
      await tester.pumpAndSettle();

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
  });

  group('Account and input UX', () {
    testWidgets('create account uses separated UK phone code', (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/create-account'),
      );
      await tester.pumpAndSettle();

      expect(find.text('+44'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
    });

    testWidgets('start choice exposes create and join Home paths', (
      tester,
    ) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/start-choice'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create a Home'), findsOneWidget);
      expect(find.text('Join a Home'), findsOneWidget);
      expect(find.text('Continue without a Home'), findsNothing);
    });

    testWidgets('postcode automatically uppercases and inserts spacing', (
      tester,
    ) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/create-home'),
      );
      await tester.pumpAndSettle();

      final postcodeField = find.widgetWithText(TextField, 'Postcode');

      await tester.enterText(postcodeField, 'eh142pt');
      await tester.pumpAndSettle();

      expect(find.text('EH14 2PT'), findsOneWidget);
    });

    testWidgets('property details continue to tenancy setup', (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/create-home'),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Home name'),
        'George Street Flat',
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Postcode'),
        'EH2 2LE',
      );

      final manualAddress = find.text('Enter address manually');
      await tester.ensureVisible(manualAddress);
      await tester.tap(manualAddress);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Address line 1'),
        '24 George Street',
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'City'),
        'Edinburgh',
      );

      final continueButton = find.widgetWithText(HouselyButton, 'Continue');

      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();

      final continueWidget = tester.widget<HouselyButton>(continueButton);
      expect(continueWidget.onPressed, isNotNull);
      continueWidget.onPressed!.call();
      await tester.pumpAndSettle();

      expect(find.text('Are you named on the tenancy?'), findsOneWidget);
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
  });

  group('Streamlined creator tenancy onboarding', () {
    testWidgets('tenancy upload exposes document choice', (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/upload-tenancy'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add your tenancy agreement'), findsOneWidget);
      expect(find.text('Choose document'), findsOneWidget);
      expect(find.text('Read agreement'), findsOneWidget);
    });

    testWidgets('mock tenancy upload enables Read agreement', (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/upload-tenancy'),
      );
      await tester.pumpAndSettle();

      final chooseDocument = find.widgetWithText(
        HouselyButton,
        'Choose document',
      );

      await tester.ensureVisible(chooseDocument);
      await tester.pumpAndSettle();
      await tester.tap(chooseDocument);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('tenancy-agreement.pdf'), findsOneWidget);

      final readAgreement = find.widgetWithText(
        HouselyButton,
        'Read agreement',
      );

      expect(readAgreement, findsOneWidget);
    });

    testWidgets('tenancy processing goes directly to name choice', (
      tester,
    ) async {
      await _reachTenancyNameChoice(tester);

      expect(find.text('Muhammad Shaheer Shoukathali'), findsOneWidget);
      expect(find.text('Alex Morgan'), findsOneWidget);
      expect(find.text('Meera Thomas'), findsOneWidget);

      expect(find.text('Review my match'), findsNothing);
      expect(find.text('Review people in your tenancy'), findsNothing);
    });

    testWidgets('creator can select only their own tenancy identity', (
      tester,
    ) async {
      await _reachTenancyNameChoice(tester);

      await tester.tap(find.text('Muhammad Shaheer Shoukathali'));
      await tester.pumpAndSettle();

      final continueButton = find.widgetWithText(HouselyButton, 'Continue');

      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Confirm this is you'), findsOneWidget);
      expect(find.text('Confirm and enter my Home'), findsOneWidget);

      expect(find.text('Alex Morgan'), findsNothing);
      expect(find.text('Meera Thomas'), findsNothing);
    });

    testWidgets('confirming tenancy identity goes directly to Home', (
      tester,
    ) async {
      await _claimCreatorAndReachHome(tester);

      expect(find.text('Make George Street Flat ready'), findsOneWidget);
      expect(find.text('Add your rent'), findsOneWidget);
      expect(find.text('Add recurring payments'), findsOneWidget);
      expect(find.text('Protect your move-in'), findsOneWidget);

      expect(find.text('Your tenancy status is confirmed'), findsNothing);
      expect(find.text('Review people in your tenancy'), findsNothing);
    });

    testWidgets('confirm screen Back returns to name choice', (tester) async {
      await _reachTenancyNameChoice(tester);

      await tester.tap(find.text('Muhammad Shaheer Shoukathali'));
      await tester.pumpAndSettle();

      final continueButton = find.widgetWithText(HouselyButton, 'Continue');
      expect(continueButton, findsOneWidget);
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Confirm this is you'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Which name is yours?'), findsOneWidget);
      expect(find.text('Set up your Home'), findsNothing);
    });

    testWidgets('name choice Back returns to tenancy upload', (tester) async {
      await _reachTenancyNameChoice(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Add your tenancy agreement'), findsOneWidget);
      expect(find.text('Set up your Home'), findsNothing);
    });

    testWidgets('no matching tenancy name can still create Home', (
      tester,
    ) async {
      await _reachTenancyNameChoice(tester);

      final noMatch = find.widgetWithText(
        HouselyButton,
        'None of these are me',
      );

      await tester.ensureVisible(noMatch);
      await tester.tap(noMatch);
      await tester.pumpAndSettle();

      expect(find.text('Your name wasn’t found'), findsOneWidget);

      final createWithoutVerification = find.widgetWithText(
        HouselyButton,
        'Create Home without verification',
      );

      await tester.ensureVisible(createWithoutVerification);
      await tester.tap(createWithoutVerification);
      await tester.pumpAndSettle();

      expect(find.text('Make George Street Flat ready'), findsOneWidget);
    });

    testWidgets('other detected names remain available after creator claim', (
      tester,
    ) async {
      await _claimCreatorAndReachHome(tester);

      final householdTitle = find.text('Household');
      await tester.scrollUntilVisible(
        householdTitle,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Alex Morgan'), findsOneWidget);
      expect(find.text('Meera Thomas'), findsOneWidget);
      expect(find.text('Not joined'), findsNWidgets(2));
    });
  });

  group('Canonical adaptive Home', () {
    testWidgets('normal entry uses the adaptive admin Home', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/home'));
      await tester.pumpAndSettle();

      expect(find.text('August at Home'), findsOneWidget);
      expect(find.text('household commitments'), findsOneWidget);
      expect(find.text('Split'), findsOneWidget);
      expect(find.text('Vault'), findsOneWidget);
      expect(find.text('Stuff'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('legacy Home preview redirects to canonical Home', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/home-preview'));
      await tester.pumpAndSettle();

      expect(find.text('August at Home'), findsOneWidget);
      expect(find.text('household commitments'), findsOneWidget);
    });

    testWidgets('creator enters the adaptive setup variation', (tester) async {
      await _claimCreatorAndReachHome(tester);

      expect(find.text('Make George Street Flat ready'), findsOneWidget);
      expect(find.text('Tenancy connected'), findsOneWidget);
      expect(find.text('Add your rent'), findsOneWidget);
      expect(find.text('Add recurring payments'), findsOneWidget);
      expect(find.text('Protect your move-in'), findsOneWidget);
    });
  });

  group('AccessDraft tenancy state regression', () {
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

        final firstShaheer = draft.householdMembers.singleWhere(
          (member) => member.name == 'Muhammad Shaheer Shoukathali',
        );

        expect(firstShaheer.isCurrentUser, isTrue);

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

    test('detected tenancy people are preserved as separate identities', () {
      final draft = AccessDraft()..phone = '+447700900000';

      draft.setDetectedTenantNames([
        'Muhammad Shaheer Shoukathali',
        'Alex Morgan',
        'Meera Thomas',
      ]);

      draft.setMatchedTenantName('Muhammad Shaheer Shoukathali');
      draft.confirmTenancyIdentity();
      draft.setHomeSetupAdmin(true);

      expect(draft.householdMembers.length, 3);

      final alex = draft.householdMembers.singleWhere(
        (member) => member.name == 'Alex Morgan',
      );

      final meera = draft.householdMembers.singleWhere(
        (member) => member.name == 'Meera Thomas',
      );

      expect(alex.isCurrentUser, isFalse);
      expect(alex.connectionStatus, HouseholdConnectionStatus.notConnected);
      expect(alex.houselyUserId, isNull);

      expect(meera.isCurrentUser, isFalse);
      expect(meera.connectionStatus, HouseholdConnectionStatus.notConnected);
      expect(meera.houselyUserId, isNull);
    });

    test('reprocessing tenancy clears stale identity state', () {
      final draft = AccessDraft()..phone = '+447700900000';

      draft.setDetectedTenantNames([
        'Muhammad Shaheer Shoukathali',
        'Alex Morgan',
      ]);

      draft.setMatchedTenantName('Muhammad Shaheer Shoukathali');
      draft.confirmTenancyIdentity();

      expect(draft.matchedTenantName, isNotNull);
      expect(draft.namedTenantVerified, isTrue);

      draft.setDetectedTenantNames(['New Person', 'Another Person']);

      expect(draft.matchedTenantName, isNull);
      expect(draft.namedTenantVerified, isFalse);
      expect(
        draft.householdMembers.map((member) => member.name),
        containsAll(['New Person', 'Another Person']),
      );
      expect(
        draft.householdMembers.any(
          (member) => member.name == 'Muhammad Shaheer Shoukathali',
        ),
        isFalse,
      );
    });

    test('excluding a non-current detected tenancy person updates state', () {
      final draft = AccessDraft();

      draft.setDetectedTenantNames([
        'Muhammad Shaheer Shoukathali',
        'Alex Morgan',
        'Meera Thomas',
      ]);

      draft.setMatchedTenantName('Muhammad Shaheer Shoukathali');
      draft.confirmTenancyIdentity();

      final meera = draft.householdMembers.singleWhere(
        (member) => member.name == 'Meera Thomas',
      );

      draft.excludeTenancyMember(meera.id);

      expect(
        draft.memberById(meera.id)!.tenancyReviewStatus,
        TenancyMemberReviewStatus.excluded,
      );
    });
  });

  group('Post-onboarding household management regression', () {
    testWidgets('unclaimed tenancy member can open connection flow', (
      tester,
    ) async {
      await _openAlexConnectionFlow(tester);

      expect(find.text('Connect Alex Morgan'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
    });

    testWidgets('existing Housely user can still be found and invited', (
      tester,
    ) async {
      await _lookupAlex(tester, phone: '+447700900123');

      expect(find.text('Housely account found'), findsOneWidget);

      final sendInvite = find.widgetWithText(
        HouselyButton,
        'Send Home invitation',
      );

      await tester.ensureVisible(sendInvite);
      await tester.tap(sendInvite);
      await tester.pumpAndSettle();

      expect(find.text('Invitation sent'), findsOneWidget);
      expect(find.text('Invite pending'), findsOneWidget);
    });

    testWidgets('unknown phone can still create an off-app member', (
      tester,
    ) async {
      await _lookupAlex(tester, phone: '+447700888888');

      expect(find.text('No Housely account found'), findsOneWidget);

      final addOffApp = find.widgetWithText(
        HouselyButton,
        'Add as off-app member',
      );

      await tester.ensureVisible(addOffApp);
      await tester.tap(addOffApp);
      await tester.pumpAndSettle();

      expect(find.text('Off-app member added'), findsOneWidget);
      expect(find.textContaining('Alex Morgan'), findsWidgets);
    });

    testWidgets('normal household member can be added after onboarding', (
      tester,
    ) async {
      await _reachHouseholdManagement(tester);

      final addMember = find.widgetWithText(
        HouselyButton,
        'Add household member',
      );

      await tester.ensureVisible(addMember);
      await tester.tap(addMember);
      await tester.pumpAndSettle();

      expect(find.text('Add household member'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'John Smith');

      tester.testTextInput.hide();
      await tester.pumpAndSettle();

      final addButton = find.widgetWithText(HouselyButton, 'Add member');

      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('Household member added'), findsOneWidget);
      expect(find.text('John Smith'), findsOneWidget);
    });

    testWidgets('guest temporary resident can be added after onboarding', (
      tester,
    ) async {
      await _reachHouseholdManagement(tester);

      final addMember = find.widgetWithText(
        HouselyButton,
        'Add household member',
      );

      await tester.ensureVisible(addMember);
      await tester.tap(addMember);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Sarah Guest');

      tester.testTextInput.hide();
      await tester.pumpAndSettle();

      final guestOption = find.text('Guest / temporary resident');
      expect(guestOption, findsOneWidget);

      await tester.ensureVisible(guestOption);
      await tester.tap(guestOption);
      await tester.pumpAndSettle();

      final addButton = find.widgetWithText(HouselyButton, 'Add member');

      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('Household member added'), findsOneWidget);
      expect(find.text('Sarah Guest'), findsOneWidget);
      expect(
        find.text('Added as a guest / temporary resident.'),
        findsOneWidget,
      );
    });
  });

  group('Adaptive Home variation regression', () {
    testWidgets('State lab previews the member Home variation', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/state-lab'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Active member'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Active member'));
      await tester.scrollUntilVisible(
        find.text('Preview on Home'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Preview on Home'));
      await tester.pumpAndSettle();

      expect(find.text('Your August'), findsOneWidget);
      expect(find.text('your rent share of £850'), findsOneWidget);
      expect(find.text('Manage'), findsNothing);
    });

    testWidgets('household attention opens the relevant member', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/state-lab'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Household attention'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Household attention'));
      await tester.scrollUntilVisible(
        find.text('Preview on Home'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Preview on Home'));
      await tester.pumpAndSettle();

      expect(find.text('Home status'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Alex has not joined yet'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Alex has not joined yet'));
      await tester.pumpAndSettle();
      expect(find.text('Household'), findsWidgets);
    });
  });

  group('Join Home code and QR regression', () {
    testWidgets('Join a Home opens code and QR options', (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/start-choice'),
      );
      await tester.pumpAndSettle();

      final joinHome = find.text('Join a Home');
      expect(joinHome, findsOneWidget);

      await tester.tap(joinHome);
      await tester.pumpAndSettle();

      expect(find.text('Join your household'), findsOneWidget);
      expect(find.text('Home code'), findsOneWidget);
      expect(find.text('Find Home'), findsOneWidget);
      expect(find.text('Scan QR code'), findsOneWidget);
    });

    testWidgets('Home code formats automatically', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/join-home'));
      await tester.pumpAndSettle();

      final codeField = find.widgetWithText(TextField, 'Home code');

      await tester.enterText(codeField, 'hsly7k4p9q');
      await tester.pumpAndSettle();

      expect(find.text('HSLY-7K4P9Q'), findsWidgets);
    });

    testWidgets('valid Home code reaches Home preview', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/join-home'));
      await tester.pumpAndSettle();

      final codeField = find.widgetWithText(TextField, 'Home code');
      await tester.enterText(codeField, 'HSLY-7K4P9Q');
      await tester.pumpAndSettle();

      final findHome = find.widgetWithText(HouselyButton, 'Find Home');

      tester.testTextInput.hide();
      await tester.pumpAndSettle();

      await tester.tap(findHome);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pumpAndSettle();

      expect(find.text('George Street Flat'), findsWidgets);
      expect(find.text('Join this Home'), findsOneWidget);
    });

    testWidgets('invalid Home code shows a safe error', (tester) async {
      await tester.pumpWidget(const HouselyApp(initialLocation: '/join-home'));
      await tester.pumpAndSettle();

      final codeField = find.widgetWithText(TextField, 'Home code');
      await tester.enterText(codeField, 'wrongcode');
      await tester.pumpAndSettle();

      final findHome = find.widgetWithText(HouselyButton, 'Find Home');

      tester.testTextInput.hide();
      await tester.pumpAndSettle();

      await tester.tap(findHome);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pumpAndSettle();

      expect(find.text('Home not found'), findsOneWidget);
      expect(find.text('George Street Flat'), findsNothing);
    });

    testWidgets('invitation link auto-loads its Home code', (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/join-home?code=HSLY-7K4P9Q'),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.pumpAndSettle();

      expect(find.text('George Street Flat'), findsWidgets);
      expect(find.text('Join this Home'), findsOneWidget);
    });

    testWidgets('QR scanner exposes centered Go back action', (tester) async {
      await tester.pumpWidget(
        const HouselyApp(initialLocation: '/scan-home-qr'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Go back'), findsOneWidget);
    });
  });
}
