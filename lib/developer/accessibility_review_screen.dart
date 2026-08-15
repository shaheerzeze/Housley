import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/housely_repository.dart';
import '../design_system/components/components.dart';
import '../design_system/theme/housely_tokens.dart';
import '../features/shared/feature_scaffold.dart';

class AccessibilityReviewScreen extends StatelessWidget {
  const AccessibilityReviewScreen({required this.repository, super.key});

  final HouselyRepository repository;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return FeatureScaffold(
      title: 'Accessibility review',
      subtitle: 'Phase 12 · Interaction polish  /  Phase 13 · Inclusive design',
      onBack: () => context.pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HouselySection(
            title: 'Current environment',
            child: HouselyGroupedList(
              children: [
                HouselyRecordRow(
                  title: '${media.size.width.round()} px viewport',
                  subtitle: media.size.width < 600
                      ? 'Compact mobile layout'
                      : 'Centred wide-screen layout',
                  icon: Icons.devices_outlined,
                  onTap: () {},
                ),
                HouselyRecordRow(
                  title: media.disableAnimations
                      ? 'Reduced motion enabled'
                      : 'Standard motion enabled',
                  subtitle: 'Follows the operating-system preference',
                  icon: Icons.animation_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: HouselySpace.xl),
          HouselySection(
            title: 'Motion and feedback',
            child: HouselyGroupedList(
              children: const [
                _CheckRow(title: '150–280 ms motion token range'),
                _CheckRow(title: 'Page entrances preserve spatial context'),
                _CheckRow(title: 'Button presses provide platform feedback'),
                _CheckRow(title: 'Reduced-motion preference is respected'),
              ],
            ),
          ),
          const SizedBox(height: HouselySpace.xl),
          HouselySection(
            title: 'Acceptance checks',
            child: HouselyGroupedList(
              children: const [
                _CheckRow(title: '48 px minimum interaction targets'),
                _CheckRow(title: 'Visible labels and semantic names'),
                _CheckRow(title: 'Colour is never the only status signal'),
                _CheckRow(title: 'Safe areas and keyboard insets respected'),
                _CheckRow(title: 'Content remains usable at 200% text'),
                _CheckRow(title: 'Long names and money values wrap safely'),
              ],
            ),
          ),
          const SizedBox(height: HouselySpace.xl),
          HouselyButton(
            label: 'Preview 200% text on Home',
            leadingIcon: Icons.text_increase_rounded,
            onPressed: () {
              repository.selectScenario(DemoScenario.largeText);
              context.go('/home');
            },
          ),
          const SizedBox(height: HouselySpace.sm),
          HouselyButton(
            label: 'Preview long content',
            style: HouselyButtonStyle.secondary,
            leadingIcon: Icons.subject_rounded,
            onPressed: () {
              repository.selectScenario(DemoScenario.longContent);
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$title, passed',
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: HouselySize.minTouch),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HouselySpace.md,
          vertical: HouselySpace.sm,
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: HouselyPalette.mint),
            const SizedBox(width: HouselySpace.md),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    ),
  );
}
