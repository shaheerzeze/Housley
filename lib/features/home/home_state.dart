import 'package:flutter/foundation.dart';

enum HomeScenario {
  noHome,
  newAdmin,
  newMember,
  partialAdmin,
  activeAdmin,
  activeMember,
  allGoodMember,
  rentDue,
  overdue,
  householdAttention,
  guestStay,
  movingOut,
  archived,
}

extension HomeScenarioDetails on HomeScenario {
  String get label => switch (this) {
    HomeScenario.noHome => 'No Home yet',
    HomeScenario.newAdmin => 'New Home admin',
    HomeScenario.newMember => 'First Home after joining',
    HomeScenario.partialAdmin => 'Partially set-up admin',
    HomeScenario.activeAdmin => 'Fully set-up admin',
    HomeScenario.activeMember => 'Active member',
    HomeScenario.allGoodMember => 'Member · All up to date',
    HomeScenario.rentDue => 'Rent due soon',
    HomeScenario.overdue => 'Rent overdue',
    HomeScenario.householdAttention => 'Household attention',
    HomeScenario.guestStay => 'Active guest stay',
    HomeScenario.movingOut => 'Moving out',
    HomeScenario.archived => 'Archived Home',
  };

  String get description => switch (this) {
    HomeScenario.noHome => 'Registered user who has not created or joined a Home.',
    HomeScenario.newAdmin => 'Creator sees the first meaningful Home setup step.',
    HomeScenario.newMember => 'Joining member confirms only their own responsibilities.',
    HomeScenario.partialAdmin => 'The Home is usable but one setup task remains.',
    HomeScenario.activeAdmin => 'Household-level commitments, people and activity.',
    HomeScenario.activeMember => 'A personal view of shared commitments and activity.',
    HomeScenario.allGoodMember => 'A calm state with no unresolved actions.',
    HomeScenario.rentDue => 'A warm, time-sensitive personal reminder.',
    HomeScenario.overdue => 'A clear overdue action without an alarming whole screen.',
    HomeScenario.householdAttention => 'Non-financial household issues need an admin.',
    HomeScenario.guestStay => 'Temporary dates, contributions and limited access.',
    HomeScenario.movingOut => 'Evidence, belongings and final commitments.',
    HomeScenario.archived => 'Read-only access after leaving a Home.',
  };
}

class AttentionItem {
  AttentionItem(this.id, this.title, this.detail, this.route, {this.amount});
  final String id;
  final String title;
  final String detail;
  final String route;
  final String? amount;
  bool resolved = false;
}

class HomeFeatureState extends ChangeNotifier {
  HomeScenario _scenario = HomeScenario.activeAdmin;
  HomeScenario get scenario => _scenario;

  final attention = <AttentionItem>[
    AttentionItem(
      'member',
      'Alex has not joined yet',
      'Named on tenancy · Not joined',
      '/household',
    ),
    AttentionItem(
      'bill',
      'Energy bill needs review',
      'Household · Action required',
      '/expense-detail',
      amount: '£84.20',
    ),
    AttentionItem(
      'leaving',
      'Alex is leaving',
      '4 connected records need review',
      '/change-impact',
    ),
  ];

  bool balanceResolved = false;
  bool recurringResolved = false;
  bool itemsResolved = false;
  bool departureComplete = false;

  int get attentionCount => attention.where((item) => !item.resolved).length;
  bool get canFinishMoveOut =>
      balanceResolved && recurringResolved && itemsResolved;

  void selectScenario(HomeScenario value) {
    if (_scenario == value) return;
    _scenario = value;
    notifyListeners();
  }

  void resolve(String id) {
    final matches = attention.where((item) => item.id == id);
    if (matches.isNotEmpty) matches.first.resolved = true;
    notifyListeners();
  }

  void setBalance(bool value) {
    balanceResolved = value;
    notifyListeners();
  }

  void setRecurring(bool value) {
    recurringResolved = value;
    notifyListeners();
  }

  void setItems(bool value) {
    itemsResolved = value;
    notifyListeners();
  }

  void finishDeparture() {
    if (!canFinishMoveOut) return;
    departureComplete = true;
    resolve('leaving');
  }
}
