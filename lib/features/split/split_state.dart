import 'package:flutter/foundation.dart';

class ExpenseRecord {
  ExpenseRecord({
    required this.title,
    required this.amountPence,
    required this.payer,
    required this.scope,
  });
  final String title;
  final int amountPence;
  final String payer;
  final String scope;
}

class ExpenseDraft {
  String title = '';
  int amountPence = 0;
  String payer = 'You';
  String scope = 'Household';
  final Set<String> people = {'You', 'Alex', 'Sam'};
  String method = 'Equal';

  void clear() {
    title = '';
    amountPence = 0;
    payer = 'You';
    scope = 'Household';
    people
      ..clear()
      ..addAll({'You', 'Alex', 'Sam'});
    method = 'Equal';
  }
}

class SplitFeatureState extends ChangeNotifier {
  final draft = ExpenseDraft();
  final expenses = <ExpenseRecord>[
    ExpenseRecord(
      title: 'Weekly shop',
      amountPence: 4260,
      payer: 'Alex',
      scope: 'Household',
    ),
    ExpenseRecord(
      title: 'Internet',
      amountPence: 3200,
      payer: 'You',
      scope: 'Household',
    ),
  ];
  int balancePence = 12640;

  void addExpense() {
    expenses.insert(
      0,
      ExpenseRecord(
        title: draft.title,
        amountPence: draft.amountPence,
        payer: draft.payer,
        scope: draft.scope,
      ),
    );
    draft.clear();
    notifyListeners();
  }

  void settle(int amountPence) {
    balancePence = (balancePence - amountPence).clamp(0, 1 << 31);
    notifyListeners();
  }
}
