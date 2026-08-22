import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/housely_repository.dart';
import '../data/mvp_app_state.dart';
import '../design_system/components/components.dart';
import '../design_system/theme/housely_tokens.dart';
import '../features/shared/feature_scaffold.dart';
import '../features/home/home_state.dart';

class StateLabScreen extends StatelessWidget {
  const StateLabScreen({required this.repository, required this.homeState, required this.appState, super.key});

  final HouselyRepository repository;
  final HomeFeatureState homeState;
  final MvpAppState appState;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([repository, homeState, appState]),
    builder: (context, _) => FeatureScaffold(
      title: 'State lab',
      subtitle: 'Phase 10 · Mock data  /  Phase 11 · Required states',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselyPrivacyNotice(
            title: 'Local prototype controls',
            message:
                'These choices only change this session. No household data is sent or deleted.',
          ),
          const SizedBox(height: HouselySpace.xl),
          Text('Current role', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: HouselySpace.xs),
          Text(
            'Role controls both the Home variation and route-level permissions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: HouselySpace.md),
          HouselySegmentedControl<HouselyRole>(
            segments: {for (final role in HouselyRole.values) role: role.label},
            selected: appState.role,
            onChanged: appState.selectRole,
          ),
          const SizedBox(height: HouselySpace.xl),
          Text('Home variation', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: HouselySpace.xs),
          Text(
            'Preview the real adaptive Home for each role, lifecycle and priority.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: HouselySpace.md),
          for (final scenario in HomeScenario.values) ...[
            _HomeScenarioTile(
              scenario: scenario,
              selected: homeState.scenario == scenario,
              onTap: () {
                repository.selectScenario(DemoScenario.populated);
                appState.selectHomeScenario(scenario);
              },
            ),
            const SizedBox(height: HouselySpace.sm),
          ],
          const SizedBox(height: HouselySpace.xl),
          Text(
            'System state',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: HouselySpace.xs),
          Text(
            'Choose a state, then open any main tab to test it in context.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: HouselySpace.md),
          for (final scenario in DemoScenario.values) ...[
            _ScenarioTile(
              scenario: scenario,
              selected: repository.scenario == scenario,
              onTap: () {
                repository.selectScenario(scenario);
                appState.setOnline(scenario != DemoScenario.offline);
              },
            ),
            const SizedBox(height: HouselySpace.sm),
          ],
          const SizedBox(height: HouselySpace.md),
          HouselyButton(
            label: 'Preview on Home',
            leadingIcon: Icons.home_outlined,
            onPressed: () => context.go('/home-preview'),
          ),
          const SizedBox(height: HouselySpace.sm),
          HouselyButton(
            label: 'Open complete MVP screen library',
            leadingIcon: Icons.view_quilt_outlined,
            style: HouselyButtonStyle.secondary,
            onPressed: () => context.push('/mvp-screens'),
          ),
          const SizedBox(height: HouselySpace.sm),
          HouselyButton(
            label: 'Reset prototype data',
            style: HouselyButtonStyle.secondary,
            onPressed: () {
              repository.reset();
              appState.selectHomeScenario(HomeScenario.activeAdmin);
            },
          ),
        ],
      ),
    ),
  );
}

class _HomeScenarioTile extends StatelessWidget {
  const _HomeScenarioTile({required this.scenario, required this.selected, required this.onTap});
  final HomeScenario scenario;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected ? HouselyPalette.violetSoft : HouselyPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HouselyRadius.group),
        side: BorderSide(color: selected ? HouselyPalette.violet : HouselyPalette.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(HouselySpace.md),
          child: Row(
            children: [
              Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? HouselyPalette.violet : HouselyPalette.textSecondary),
              const SizedBox(width: HouselySpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(scenario.label, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(scenario.description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.scenario,
    required this.selected,
    required this.onTap,
  });

  final DemoScenario scenario;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Material(
      color: selected ? HouselyPalette.violetSoft : HouselyPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HouselyRadius.group),
        side: BorderSide(
          color: selected ? HouselyPalette.violet : HouselyPalette.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: HouselySize.minTouch),
          child: Padding(
            padding: const EdgeInsets.all(HouselySpace.md),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected
                      ? HouselyPalette.violet
                      : HouselyPalette.textSecondary,
                ),
                const SizedBox(width: HouselySpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scenario.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
