import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/components.dart';
import '../../design_system/theme/housely_tokens.dart';

class HouselyAppShell extends StatelessWidget {
  const HouselyAppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    void select(HouselyDestination destination) {
      final index = HouselyDestination.values.indexOf(destination);
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    final selected = HouselyDestination.values[navigationShell.currentIndex];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 840;
        return Scaffold(
          extendBody: !wide,
          body: wide
              ? SafeArea(
                  child: Row(
                    children: [
                      _HouselySideRail(selected: selected, onSelected: select),
                      const VerticalDivider(width: 1),
                      Expanded(child: navigationShell),
                    ],
                  ),
                )
              : navigationShell,
          bottomNavigationBar: wide
              ? null
              : HouselyBottomDock(selected: selected, onSelected: select),
        );
      },
    );
  }
}

class _HouselySideRail extends StatelessWidget {
  const _HouselySideRail({required this.selected, required this.onSelected});

  final HouselyDestination selected;
  final ValueChanged<HouselyDestination> onSelected;

  @override
  Widget build(BuildContext context) => NavigationRail(
    selectedIndex: HouselyDestination.values.indexOf(selected),
    onDestinationSelected: (index) =>
        onSelected(HouselyDestination.values[index]),
    labelType: NavigationRailLabelType.all,
    groupAlignment: 0,
    backgroundColor: HouselyPalette.textPrimary,
    indicatorColor: HouselyPalette.surface,
    leading: const Padding(
      padding: EdgeInsets.only(top: HouselySpace.md, bottom: HouselySpace.xl),
      child: HomePulse(size: 42),
    ),
    destinations: const [
      NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long_rounded),
        label: Text('Split'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder_rounded),
        label: Text('Vault'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.chair_outlined),
        selectedIcon: Icon(Icons.chair_rounded),
        label: Text('Stuff'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('You'),
      ),
    ],
  );
}

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) => _TabPage(
    title: 'Home',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HouselyHomeIdentity(
          name: 'George Street Flat',
          address: '18 George Street, Edinburgh',
          members: ['Muhammad Shaheer', 'Alex Morgan', 'Sam Lee'],
        ),
        const SizedBox(height: HouselySpace.xxl),
        Text('Good evening', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: HouselySpace.xs),
        Text(
          'Three things need your attention.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: HouselyPalette.textSecondary),
        ),
        const SizedBox(height: HouselySpace.xl),
        HouselyGroupedList(
          children: [
            HouselyAttentionRow(
              title: 'Electricity is due',
              detail: 'Due tomorrow',
              amount: '£84.20',
              actionLabel: 'Review',
              onTap: () {},
            ),
            HouselyAttentionRow(
              title: 'Alex is leaving',
              detail: '4 records need review',
              actionLabel: 'Resolve',
              onTap: () {},
            ),
          ],
        ),
      ],
    ),
  );
}

class FeatureTabPage extends StatelessWidget {
  const FeatureTabPage({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _TabPage(
    title: title,
    child: HouselyMessageState(
      kind: HouselyMessageKind.empty,
      title: '$title is ready',
      message: message,
      actionLabel: 'Explore $title',
      onAction: () {},
    ),
  );
}

class _TabPage extends StatelessWidget {
  const _TabPage({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: HouselySize.maxContentWidth,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            HouselySize.phoneGutter,
            HouselySpace.lg,
            HouselySize.phoneGutter,
            HouselySpace.section,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                HouselyIconButton(
                  icon: Icons.grid_view_rounded,
                  label: 'More',
                  onPressed: () => showHouselyMoreSheet(context),
                ),
              ],
            ),
            const SizedBox(height: HouselySpace.xl),
            child,
          ],
        ),
      ),
    ),
  );
}
