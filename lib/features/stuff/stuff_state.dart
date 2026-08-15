import 'package:flutter/foundation.dart';

class StuffItem {
  StuffItem({
    required this.name,
    required this.location,
    required this.valuePence,
    required this.owners,
    this.warranty,
  });
  final String name;
  final String location;
  final int valuePence;
  final Map<String, int> owners;
  final String? warranty;
}

class StuffFeatureState extends ChangeNotifier {
  final items = <StuffItem>[
    StuffItem(
      name: 'Living room sofa',
      location: 'Living room',
      valuePence: 62000,
      owners: {'You': 50, 'Alex': 50},
      warranty: 'Ends 14 Oct 2026',
    ),
    StuffItem(
      name: 'Coffee machine',
      location: 'Kitchen',
      valuePence: 18900,
      owners: {'You': 100},
    ),
  ];
  String draftName = '';
  String draftLocation = 'Living room';
  int draftValuePence = 0;
  int yourShare = 50;

  void setYourShare(int value) {
    yourShare = value;
    notifyListeners();
  }

  void addDraft() {
    items.insert(
      0,
      StuffItem(
        name: draftName,
        location: draftLocation,
        valuePence: draftValuePence,
        owners: {'You': yourShare, 'Alex': 100 - yourShare},
      ),
    );
    draftName = '';
    draftValuePence = 0;
    yourShare = 50;
    notifyListeners();
  }
}
