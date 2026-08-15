import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/housely_repository.dart';
import '../design_system/components/components.dart';
import '../design_system/theme/housely_tokens.dart';
import '../features/shared/feature_scaffold.dart';

class StateLabScreen extends StatelessWidget {
  const StateLabScreen({required this.repository, super.key});

  final HouselyRepository repository;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: repository,
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
          Text(
            'Screen scenario',
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
              onTap: () => repository.selectScenario(scenario),
            ),
            const SizedBox(height: HouselySpace.sm),
          ],
          const SizedBox(height: HouselySpace.md),
          HouselyButton(
            label: 'Preview on Home',
            leadingIcon: Icons.home_outlined,
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: HouselySpace.sm),
          HouselyButton(
            label: 'Reset prototype data',
            style: HouselyButtonStyle.secondary,
            onPressed: repository.reset,
          ),
        ],
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
