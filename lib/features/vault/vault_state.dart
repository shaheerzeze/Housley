import 'package:flutter/foundation.dart';

class VaultDocument {
  VaultDocument({
    required this.title,
    required this.category,
    required this.visibility,
    required this.date,
  });
  final String title;
  final String category;
  final String visibility;
  final String date;
}

class VaultFeatureState extends ChangeNotifier {
  final documents = <VaultDocument>[
    VaultDocument(
      title: 'Tenancy agreement.pdf',
      category: 'Tenancy',
      visibility: 'Household',
      date: '4 Aug 2026',
    ),
    VaultDocument(
      title: 'Contents insurance.pdf',
      category: 'Insurance',
      visibility: 'Personal',
      date: '29 Jul 2026',
    ),
  ];
  final areas = <String, int>{
    'Entrance': 3,
    'Living room': 5,
    'Kitchen': 6,
    'Main bedroom': 0,
  };
  bool depositLocked = false;

  bool get evidenceComplete => areas.values.every((count) => count > 0);
  int get totalEvidence => areas.values.fold(0, (sum, count) => sum + count);

  void addDocument(VaultDocument document) {
    documents.insert(0, document);
    notifyListeners();
  }

  void capture(String area) {
    areas[area] = (areas[area] ?? 0) + 1;
    notifyListeners();
  }

  void lock() {
    if (evidenceComplete) {
      depositLocked = true;
      notifyListeners();
    }
  }
}
