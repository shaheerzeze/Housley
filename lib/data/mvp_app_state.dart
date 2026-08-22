import 'package:flutter/foundation.dart';

import '../features/home/home_state.dart';
import '../features/split/split_state.dart';
import '../features/stuff/stuff_state.dart';
import '../features/vault/vault_state.dart';

enum HouselyRole { homeAdmin, member, temporaryResident }

enum HomeLifecycle { noHome, newHome, settingUp, active, movingOut, archived }

extension HouselyRoleDetails on HouselyRole {
  String get label => switch (this) {
    HouselyRole.homeAdmin => 'Home admin',
    HouselyRole.member => 'Member',
    HouselyRole.temporaryResident => 'Temporary resident',
  };
}

class MockMember {
  MockMember({
    required this.name,
    required this.relationship,
    required this.status,
    this.stayEnds,
  });

  final String name;
  final String relationship;
  String status;
  DateTime? stayEnds;
}

class MockTask {
  MockTask({required this.title, required this.assignee, this.complete = false});
  final String title;
  final String assignee;
  bool complete;
}

class MockHomeChange {
  MockHomeChange({required this.title, required this.current, required this.proposed});
  final String title;
  final String current;
  final String proposed;
  String status = 'Waiting for approval';
}

class MockNotification {
  MockNotification({required this.title, required this.destination});
  final String title;
  final String destination;
  bool read = false;
}

/// One UI-facing source of truth for the entire offline prototype.
/// Supabase repositories can replace the internals later without changing the
/// screen-level permission and transition contracts.
class MvpAppState extends ChangeNotifier {
  MvpAppState() {
    _syncHomeScenario();
  }

  final home = HomeFeatureState();
  final split = SplitFeatureState();
  final vault = VaultFeatureState();
  final stuff = StuffFeatureState();

  HouselyRole role = HouselyRole.homeAdmin;
  HomeLifecycle lifecycle = HomeLifecycle.active;
  bool online = true;
  bool authenticated = true;
  int setupCompleted = 4;
  String successTitle = 'Changes saved';
  String successMessage = 'Your Home is up to date.';

  final members = <MockMember>[
    MockMember(name: 'Muhammad Shaheer', relationship: 'Named tenant · Home admin', status: 'Joined'),
    MockMember(name: 'Alex Morgan', relationship: 'Named on tenancy', status: 'Not joined'),
    MockMember(name: 'Meera Thomas', relationship: 'Household member', status: 'Joined'),
    MockMember(
      name: 'Maya Jones',
      relationship: 'Temporary resident',
      status: 'Joined',
      stayEnds: DateTime(2026, 9, 30),
    ),
  ];

  final tasks = <MockTask>[
    MockTask(title: 'Submit meter reading', assignee: 'You'),
    MockTask(title: 'Take bins out', assignee: 'Alex'),
  ];

  final changes = <MockHomeChange>[
    MockHomeChange(title: 'Energy contribution', current: '£92.00', proposed: '£108.00'),
  ];

  final notifications = <MockNotification>[
    MockNotification(title: 'Council tax is due in 3 days', destination: '/recurring-payment-detail'),
    MockNotification(title: 'Alex accepted your invitation', destination: '/person-detail'),
    MockNotification(title: 'Move-in evidence was locked', destination: '/locked-evidence'),
  ];

  final privateGroups = <String>['Weekend groceries', 'Edinburgh trip'];
  bool councilTaxPaid = false;

  final moveOutSteps = <String, bool>{
    'Settle balances': false,
    'Review recurring payments': false,
    'Resolve item ownership': false,
    'Save personal documents': true,
    'Compare move-in evidence': false,
  };

  bool get isAdmin => role == HouselyRole.homeAdmin;
  bool get isGuest => role == HouselyRole.temporaryResident;
  bool get moveOutReady => moveOutSteps.entries
      .where((entry) => entry.key != 'Compare move-in evidence')
      .every((entry) => entry.value);

  void selectRole(HouselyRole value) {
    role = value;
    lifecycle = lifecycle == HomeLifecycle.archived ? lifecycle : HomeLifecycle.active;
    _syncHomeScenario();
    notifyListeners();
  }

  void selectLifecycle(HomeLifecycle value) {
    lifecycle = value;
    _syncHomeScenario();
    notifyListeners();
  }

  void selectHomeScenario(HomeScenario scenario) {
    switch (scenario) {
      case HomeScenario.noHome:
        lifecycle = HomeLifecycle.noHome;
        break;
      case HomeScenario.newAdmin:
        role = HouselyRole.homeAdmin;
        lifecycle = HomeLifecycle.newHome;
        break;
      case HomeScenario.newMember:
        role = HouselyRole.member;
        lifecycle = HomeLifecycle.newHome;
        break;
      case HomeScenario.partialAdmin:
        role = HouselyRole.homeAdmin;
        lifecycle = HomeLifecycle.settingUp;
        break;
      case HomeScenario.activeAdmin:
      case HomeScenario.householdAttention:
        role = HouselyRole.homeAdmin;
        lifecycle = HomeLifecycle.active;
        break;
      case HomeScenario.activeMember:
      case HomeScenario.allGoodMember:
      case HomeScenario.rentDue:
      case HomeScenario.overdue:
        role = HouselyRole.member;
        lifecycle = HomeLifecycle.active;
        break;
      case HomeScenario.guestStay:
        role = HouselyRole.temporaryResident;
        lifecycle = HomeLifecycle.active;
        break;
      case HomeScenario.movingOut:
        lifecycle = HomeLifecycle.movingOut;
        break;
      case HomeScenario.archived:
        lifecycle = HomeLifecycle.archived;
        break;
    }
    home.selectScenario(scenario);
    notifyListeners();
  }

  void setOnline(bool value) {
    online = value;
    notifyListeners();
  }

  bool canAccess(String path) {
    if (path == '/state-lab' || path == '/mvp-screens' || path == '/accessibility-review') return true;
    if (lifecycle == HomeLifecycle.archived) {
      return path == '/home' || path == '/vault' || path == '/locked-evidence' || path == '/export-ready' || path == '/you' || path == '/archived-home' || path == '/move-out-review' || path == '/move-out-complete';
    }
    const adminOnly = <String>{
      '/invite-person-type',
      '/invite-person',
      '/review-invitation',
      '/member-permissions',
      '/end-stay',
      '/propose-change',
      '/review-change',
      '/household-management',
      '/add-household-member',
      '/remove-household-member',
      '/named-tenant-removal-info',
      '/invite-members',
      '/member-access',
      '/connect-tenant-member',
      '/setup-rent',
      '/setup-recurring',
      '/setup-move-in',
    };
    if (adminOnly.contains(path) && !isAdmin) return false;
    if (isGuest) {
      const guestBlocked = <String>{
        '/household-overview',
        '/changes-overview',
        '/approve-change',
        '/deposit-rooms',
        '/capture-evidence',
        '/review-evidence',
      };
      if (guestBlocked.contains(path)) return false;
    }
    return true;
  }

  void completeSetupStep() {
    if (setupCompleted < 4) setupCompleted++;
    lifecycle = setupCompleted == 4 ? HomeLifecycle.active : HomeLifecycle.settingUp;
    _syncHomeScenario();
    notifyListeners();
  }

  void invite(String name) {
    final existing = members.where((member) => member.name == name);
    if (existing.isNotEmpty) {
      existing.first.status = 'Invited · Waiting to join';
    } else {
      members.add(MockMember(name: name, relationship: 'Household member', status: 'Invited · Waiting to join'));
    }
    setOutcome('Invitation sent', '$name can now join George Street Flat.');
  }

  void extendGuest() {
    MockMember? guest;
    for (final member in members) {
      if (member.relationship == 'Temporary resident') guest = member;
    }
    if (guest != null) guest.stayEnds = DateTime(2026, 10, 31);
    setOutcome('Stay extended', 'Temporary access now ends on 31 October 2026.');
  }

  void endGuest() {
    MockMember? guest;
    for (final member in members) {
      if (member.relationship == 'Temporary resident') guest = member;
    }
    if (guest != null) guest.status = 'Stay ended';
    setOutcome('Temporary stay ended', 'Household access has been removed.');
  }

  void completeTask() {
    if (tasks.isNotEmpty) tasks.first.complete = true;
    setOutcome('Task completed', 'The household timeline has been updated.');
  }

  void createPrivateGroup(String name) {
    if (name.trim().isNotEmpty && !privateGroups.contains(name.trim())) {
      privateGroups.insert(0, name.trim());
    }
    setOutcome('Private group created', '${name.trim()} is visible only to its participants.');
  }

  void recordCouncilTax() {
    councilTaxPaid = true;
    setOutcome('Payment recorded', 'September council tax has been marked as paid.');
  }

  void approveChange() {
    if (changes.isNotEmpty) changes.first.status = 'Approved';
    setOutcome('Approval recorded', 'The change will apply after every required approval.');
  }

  void setMoveOutStep(String step, bool value) {
    if (moveOutSteps.containsKey(step)) moveOutSteps[step] = value;
    notifyListeners();
  }

  void finishMoveOut() {
    if (!moveOutReady) return;
    moveOutSteps['Compare move-in evidence'] = true;
    lifecycle = HomeLifecycle.archived;
    setOutcome('Move-out record protected', 'Your Home is now archived and remains available read-only.');
    _syncHomeScenario();
  }

  void markNotificationRead(int index) {
    if (index >= 0 && index < notifications.length) notifications[index].read = true;
    notifyListeners();
  }

  void setOutcome(String title, String message) {
    successTitle = title;
    successMessage = message;
    notifyListeners();
  }

  void _syncHomeScenario() {
    final scenario = switch (lifecycle) {
      HomeLifecycle.noHome => HomeScenario.noHome,
      HomeLifecycle.newHome => isAdmin ? HomeScenario.newAdmin : HomeScenario.newMember,
      HomeLifecycle.settingUp => HomeScenario.partialAdmin,
      HomeLifecycle.movingOut => HomeScenario.movingOut,
      HomeLifecycle.archived => HomeScenario.archived,
      HomeLifecycle.active => switch (role) {
        HouselyRole.homeAdmin => HomeScenario.activeAdmin,
        HouselyRole.member => HomeScenario.activeMember,
        HouselyRole.temporaryResident => HomeScenario.guestStay,
      },
    };
    home.selectScenario(scenario);
  }
}
