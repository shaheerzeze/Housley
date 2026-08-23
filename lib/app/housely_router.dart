import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/housely_repository.dart';
import '../data/mvp_app_state.dart';
import '../developer/accessibility_review_screen.dart';
import '../developer/scenario_gate.dart';
import '../developer/state_lab_screen.dart';
import '../features/access/access_draft.dart';
import '../features/access/access_screens.dart';
import '../features/access/join_home_screens.dart';
import '../features/access/join_home_state.dart';
import '../features/access/streamlined_create_home_flow.dart';
import '../features/home/home_entry_screen.dart';
import '../features/home/home_screens.dart';
import '../features/home/home_setup_state.dart';
import '../features/home/home_state.dart';
import '../features/mvp/mvp_catalog.dart';
import '../features/mvp/mvp_screens.dart';
import '../features/shell/app_shell.dart';
import '../features/split/split_screens.dart';
import '../features/stuff/stuff_screens.dart';
import '../features/vault/vault_screens.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>();
final _splitNavigatorKey = GlobalKey<NavigatorState>();
final _vaultNavigatorKey = GlobalKey<NavigatorState>();
final _stuffNavigatorKey = GlobalKey<NavigatorState>();
final _youNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createHouselyRouter({String initialLocation = '/welcome'}) {
  final draft = AccessDraft();
  final joinHomeState = JoinHomeState();
  final appState = MvpAppState();
  final homeState = appState.home;
  final homeSetupState = HomeSetupState();
  final splitState = appState.split;
  final vaultState = appState.vault;
  final stuffState = appState.stuff;
  final repository = MockHouselyRepository();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: appState,
    redirect: (context, state) {
      if (state.matchedLocation == '/access-restricted') return null;
      return appState.canAccess(state.matchedLocation)
          ? null
          : '/access-restricted';
    },
    routes: [
      GoRoute(
        path: '/access-restricted',
        builder: (context, state) => const RestrictedAccessScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => SignInScreen(draft: draft),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordScreen(draft: draft),
      ),
      GoRoute(
        path: '/password-reset-sent',
        builder: (context, state) => PasswordResetSentScreen(draft: draft),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => CreateAccountScreen(draft: draft),
      ),
      GoRoute(
        path: '/verify-phone',
        builder: (context, state) => VerifyPhoneScreen(draft: draft),
      ),
      GoRoute(
        path: '/start-choice',
        builder: (context, state) => const StartChoiceScreen(),
      ),

      // JOIN HOME — existing code/QR flow stays intact.
      GoRoute(
        path: '/join-home',
        builder: (context, state) => JoinHomeScreen(
          draft: draft,
          state: joinHomeState,
          initialCode: state.uri.queryParameters['code'],
        ),
      ),
      GoRoute(
        path: '/invite-home',
        builder: (context, state) =>
            InviteToHomeScreen(draft: draft, state: joinHomeState),
      ),
      GoRoute(
        path: '/scan-home-qr',
        builder: (context, state) => ScanHomeQrScreen(state: joinHomeState),
      ),
      GoRoute(
        path: '/join-home-preview',
        builder: (context, state) =>
            JoinHomePreviewScreen(draft: draft, state: joinHomeState),
      ),
      GoRoute(
        path: '/join-home-success',
        builder: (context, state) =>
            JoinHomeSuccessScreen(state: joinHomeState),
      ),

      // STREAMLINED CREATE HOME.
      // Existing URLs are retained so the rest of the app does not need to
      // know that the onboarding implementation changed.
      GoRoute(
        path: '/create-home',
        builder: (context, state) => StreamlinedCreateHomeScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenancy-status',
        builder: (context, state) =>
            StreamlinedTenancyStatusScreen(draft: draft),
      ),
      GoRoute(
        path: '/upload-tenancy',
        builder: (context, state) =>
            StreamlinedUploadTenancyScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenancy-processing',
        builder: (context, state) =>
            StreamlinedTenancyProcessingScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenancy-detected',
        builder: (context, state) =>
            StreamlinedClaimTenancyNameScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenant-match',
        builder: (context, state) =>
            StreamlinedClaimTenancyNameScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenant-match-confirm',
        builder: (context, state) =>
            StreamlinedConfirmTenancyIdentityScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenant-match-missing',
        builder: (context, state) =>
            StreamlinedTenancyNameMissingScreen(draft: draft),
      ),

      // Progressive first-Home setup. These are optional, non-blocking routes.
      GoRoute(
        path: '/setup-rent',
        builder: (context, state) => AddRentSetupScreen(
          state: homeSetupState,
          onSaved: () => homeState.selectScenario(HomeScenario.partialAdmin),
        ),
      ),
      GoRoute(
        path: '/setup-recurring',
        builder: (context, state) => AddRecurringSetupScreen(
          state: homeSetupState,
          onSaved: () => homeState.selectScenario(HomeScenario.partialAdmin),
        ),
      ),
      GoRoute(
        path: '/setup-move-in',
        builder: (context, state) => MoveInSetupScreen(
          state: homeSetupState,
          onSaved: () => homeState.selectScenario(
            homeSetupState.isComplete(
              tenancyComplete: draft.tenancySetupComplete,
            )
                ? HomeScenario.activeAdmin
                : HomeScenario.partialAdmin,
          ),
        ),
      ),

      // LEGACY / POST-ONBOARDING HOUSEHOLD MANAGEMENT.
      // These routes remain available because member connection and invitations
      // now belong inside the Home rather than the mandatory creator journey.
      GoRoute(
        path: '/tenancy-role',
        builder: (context, state) => TenancyRoleScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenancy-members-review',
        builder: (context, state) => TenancyMembersReviewScreen(draft: draft),
      ),
      GoRoute(
        path: '/tenancy-complete',
        builder: (context, state) => TenancySetupCompleteScreen(draft: draft),
      ),
      GoRoute(
        path: '/connect-tenant-member',
        builder: (context, state) => ConnectTenantMemberScreen(draft: draft),
      ),
      GoRoute(
        path: '/member-account-found',
        builder: (context, state) => MemberAccountFoundScreen(draft: draft),
      ),
      GoRoute(
        path: '/member-account-not-found',
        builder: (context, state) => MemberAccountNotFoundScreen(draft: draft),
      ),
      GoRoute(
        path: '/off-app-member-added',
        builder: (context, state) => OffAppMemberAddedScreen(draft: draft),
      ),
      GoRoute(
        path: '/member-invite-sent',
        builder: (context, state) => MemberInviteSentScreen(draft: draft),
      ),
      GoRoute(
        path: '/home-invitation',
        builder: (context, state) => HomeInvitationScreen(draft: draft),
      ),
      GoRoute(
        path: '/home-invitation-accepted',
        builder: (context, state) => HomeInvitationAcceptedScreen(draft: draft),
      ),
      GoRoute(
        path: '/home-invitation-declined',
        builder: (context, state) => HomeInvitationDeclinedScreen(draft: draft),
      ),
      GoRoute(
        path: '/invite-members',
        builder: (context, state) => InviteMembersScreen(draft: draft),
      ),
      GoRoute(
        path: '/member-access',
        builder: (context, state) => MemberAccessScreen(draft: draft),
      ),
      GoRoute(
        path: '/member-access-saved',
        builder: (context, state) => MemberAccessSavedScreen(draft: draft),
      ),
      GoRoute(
        path: '/household-management',
        builder: (context, state) => HouseholdManagementScreen(draft: draft),
      ),
      GoRoute(
        path: '/add-household-member',
        builder: (context, state) => AddHouseholdMemberScreen(draft: draft),
      ),
      GoRoute(
        path: '/household-member-added',
        builder: (context, state) => HouseholdMemberAddedScreen(draft: draft),
      ),
      GoRoute(
        path: '/remove-household-member',
        builder: (context, state) => RemoveHouseholdMemberScreen(draft: draft),
      ),
      GoRoute(
        path: '/named-tenant-removal-info',
        builder: (context, state) => NamedTenantRemovalInfoScreen(draft: draft),
      ),

      // Existing Home subflows.
      GoRoute(
        path: '/attention',
        builder: (context, state) => AttentionScreen(state: homeState),
      ),
      GoRoute(
        path: '/household',
        builder: (context, state) => HouseholdScreen(state: homeState),
      ),
      GoRoute(
        path: '/changes',
        builder: (context, state) => ChangesScreen(state: homeState),
      ),
      GoRoute(
        path: '/change-impact',
        builder: (context, state) => ChangeImpactScreen(state: homeState),
      ),
      GoRoute(
        path: '/finish-move-out',
        builder: (context, state) => FinishMoveOutScreen(state: homeState),
      ),
      GoRoute(
        path: '/expense-detail',
        builder: (context, state) => ExpenseDetailPlaceholder(state: homeState),
      ),

      // Split.
      GoRoute(
        path: '/add-expense',
        builder: (context, state) => AddExpenseScreen(state: splitState),
      ),
      GoRoute(
        path: '/choose-people',
        builder: (context, state) => ChoosePeopleScreen(state: splitState),
      ),
      GoRoute(
        path: '/review-expense',
        builder: (context, state) => ReviewExpenseScreen(state: splitState),
      ),
      GoRoute(
        path: '/private-groups',
        builder: (context, state) => PrivateGroupsScreen(state: splitState),
      ),
      GoRoute(
        path: '/record-settlement',
        builder: (context, state) => RecordSettlementScreen(state: splitState),
      ),

      // Vault.
      GoRoute(
        path: '/upload-document',
        builder: (context, state) => UploadDocumentScreen(state: vaultState),
      ),
      GoRoute(
        path: '/document-detail',
        builder: (context, state) => DocumentDetailScreen(state: vaultState),
      ),
      GoRoute(
        path: '/deposit-guard',
        builder: (context, state) => DepositGuardIntroScreen(state: vaultState),
      ),
      GoRoute(
        path: '/deposit-checklist',
        builder: (context, state) => DepositChecklistScreen(state: vaultState),
      ),
      GoRoute(
        path: '/review-lock',
        builder: (context, state) => ReviewLockScreen(state: vaultState),
      ),

      // Stuff.
      GoRoute(
        path: '/add-item',
        builder: (context, state) => AddItemScreen(state: stuffState),
      ),
      GoRoute(
        path: '/set-ownership',
        builder: (context, state) => SetOwnershipScreen(state: stuffState),
      ),
      GoRoute(
        path: '/item-detail',
        builder: (context, state) => ItemDetailScreen(state: stuffState),
      ),

      GoRoute(
        path: '/more',
        builder: (context, state) => const MoreMenuScreen(),
      ),
      GoRoute(
        path: '/state-lab',
        builder: (context, state) => StateLabScreen(
          repository: repository,
          homeState: homeState,
          appState: appState,
        ),
      ),
      GoRoute(
        path: '/accessibility-review',
        builder: (context, state) =>
            AccessibilityReviewScreen(repository: repository),
      ),
      GoRoute(
        path: '/mvp-screens',
        builder: (context, state) => const MvpCatalogScreen(),
      ),
      ...mvpScreenCatalog.map(
        (screen) => GoRoute(
          path: screen.path,
          builder: (context, state) => MvpAccessGate(
            appState: appState,
            path: screen.path,
            child: MvpScreen(spec: screen, appState: appState),
          ),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HouselyAppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  if (draft.homeName.trim().isNotEmpty) {
                    final completed = homeSetupState.completedSteps(
                      tenancyComplete: draft.tenancySetupComplete,
                    );
                    homeState.selectScenario(
                      completed >= 4
                          ? HomeScenario.activeAdmin
                          : completed > 1
                          ? HomeScenario.partialAdmin
                          : draft.homeSetupAdmin
                          ? HomeScenario.newAdmin
                          : HomeScenario.newMember,
                    );
                  }
                  return HomeCommandScreen(state: homeState);
                },
              ),
              GoRoute(
                path: '/home-preview',
                redirect: (context, state) => '/home',
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _splitNavigatorKey,
            routes: [
              GoRoute(
                path: '/split',
                builder: (context, state) => ScenarioGate(
                  repository: repository,
                  section: 'Split',
                  child: SplitOverviewScreen(state: splitState),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _vaultNavigatorKey,
            routes: [
              GoRoute(
                path: '/vault',
                builder: (context, state) => ScenarioGate(
                  repository: repository,
                  section: 'Vault',
                  child: VaultOverviewScreen(state: vaultState),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _stuffNavigatorKey,
            routes: [
              GoRoute(
                path: '/stuff',
                builder: (context, state) => ScenarioGate(
                  repository: repository,
                  section: 'Stuff',
                  child: StuffOverviewScreen(state: stuffState),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _youNavigatorKey,
            routes: [
              GoRoute(
                path: '/you',
                builder: (context, state) => ScenarioGate(
                  repository: repository,
                  section: 'You',
                  child: const AccountScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
