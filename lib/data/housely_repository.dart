import 'package:flutter/foundation.dart';

enum DemoScenario {
  populated,
  loading,
  empty,
  offline,
  validationError,
  serviceError,
  permissionLost,
  disabled,
  success,
  largeText,
  longContent,
}

extension DemoScenarioDetails on DemoScenario {
  String get label => switch (this) {
    DemoScenario.populated => 'Populated',
    DemoScenario.loading => 'Loading',
    DemoScenario.empty => 'Empty',
    DemoScenario.offline => 'Offline',
    DemoScenario.validationError => 'Validation error',
    DemoScenario.serviceError => 'Service error',
    DemoScenario.permissionLost => 'Permission lost',
    DemoScenario.disabled => 'Disabled action',
    DemoScenario.success => 'Success',
    DemoScenario.largeText => 'Large text',
    DemoScenario.longContent => 'Long content',
  };

  String get description => switch (this) {
    DemoScenario.populated => 'A realistic, fully populated household.',
    DemoScenario.loading => 'Slow connection with content placeholders.',
    DemoScenario.empty => 'A new home with no records yet.',
    DemoScenario.offline => 'Cached content with the network unavailable.',
    DemoScenario.validationError => 'Invalid input with recovery guidance.',
    DemoScenario.serviceError => 'A recoverable server-side failure.',
    DemoScenario.permissionLost => 'The member no longer has access.',
    DemoScenario.disabled => 'An action is waiting on a prerequisite.',
    DemoScenario.success => 'A completed action and clear next step.',
    DemoScenario.largeText => 'Accessibility text at 200 percent.',
    DemoScenario.longContent => 'Long names and values stress the layout.',
  };
}

class HouselySnapshot {
  const HouselySnapshot({
    required this.homeName,
    required this.memberCount,
    required this.attentionCount,
    required this.expenseCount,
    required this.documentCount,
    required this.itemCount,
  });

  final String homeName;
  final int memberCount;
  final int attentionCount;
  final int expenseCount;
  final int documentCount;
  final int itemCount;
}

/// The UI-facing contract. A REST, Supabase, or Firebase implementation can
/// replace the mock without changing the feature screens.
abstract class HouselyRepository extends ChangeNotifier {
  DemoScenario get scenario;
  HouselySnapshot get cachedSnapshot;
  Duration get simulatedLatency;
  Future<HouselySnapshot> refresh();
  void selectScenario(DemoScenario value);
  void reset();
}

class MockHouselyRepository extends HouselyRepository {
  DemoScenario _scenario = DemoScenario.populated;

  @override
  DemoScenario get scenario => _scenario;

  @override
  Duration get simulatedLatency => const Duration(milliseconds: 650);

  @override
  HouselySnapshot get cachedSnapshot => const HouselySnapshot(
    homeName: 'George Street Flat',
    memberCount: 3,
    attentionCount: 3,
    expenseCount: 4,
    documentCount: 6,
    itemCount: 5,
  );

  @override
  Future<HouselySnapshot> refresh() async {
    await Future<void>.delayed(simulatedLatency);
    if (_scenario == DemoScenario.offline) {
      throw const HouselyDataException('You are offline. Cached data is safe.');
    }
    if (_scenario == DemoScenario.serviceError) {
      throw const HouselyDataException('The service could not refresh.');
    }
    return cachedSnapshot;
  }

  @override
  void selectScenario(DemoScenario value) {
    if (_scenario == value) return;
    _scenario = value;
    notifyListeners();
  }

  @override
  void reset() => selectScenario(DemoScenario.populated);
}

class HouselyDataException implements Exception {
  const HouselyDataException(this.message);
  final String message;
}
