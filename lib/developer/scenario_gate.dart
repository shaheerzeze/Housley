import 'package:flutter/material.dart';

import '../data/housely_repository.dart';
import '../design_system/components/components.dart';
import '../design_system/theme/housely_tokens.dart';

class ScenarioGate extends StatelessWidget {
  const ScenarioGate({
    required this.repository,
    required this.section,
    required this.child,
    super.key,
  });

  final HouselyRepository repository;
  final String section;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: repository,
    builder: (context, _) {
      final scenario = repository.scenario;
      if (scenario == DemoScenario.populated) return child;
      if (scenario == DemoScenario.largeText) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child,
        );
      }
      if (scenario == DemoScenario.longContent) {
        return _LongContentPage(section: section, onReset: repository.reset);
      }
      return _ScenarioPage(
        scenario: scenario,
        section: section,
        onReset: repository.reset,
      );
    },
  );
}

class _ScenarioPage extends StatelessWidget {
  const _ScenarioPage({
    required this.scenario,
    required this.section,
    required this.onReset,
  });

  final DemoScenario scenario;
  final String section;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: HouselySize.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.all(HouselySpace.lg),
            children: [
              Text(section, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: HouselySpace.xl),
              if (scenario == DemoScenario.loading)
                const _LoadingState()
              else
                HouselyMessageState(
                  title: _title,
                  message: _message,
                  kind: _kind,
                  actionLabel: 'Return to populated state',
                  onAction: onReset,
                ),
            ],
          ),
        ),
      ),
    ),
  );

  String get _title => switch (scenario) {
    DemoScenario.empty => 'Nothing here yet',
    DemoScenario.offline => 'You are offline',
    DemoScenario.validationError => 'Check the highlighted details',
    DemoScenario.serviceError => 'We could not refresh $section',
    DemoScenario.permissionLost => 'Access has changed',
    DemoScenario.disabled => 'One more step is needed',
    DemoScenario.success => 'All done',
    _ => scenario.label,
  };

  String get _message => switch (scenario) {
    DemoScenario.empty =>
      'Create the first record when your household is ready.',
    DemoScenario.offline =>
      'Showing cached metadata from just now. Drafts remain available, but final money and lock actions wait for a connection.',
    DemoScenario.validationError =>
      'Correct the fields marked in coral, then try again.',
    DemoScenario.serviceError =>
      'Nothing was lost. Wait a moment and safely retry.',
    DemoScenario.permissionLost =>
      'Ask a home admin if you think you should still see this information.',
    DemoScenario.disabled =>
      'Complete the required household details before continuing.',
    DemoScenario.success =>
      'The change is saved and everyone affected can now see it.',
    _ => scenario.description,
  };

  HouselyMessageKind get _kind => switch (scenario) {
    DemoScenario.empty || DemoScenario.disabled => HouselyMessageKind.empty,
    DemoScenario.offline => HouselyMessageKind.offline,
    DemoScenario.success => HouselyMessageKind.success,
    _ => HouselyMessageKind.error,
  };
}

class _LongContentPage extends StatelessWidget {
  const _LongContentPage({required this.section, required this.onReset});

  final String section;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: HouselySize.maxContentWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.all(HouselySpace.lg),
            children: [
              Text(section, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: HouselySpace.xl),
              const HouselyMessageState(
                title:
                    'Alexandra-Mae Montgomery-Sutherland is reviewing this unusually detailed household record',
                message:
                    '£12,345,678.90 · George Street Flat and Extended Shared Tenancy Agreement Archive · Last updated 31 December 2026 at 23:59',
                kind: HouselyMessageKind.empty,
              ),
              const SizedBox(height: HouselySpace.md),
              HouselyButton(
                label: 'Return to populated state',
                onPressed: onReset,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      HouselySkeleton(width: 180, height: 26),
      SizedBox(height: HouselySpace.lg),
      HouselySkeleton(height: 132, radius: HouselyRadius.feature),
      SizedBox(height: HouselySpace.md),
      HouselySkeleton(height: 76, radius: HouselyRadius.group),
      SizedBox(height: HouselySpace.sm),
      HouselySkeleton(height: 76, radius: HouselyRadius.group),
    ],
  );
}
