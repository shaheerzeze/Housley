import 'package:flutter/foundation.dart';

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
  final attention = <AttentionItem>[
    AttentionItem(
      'bill',
      'Electricity is due',
      'Due tomorrow · Household',
      '/expense-detail',
      amount: '£84.20',
    ),
    AttentionItem(
      'leaving',
      'Alex is leaving',
      '4 connected records need review',
      '/change-impact',
    ),
    AttentionItem(
      'deposit',
      'Complete deposit evidence',
      '2 rooms still need photos',
      '/home',
    ),
  ];

  bool balanceResolved = false;
  bool recurringResolved = false;
  bool itemsResolved = false;
  bool departureComplete = false;

  int get attentionCount => attention.where((item) => !item.resolved).length;
  bool get canFinishMoveOut =>
      balanceResolved && recurringResolved && itemsResolved;

  void resolve(String id) {
    final item = attention.where((item) => item.id == id).firstOrNull;
    if (item != null) item.resolved = true;
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
