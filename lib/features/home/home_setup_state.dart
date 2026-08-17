import 'package:flutter/foundation.dart';

class HomeRecurringCost {
  const HomeRecurringCost({
    required this.id,
    required this.name,
    required this.amountPence,
    required this.frequency,
  });

  final String id;
  final String name;
  final int amountPence;
  final String frequency;
}

class HomeSetupState extends ChangeNotifier {
  int rentPence = 0;
  int rentDueDay = 1;

  final List<HomeRecurringCost> recurringCosts = [];

  bool householdOpened = false;
  bool moveInProtectionStarted = false;
  bool setupCardDismissed = false;

  bool get hasRent => rentPence > 0;
  bool get hasRecurringCosts => recurringCosts.isNotEmpty;

  int get recurringMonthlyPence =>
      recurringCosts.fold(0, (sum, item) => sum + item.amountPence);

  int get monthlyCommitmentsPence => rentPence + recurringMonthlyPence;

  int completedSteps({required bool tenancyComplete}) {
    var count = 0;
    if (tenancyComplete) count++;
    if (hasRent) count++;
    if (hasRecurringCosts) count++;
    if (householdOpened) count++;
    if (moveInProtectionStarted) count++;
    return count;
  }

  double progress({required bool tenancyComplete}) =>
      completedSteps(tenancyComplete: tenancyComplete) / 5;

  bool isComplete({required bool tenancyComplete}) =>
      completedSteps(tenancyComplete: tenancyComplete) == 5;

  void saveRent({required int amountPence, required int dueDay}) {
    rentPence = amountPence;
    rentDueDay = dueDay;
    notifyListeners();
  }

  void addRecurringCost({
    required String name,
    required int amountPence,
    required String frequency,
  }) {
    recurringCosts.add(
      HomeRecurringCost(
        id: 'recurring-${recurringCosts.length + 1}',
        name: name,
        amountPence: amountPence,
        frequency: frequency,
      ),
    );
    notifyListeners();
  }

  void markHouseholdOpened() {
    if (householdOpened) return;
    householdOpened = true;
    notifyListeners();
  }

  void markMoveInProtectionStarted() {
    if (moveInProtectionStarted) return;
    moveInProtectionStarted = true;
    notifyListeners();
  }

  void dismissSetupCard() {
    setupCardDismissed = true;
    notifyListeners();
  }

  void showSetupCard() {
    setupCardDismissed = false;
    notifyListeners();
  }
}
